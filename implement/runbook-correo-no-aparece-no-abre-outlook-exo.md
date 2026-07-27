# Runbook — Correo que no aparece o no se abre en Outlook (buzón en la nube, Exchange Online)

> **Qué es esto:** guía reutilizable para resolver tú solo, casi en automático, los tickets del tipo "un correo no aparece / no se abre en Outlook". Nace del caso Maswer / Angelika Stangenberg del 23-jul-2026 (ver reporte del caso en `reports/drafts/2026-07-23_maswer_correo-no-abre-outlook-cache-ost.md`). Explica **qué significa cada paso y por qué**, no solo los comandos.

---

## 1. El modelo mental (lo que de verdad hay que entender)

**Outlook trabaja con dos copias del mismo buzón:**
- La **copia del servidor** (la buena, la de referencia): hoy, para casi todos los usuarios de Maswer, está en **Exchange Online (la nube de Microsoft)**.
- La **copia local (fichero OST)** en el PC del usuario: una caché para trabajar rápido y offline.

El 90% de estos casos ("desapareció", "no abre", "va raro pero solo en mi Outlook") son **la copia local desincronizada o corrupta, con la copia del servidor perfectamente sana**. Por eso la regla de oro es:

> **Primero mira el servidor en modo lectura. No toques el PC del usuario ni pidas accesos hasta saber si el correo existe y está sano en el servidor.**

Si el servidor está bien → el problema es el cliente (caché) → arreglo local sencillo. Si el servidor NO tiene el correo → recuperación (papelera/backup) o, si hay una regla rara, seguridad.

## 2. Exchange híbrido de Maswer: dónde vive el buzón y qué permisos mandan

Maswer es **híbrido**: el AD on-prem (`MDERZADC003/004`) es el master de identidad y sincroniza a Entra vía `MEUAZAC011`. Pero **los buzones de usuario ya viven en la nube (Exchange Online)**, no en el Exchange on-prem `MEUAZEX001`.

Cómo saber dónde está un buzón — mira `RecipientTypeDetails`:
- **`UserMailbox`** → buzón **en la nube**. Trabajas desde Exchange Online.
- **`RemoteUserMailbox`** (visto desde on-prem) → también en la nube; el on-prem solo guarda el "puntero" híbrido.

Dos trampas de permisos, importantes:
- **Ser admin local del servidor `MEUAZEX001` NO es tener permisos de Exchange.** Exchange tiene su propio sistema de roles (RBAC). Por eso `Connect-ExchangeServer -auto` puede dar *"isn't assigned to any management roles"*.
- **El RBAC on-prem y el de Exchange Online son separados.** Tu cuenta puede no tener rol on-prem pero **sí** en la nube. Como el buzón está en la nube, ese es el camino correcto de todas formas.

Regla práctica: **para buzones de usuario, ve directo a Exchange Online.** Solo bajas a `MEUAZEX001` si un buzón sale realmente como on-prem.

## 3. El caché local (OST) y el error `Ein Clientvorgang ist fehlgeschlagen`

`Ein Clientvorgang ist fehlgeschlagen` = *"a client operation failed"*. La palabra clave es **client**: el fallo es en el cliente Outlook (su caché local), no en el servidor. Se confirma cuando:
- Outlook está conectado ("Verbunden mit Microsoft Exchange") y la carpeta dice estar al día ("auf dem neusten Stand"), **pero** un elemento concreto no se ve o no abre.
- La copia del servidor existe y está sana (lo verificas tú, ver comandos).

Otra causa de "no lo veo en la carpeta": el correo está en una **subcarpeta** un nivel más abajo (la `FolderPath` lo delata), no suelto en la carpeta padre.

Arreglos del lado del cliente, de menos a más agresivo:
1. **Cerrar y reabrir Outlook** (a veces basta: fuerza resync).
2. **Vaciar elementos sin conexión** de la carpeta: clic derecho en la carpeta → Propiedades → "Vaciar elementos sin conexión" (Clear Offline Items). Re-descarga solo esa carpeta.
3. **Recrear el perfil de Outlook**: Panel de control → Correo → Mostrar perfiles → Agregar. Descarga limpia de todo el buzón. ⚠️ Hazlo a final de jornada, no a media mañana. Sin sesión remota a usuarios finales → se coordina en su equipo.

