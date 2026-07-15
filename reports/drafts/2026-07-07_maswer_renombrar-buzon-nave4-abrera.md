# Informe de caso — Maswer / Renombrar el buzón compartido "Nave 4 - Abrera"

- **Cliente:** Maswer
- **Dominio:** intern.maswer.com (AD on-prem sincronizado a Entra ID / M365 `maswerag.onmicrosoft.com`; Exchange híbrido)
- **Técnico asignado:** Sebastian Lazarte Castellón (CoolNetworks)
- **Origen:** trabajo interno de mantenimiento (corrección de configuración detectada al editar el buzón)
- **Fecha:** 07-jul-2026
- **Estado actual:** **Resuelto** — nombre corregido y verificado en 365 · higiene de la cuenta pendiente (opcional)

---

## Triaje del ticket

| Campo | Valor |
|---|---|
| Categoría | Accounts and Access (configuración de buzón) |
| Prioridad | P4 - Baja (cosmético/higiene, no bloqueante) |
| Grupo | N1 - Soporte General |
| SLA inicial | Respuesta en 1 día laborable |
| Escalado | No escalado — resuelto en N1 |

---

## Síntoma inicial

Al intentar actualizar el buzón `nave4.abrera@maswer.com` desde el **admin center de
M365 / Exchange Online**, la consola devolvía el error:

> *"Error executing request. The operation on mailbox "Nave 4 - Abrera" failed because
> it's out of the current user's write scope. The action 'Set-Mailbox',
> 'Alias,DisplayName', can't be performed on the object 'Nave 4 - Abrera' because the
> object is being synchronized from your on-premises organization. This action should
> be performed on the object in your on-premises organization."*

Intento posterior con `Set-Mailbox` en una PowerShell local → `El término 'Set-Mailbox'
no se reconoce…` (ventana sin módulo de Exchange cargado).

---

## Diagnóstico

Dos hallazgos:

1. **Entorno híbrido.** El buzón vive en Exchange Online, pero su objeto de directorio
   se **sincroniza desde el AD on-prem**. Los atributos `displayName` y `mailNickname`
   (= "Alias") están **gobernados on-prem** y **no** se pueden editar desde M365 → de ahí
   el error de "write scope". No es un problema de permisos del técnico.

2. **Buzón montado sobre una cuenta reconvertida.** El buzón compartido
   `nave4.abrera@maswer.com` estaba construido sobre la **cuenta de usuario antigua de
   "Miriam Juen Vega"**: alguien le cambió el correo a `nave4.abrera@maswer.com` pero
   **nunca actualizó el nombre**, por lo que en 365 seguía mostrándose como "Miriam Juen
   Vega". El tipo de buzón en 365 sí era correcto: **SharedMailbox** (sin licencia).

---

## Resolución aplicada

Corregido **en origen** (AD on-prem) y sincronizado a 365:

1. **AD** (`dsa.msc` en el DC `MEUAZDC011`, con *View → Advanced Features*):
   - Objeto localizado por búsqueda (`Get-ADObject`/Find) — no aparecía como "Nave 4"
     porque su nombre real era "Miriam Juen Vega".
   - Pestaña *General*: `First name` y `Last name` vaciados; **Display name → `Nave 4 - Abrera`**.
   - Objeto **renombrado** (CN) a `Nave 4 - Abrera`.
   - `mailNickname` → `nave4.abrera` (Attribute Editor). `mail`/`proxyAddresses`/`targetAddress` **sin tocar**.
2. **Sincronización** forzada en el servidor de Azure AD Connect **`MEUAZAC011`**:
   `Start-ADSyncSyncCycle -PolicyType Delta`.
3. **Verificación** en el Exchange admin center / "Administrar buzones" (Ctrl+F5 por caché):
   nombre `Nave 4 - Abrera`, correo `nave4.abrera@maswer.com`, tipo `SharedMailbox`. ✅

---

## Runbook — Cómo replicar (renombrar un buzón híbrido)

Aplicable a **cualquier** buzón de Maswer cuyo nombre/alias haya que cambiar y M365 dé
el error *"out of write scope / synchronized from your on-premises organization"*.

**Regla de oro:** el nombre/alias **NO** se toca en M365. Se edita en el AD on-prem y se
sincroniza. Nunca modificar `mail`, `proxyAddresses` ni `targetAddress` a mano.

