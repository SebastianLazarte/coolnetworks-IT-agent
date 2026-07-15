# Runbook — Instalación estándar de STAkis en endpoints Maswer

- **Cliente:** Maswer AG (dominio `intern.maswer.com`, NetBIOS **MASWER**)
- **Responsable:** Sebastian Lazarte Castellón (CoolNetworks — IT de Maswer)
- **Fecha:** 14-jul-2026
- **Software:** STAkis Profi (STAHLGRUBER) — cliente de red `KWB_STAKIS_NET_CLIENT.EXE`, ya provisionado en la unidad de red
- **Objetivo:** un procedimiento **repetible** para instalar STAkis en cualquier máquina Maswer, en vez de resolverlo caso a caso
- **Primera ejecución (piloto):** máquina de Vincenzo Valle → [2026-06-23_stakis-access-install.md](2026-06-23_stakis-access-install.md)

---

## Lo primero, en claro

STAkis no falta ni le falta licencia: el ejecutable `KWB_STAKIS_NET_CLIENT.EXE` ya
está en la unidad de red. **El único bloqueo es la elevación (UAC):** al ejecutarlo,
Windows pide una cuenta de administrador local porque el editor es desconocido
(`Herausgeber: Unbekannt`).

Por eso este runbook **no es "cómo instalar STAkis" sino "con qué cuenta admin elevar
en la máquina del usuario"**. Sin una cuenta admin operativa en ese endpoint, el
runbook no se puede ejecutar (ver [Prerrequisito bloqueante](#prerrequisito-bloqueante)).
Instalar STAkis en la propia máquina del técnico no sirve: la instalación es por
equipo/usuario.

---

## Prerrequisitos

| # | Prerrequisito | Detalle |
|---|---|---|
| 1 | **Cuenta admin operativa en el endpoint destino** | La que resulte de la Fase 0. `MASWER\localadmin` **NO** vale (error 1385 — ni figura en Administradores local). |
| 2 | **Ruta del binario** | `KWB_STAKIS_NET_CLIENT.EXE` en la unidad de red de Maswer (origen: `Netzwerklaufwerk`). |
| 3 | **Acceso a la máquina** | Consola física, o herramienta remota que **muestre el secure desktop del UAC** (host instalado como servicio). Ojo: TeamViewer a veces corta (detección de uso comercial) → fallback AnyDesk. Ver agenda conet, punto 2 → [2026-07-03_agenda-reunion-conet.md](../Implement/2026-07-03_maswer_agenda-reunion-conet.md). |
| 4 | **Switch silencioso (opcional)** | Si la Fase 0 lo identifica, para instalación desatendida. |

---

## Fase 0 — Verificación: ¿qué cuenta admin uso? (se hace UNA vez)

Esta fase fija la **cuenta admin estándar** del runbook y responde de una vez
"¿tengo una cuenta que funcione?". Todo se hace sin depender de conet.

### 0.1 — Buscar credenciales de `MASWER\admin`
`MASWER\admin` aparece como admin en la propia máquina del técnico → es el candidato
a "cuenta de dominio para elevar" que no se pasó en la transición de Oliver. Buscar su
contraseña en:
- La **KeePass compartida** → [2026-07-13_maswer_keepass-recuperacion-bd-compartida.md](2026-07-13_maswer_keepass-recuperacion-bd-compartida.md).
- El gestor de contraseñas personal / notas de la transición.

### 0.2 — Probar la elevación en un endpoint ajeno
En una máquina que **no** sea la del técnico (equipo de prueba, o el de Vincenzo con
ventana acordada):

```powershell
# ¿Quién es admin local en ESTA máquina?  (SID S-1-5-32-544 = Administradores)
Get-LocalGroupMember -SID S-1-5-32-544
```

Después, intentar elevar el UAC con `MASWER\admin`. Descartar de nuevo
`MASWER\localadmin` (dará 1385).

### 0.3 — Identificar el modo de instalación del binario (en la máquina propia del técnico)
Donde el técnico SÍ es admin y sin tocar la máquina de nadie:

```powershell
# Nivel de ejecución que pide el ejecutable (requireAdministrator / highestAvailable / asInvoker)
sigcheck -m .\KWB_STAKIS_NET_CLIENT.EXE
```

- Instalarlo con **Process Monitor** abierto y ver dónde escribe: solo
  `%LOCALAPPDATA%` / `HKCU` = per-user; `Program Files` / `HKLM` = necesita admin.
- Anotar los switches silenciosos según el tipo de instalador.
- Fallback si no queda claro: preguntar al fabricante `stakis.support@stahlgruber.de`.

### Resultado de la Fase 0
- **`MASWER\admin` (u otra cuenta del técnico) eleva en máquinas ajenas** → esa es la
  **cuenta admin estándar**. Seguir a la [Fase 1](#fase-1--procedimiento-de-instalación). **No hace falta conet.**
- **Ninguna cuenta funciona** → ver [Prerrequisito bloqueante](#prerrequisito-bloqueante).

---

## Fase 1 — Procedimiento de instalación

Repetible en cualquier endpoint Maswer, una vez fijada la cuenta admin estándar.

1. **Acceder** a la máquina del usuario (consola o remoto con secure desktop del UAC).
2. **Ejecutar** `KWB_STAKIS_NET_CLIENT.EXE` desde la unidad de red y, cuando salte el
   UAC, elevar con la **cuenta admin estándar** (Fase 0). Si hay switch silencioso,
   lanzarlo desde una consola ya elevada con esa cuenta.
3. **Verificar** que STAkis **arranca e inicia sesión** correctamente.
4. **Confirmar al usuario** que ya lo tiene y **registrar** el cierre en el caso del ticket.

---

## Fase 2 — Repetibilidad

- **Guardar la cuenta admin estándar en la KeePass compartida** (nombre, para qué se
  usa) para que el procedimiento lo pueda ejecutar cualquiera del equipo, no solo
  quien lo descubrió.
- **Enlazar este runbook** desde cada caso de STAkis nuevo en vez de rehacer el
  diagnóstico. El primer caso es Vincenzo (piloto).

---

## Prerrequisito bloqueante

Si la Fase 0 **no** encuentra ninguna cuenta admin operativa en las máquinas ajenas,
**este runbook no se puede ejecutar** hasta que se provisione ese acceso. No hay
atajo: sin admin local en el endpoint no se eleva el UAC, y `localadmin` no sirve.

En ese caso la vía es **conet.de** (administra la infra de Maswer): pedir la cuenta
admin de dominio operativa (o que configuren el acceso del técnico). **No hay que
redactar nada nuevo** — ya está preparado:
- Correo listo para enviar a Kevin Pütz-Kurth → [2026-06-23_maswer_recuperacion-accesos-post-oliver.md](../Implement/2026-06-23_maswer_recuperacion-accesos-post-oliver.md)
- Agenda de la reunión (punto 1: elevación/admin) → [2026-07-03_maswer_agenda-reunion-conet.md](../Implement/2026-07-03_maswer_agenda-reunion-conet.md)

Prohibido como atajo: compartir la contraseña de `localadmin` con el usuario
(incidente de seguridad ya documentado) o desactivar el UAC.

---

## Anexo — Conceder admin local (procedimiento probado en sesión)

Alternativa al "teclear la credencial en cada instalación": dejar admin local a la
cuenta correcta **una vez**, y a partir de ahí el UAC de STAkis es un simple Sí/No.
Todo se corre en la sesión remota del equipo destino.

1. **Nombre exacto de la cuenta** del usuario (en su sesión): `whoami` → devuelve `maswer\<usuario>`.
2. **Abrir un shell admin** con `runas` (aquí se teclea la contraseña de `MASWER\admin`, la mete el técnico, no el usuario):
   ```
   runas /user:MASWER\admin powershell
   ```
3. **Añadir al grupo Administradores local** (SID `S-1-5-32-544`, a prueba de idioma del Windows):
   ```powershell
   Add-LocalGroupMember -SID S-1-5-32-544 -Member "MASWER\<usuario>"
   Get-LocalGroupMember  -SID S-1-5-32-544   # verificar
   ```
4. **El usuario cierra sesión y vuelve a entrar** (imprescindible: el token de admin no aplica hasta el nuevo logon).
5. Ejecutar `KWB_STAKIS_NET_CLIENT.EXE` → el UAC pide solo **Sí/No**; si la pantalla se pone negra en remoto, **el usuario pulsa "Ja" en su máquina** (sin claves).

> ⚠️ Seguridad: hacer admin permanente a un **usuario final** no encaja con el modelo
> por tiers de Maswer (los equipos se meten al grupo `adm2`, no usuarios sueltos). Como
> apaño puntual sirve; lo limpio es que **conet** añada el **grupo** admin por GPO. Si se
> usa como apaño, valorar revertirlo después (`Remove-LocalGroupMember`).

---

## Estado

**Sesión piloto ejecutada el 14-jul-2026 sobre la máquina de Vincenzo (`MDEHEFCLI016`,
vía TeamViewer). NO cerrada — la sesión remota terminó sin completar la instalación.**

Confirmado en vivo:
- **Vincenzo es usuario estándar**, no admin local: al intentar elevar, el UAC pide
  *usuario y contraseña*, no un simple Sí/No.
- STAkis está en `\\MDEKASCLI003\STAkis_Profi` (unidad `S:`); es una **app Visual FoxPro 9
  de red** (`vfp9*.dll`, `.dbf`, `vrunfox.exe`), pero `KWB_STAKIS_NET_CLIENT.EXE`
  **exige elevación** → no hay arranque per-user sin admin.
- Con QuickSupport **sin elevar**, el UAC sale en el secure desktop y **"bota" la
  conexión** (pantalla negra). No se puede elevar QuickSupport porque Vincenzo (usuario
  estándar) necesitaría a su vez la contraseña admin.
- `MASWER\localadmin` sigue descartada (error 1385).

**Método correcto (ver Hallazgo clave abajo):** en el UAC, el técnico teclea **su propia
cuenta** `MASWER\IT-Support-Germany` + su contraseña. Está en `adm2-Administrators` (tier
de workstations) → debería elevar. Ya NO se usa `localadmin` (1385) ni se depende de
`MASWER\admin` ni de conet.

*(Nota: durante la sesión no se llegó a completar porque se probaron cuentas equivocadas
—`localadmin`— y hubo problemas de secure desktop con QuickSupport sin elevar; la cuenta
propia del técnico nunca se probó.)*

### HALLAZGO CLAVE (14-jul-2026, verificado en vivo contra el DC `MUSAZDC011`)
La conclusión previa ("el técnico no tiene admin → conet") era **FALSA**. Comprobado con
comandos en la máquina del técnico:
- **La cuenta del técnico `MASWER\IT-Support-Germany` ES miembro de `adm2-Administrators`**
  (tier de administradores de **workstations**) y de `adm1-Administrators` (servidores):
  ```
  adm2-Administrators → Admin2_AJasso, Admin2_MRGarcia, Admin2_OOrth, IT-Support-Germany
  adm1-Administrators → adm1_conet, Admin1_OOrth, Administrator1_OOrth, IT-Support-Germany
  ```
- En la propia máquina del técnico, el grupo Administradores local incluye
  `MASWER\IT-Support-Germany`, `MASWER\Domain Admins` y `MASWER\admin`.
- El DC responde → el técnico **está en la red**. Lo de `MDEHEFCLI016` inalcanzable fue
  solo ruta/sitio a esa workstation concreta, no falta de conectividad al dominio.

**Consecuencia:** para elevar en un endpoint, el técnico debe usar **SU PROPIA cuenta**
`MASWER\IT-Support-Germany` + su contraseña — **no** `localadmin` (1385, cuenta equivocada)
ni `MASWER\admin`. Nunca se probó la cuenta propia; ese fue el error real.

### Método correcto (probar en la próxima sesión)
En el UAC de la máquina del usuario, teclear:
- **Usuario:** `MASWER\IT-Support-Germany`
- **Contraseña:** la del propio técnico.

Si eleva → instalar STAkis y cerrar, **sin conet, sin cuenta compartida, sin cuenta master**.

**Único caveat:** funciona si esa workstation incluye `adm2-Administrators` (o Domain
Admins) en su grupo Administradores local — que es la razón de ser del tier. Se confirma
literalmente al teclear la cuenta. Si diera *acceso denegado*, ese equipo no honra el tier
→ entonces sí conet (añadir `adm2-Administrators` a los Administradores local por GPO,
arreglando `CN=Computers`). Descartado crear cuenta "master" compartida (duplica el riesgo
`localadmin`, hallazgo de auditoría).