## 4. Flujo de diagnóstico (árbol de decisión)

```
1. Leer la captura del usuario → ¿Outlook conectado? ¿carpeta "al día"?
   Sí → sospecha de caché local, NO de servidor.

2. ¿Dónde vive el buzón? (Exchange Online casi siempre)
   Connect-ExchangeOnline → Get-Mailbox → RecipientTypeDetails = UserMailbox

3. ¿Existe el correo en el SERVIDOR? (read-only, sin abrir su correo)
   Get-MailboxFolderStatistics -FolderScope All  → ¿carpeta y nº de elementos?
   ├─ Carpeta con ItemsInFolder ≥ 1  → SERVIDOR SANO → problema de caché (paso 5a)
   └─ 0 elementos / no existe         → el correo no está ahí (paso 5b)

4. (Opcional) Confirmar el mensaje exacto → Content Search (Items ≥ 1)

5a. SERVIDOR SANO → arreglo en el cliente (cerrar/reabrir → clear offline items → perfil)
5b. NO ESTÁ      → Papelera / Elementos recuperables + Get-InboxRule
                   ⚠️ regla que mueve/oculta/reenvía → PARAR, escalar N2 Ciberseguridad
                   si nada lo recupera → restore desde Hornetsecurity 365 Total Backup
```

## 5. Comandos clave (con qué hace cada uno y cómo leer el resultado)

**Conectar a Exchange Online:**
```powershell
Connect-ExchangeOnline -UserPrincipalName IT-Support-Germany@maswer.com
```

**Encontrar el buzón real** (un nombre "a secas" falla; el identificador debe ser UPN, SMTP, alias o GUID):
```powershell
Get-Mailbox -Filter "DisplayName -like '*Apellido*'" | ft DisplayName,PrimarySmtpAddress,Alias,RecipientTypeDetails
```
→ Te da la dirección y el alias reales. `UserMailbox` = está en la nube.

**★ El comando estrella — ¿existe el correo en el servidor?** (read-only, lee del almacén del buzón, **no** de un índice, y **no** accede al contenido del correo):
```powershell
Get-MailboxFolderStatistics <smtp> -FolderScope All |
  ? Name -match "Tax|Steuer|Rückstell" | ft Name,FolderPath,ItemsInFolder,FolderSize
```
→ Te dice qué carpetas existen, su **ruta completa** (delata subcarpetas) y **cuántos elementos** tiene cada una. Con esto solo, ya sabes si el correo está a salvo, sin pedir accesos ni abrir su buzón.

**(Opcional) Confirmar el mensaje exacto — Content Search.** Necesita una **sesión de solo-búsqueda** (módulo ExchangeOnlineManagement v3.9.0+) y corre en **asíncrono**. Ojo: barre **todo el buzón**, así que puede devolver **más de 1** si hay copias en otras carpetas (original + copia movida, etc.):
```powershell
Disconnect-ExchangeOnline -Confirm:$false
Connect-IPPSSession -UserPrincipalName IT-Support-Germany@maswer.com -EnableSearchOnlySession
New-ComplianceSearch -Name "MiBusqueda" -ExchangeLocation <smtp> `
  -ContentMatchQuery 'from:"remitente@dominio" AND subject:"Asunto"'