### Paso 1 — Localizar el objeto en el AD (`MEUAZDC011`)
El nombre a mostrar en 365 puede **no** coincidir con el nombre del objeto en AD. Buscar
por correo, no por nombre. PowerShell en el DC:
```powershell
Get-ADObject -Filter "mail -like '*<parte-del-correo>*' -or displayName -like '*<texto>*' -or name -like '*<texto>*'" `
  -Properties displayName,mailNickname,mail,distinguishedName |
  Format-List name,displayName,mailNickname,mail,distinguishedName
```
Anota el `distinguishedName` (en qué OU está). Si no aparece, buscar en el catálogo
global: añadir `-Server "MEUAZDC011.intern.maswer.com:3268"`.

### Paso 2 — Editar los atributos (ADUC)
`dsa.msc` → **View → Advanced Features** (imprescindible para ver *Attribute Editor*) →
abrir el objeto → **Propiedades**:
- Pestaña *General*: `Display name` = nombre nuevo (admite espacios y guion).
- Pestaña *Attribute Editor*: `mailNickname` = alias nuevo (**sin espacios ni acentos**;
  válidos letras, números, `.` y `-`).
- **No tocar** `mail`, `proxyAddresses`, `targetAddress`.
- **Apply/OK.** Opcional: clic derecho → *Rename* para alinear el CN con el nombre nuevo.

### Paso 3 — Sincronizar (`MEUAZAC011`)
RDP al servidor de Azure AD Connect, PowerShell como admin:
```powershell
Start-ADSyncSyncCycle -PolicyType Delta      # cambios recientes
# Si Delta no detecta diferencia, forzar reevaluación total:
Start-ADSyncSyncCycle -PolicyType Initial
```
- `Result: Success` = ciclo **lanzado**, no terminado (tarda 1–2 min).
- En *Synchronization Service Manager*, un `Export` hacia `maswerag.onmicrosoft.com` solo
  aparece **si hubo un cambio que empujar**. Sin Export = sin diferencia pendiente →
  revisar que el cambio se guardó en AD (causa nº1) o forzar `Initial`.

### Paso 4 — Verificar
- **Ctrl+F5** en 365 (la lista "Administrar buzones" cachea) o mirar el valor real en el
  **Exchange admin center**.
- Confirmar `displayName`, alias y tipo de buzón correctos.

> Alternativa "de manual" si el servidor tiene Exchange Management Shell on-prem:
> `Set-RemoteMailbox -Identity <buzón> -DisplayName "…" -Alias "…"` en vez de editar
> atributos a mano. Mismo efecto, más limpio.

---

## Buena práctica — Buzones compartidos en híbrido

Que el objeto sea de tipo *User* en el AD on-prem es **normal** en híbrido (es la única
forma de sincronizarlo). La buena práctica no la define el tipo de objeto, sino:

| Criterio | Estado en este buzón |
|---|---|
| En 365 debe ser **SharedMailbox** (sin licencia, hasta 50 GB) | ✅ Cumplido |
| Cuenta con **sign-in bloqueado / deshabilitada** (nadie inicia sesión "como el buzón") | ⚠️ Por confirmar |
| Sin **grupos heredados** de la cuenta original | ⚠️ Por revisar (*Member Of*) |
| Permisos *Full Access* a las personas que deben leerlo | Por confirmar |

**Lección del caso:** reutilizar la cuenta de una persona que se va como buzón
compartido (en vez de crear uno limpio) arrastra restos — nombre, grupos, posible login
activo. Funciona, pero conviene la higiene posterior de la tabla de arriba.

---

## Estado actual y siguiente paso

**Estado:** Resuelto. El buzón muestra `Nave 4 - Abrera` en 365.

**Higiene pendiente (opcional, no urgente):**
1. Deshabilitar la cuenta en AD (*Account → Account is disabled*) si aún tiene login activo.
2. Limpiar grupos heredados de "Miriam Juen Vega" en *Member Of*.
3. Confirmar `mailNickname = nave4.abrera` y los permisos *Full Access* del buzón.

---

## Cronología

| Fecha | Evento |
|---|---|
| 07-jul | Error de "write scope" al editar el buzón desde M365. |
| 07-jul | Diagnóstico: entorno híbrido + buzón montado sobre la cuenta antigua "Miriam Juen Vega". |
| 07-jul | Corrección en AD (`MEUAZDC011`): displayName `Nave 4 - Abrera`, alias `nave4.abrera`, objeto renombrado. |
| 07-jul | Sync forzado en `MEUAZAC011` (`Start-ADSyncSyncCycle -PolicyType Delta`). |
| 07-jul | Verificado en 365 (SharedMailbox, nombre correcto). **Caso cerrado.** |