Start-ComplianceSearch -Identity "MiBusqueda"
# repetir hasta que Status = Completed; solo entonces Items es válido:
Get-ComplianceSearch -Identity "MiBusqueda" | fl Status,Items
Remove-ComplianceSearch -Identity "MiBusqueda" -Confirm:$false   # limpieza
```

**(Solo si necesitas verlo con tus ojos) — acceso auditado al buzón + OWA.** Última opción, porque es acceso registrado a un buzón (más sensible aún en perfiles de dirección):
```powershell
Add-MailboxPermission -Identity <smtp> -User IT-Support-Germany@maswer.com -AccessRights FullAccess -AutoMapping:$false
# abrir https://outlook.office.com/mail/<smtp>/
Remove-MailboxPermission -Identity <smtp> -User IT-Support-Germany@maswer.com -AccessRights FullAccess -Confirm:$false
```

**(Rama de recuperación, si el correo NO estuviera) — reglas de bandeja:**
```powershell
Get-InboxRule -Mailbox <smtp>
```
⚠️ Si hay una regla que mueve/oculta/reenvía correo (sobre todo a un externo) → **no es un fallo de cliente. Para y escala a N2 Ciberseguridad.**

## 6. Los errores típicos y qué significan (diccionario)

| Error | Qué significa | Qué hacer |
|---|---|---|
| `Get-Mailbox is not recognized` (en el servidor on-prem) | Abriste una PowerShell normal; los cmdlets de Exchange no están cargados | Abre **Exchange Management Shell**, o `. $env:ExchangeInstallPath\bin\RemoteExchange.ps1` + `Connect-ExchangeServer -auto` |
| `The user ... isn't assigned to any management roles` | Ser admin local ≠ tener rol RBAC de Exchange | Ve a **Exchange Online** (tu rol cloud sí vale). Si de verdad hiciera falta on-prem, que **conet.de** te añada a un role group |
| `object 'x' couldn't be found on ...PROD.OUTLOOK.COM` | El identificador es incorrecto (nombre "a secas"); además confirma que el buzón está **en la nube** | Usa `-Filter "DisplayName -like '*apellido*'"` para sacar la SMTP/alias reales |
| `Please close ... -EnableSearchOnlySession` | La sesión IPPS no está en modo solo-búsqueda | Reconecta con `Connect-IPPSSession -EnableSearchOnlySession` (módulo v3.9.0+) |
| `Status : Starting` / `Items : 0` | La búsqueda **sigue corriendo**; ese 0 no es un resultado real | Espera y repite `Get-ComplianceSearch` hasta `Status : Completed`; solo entonces lee `Items` |

## 7. Las alertas de conet.de: transparencia, no evasión

conet.de administra la infra de Maswer y **monitoriza**. Tu trabajo administrativo legítimo (reiniciar ADSync, conectar a Exchange, acceder a un buzón) puede **disparar alertas** — como el aviso benigno "Entra Connect Sync tampering" al reiniciar ADSync en `MEUAZAC011`.

Regla de conducta:
- **La alerta no es una señal de parar, y NO se trata de buscar cómo esquivarla.** Tú eres el IT responsable; esa actividad es tuya y legítima. Intentar que "no salte" es justo lo que parece sospechoso.
- **Lo correcto es avisar a conet.de** (Kevin Pütz-Kurth): qué cuenta, qué acción, cuándo y por qué (nº de ticket), para que correlacionen la alerta y no persigan un falso positivo.
- **Deja constancia en el ticket** cuando accedas a un buzón (justificación registrada), y **retira el permiso al terminar**.

## 8. TL;DR — checklist casi automático

1. **Lee la captura.** ¿Outlook conectado + carpeta al día pero un correo no aparece/no abre? → sospecha caché local, no servidor.
2. **`Connect-ExchangeOnline`** → `Get-Mailbox -Filter "DisplayName -like '*apellido*'"` → saca SMTP/alias; `UserMailbox` = nube.
3. **`Get-MailboxFolderStatistics ... -FolderScope All`** → ¿la carpeta existe y tiene el elemento? (read-only, sin abrir su correo).
   - **Sí (≥1)** → servidor sano → arreglo en el cliente: cerrar/reabrir Outlook → vaciar elementos sin conexión → recrear perfil. Fin.
   - **No (0)** → Papelera/Elementos recuperables + `Get-InboxRule` → regla rara = **N2 Ciberseguridad**; nada recupera = restore desde Hornetsecurity.
4. **Ojo a los identificadores** (usa SMTP/alias, no el nombre suelto) y **al modo de sesión** de Content Search (`-EnableSearchOnlySession`, esperar `Completed`; puede devolver >1 copia).
5. **Respuesta al usuario** en su idioma, sin jerga, directa. Dile **dónde está** el correo (ruta/subcarpeta) y **el arreglo simple** primero.
6. **conet.de:** si tu acción dispara alerta, avísales; no la esquives.

---

**Referencias internas:** [[maswer-servers-inventory]] · [[maswer-ad-domain-infra]] · [[maswer-m365-backup]] · [[adsync-restart-triggers-defender-alert]] · [[conet-de-administers-maswer-infra]] · [[no-remote-sessions-endusers]] · [[prefer-admin-self-test]]
