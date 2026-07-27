# Reporte del caso — Maswer / Correo no visible y que no abre en Outlook (buzón en la nube)

> **Guía reutilizable "cómo hacerlo tú solo":** este caso originó un runbook separado en `implement/runbook-correo-no-aparece-no-abre-outlook-exo.md` (modelo mental, comandos clave, diccionario de errores y checklist).

- **Cliente:** Maswer (Maswer Alemania)
- **Solicitante / usuario final:** Angelika Stangenberg (`AStangenberg`, `angelika.stangenberg@maswer.com`) — perfil de dirección (Vorstand/Aufsichtsrat), usuaria no técnica.
- **Canal:** Freshworks (portal), agente asignado en el hilo "Miguel Ángel Rubira García".
- **Técnico:** Sebastian Lazarte (CoolNetworks — IT de Maswer)
- **Fecha:** 23-jul-2026 (ticket abierto 21-jul-2026)
- **Estado actual:** RESUELTO PENDIENTE DE CONFIRMACIÓN — correo localizado y sano en el servidor, en la carpeta "Steuerberater" (donde la usuaria lo movió); el fallo es el caché local (OST) de su Outlook de escritorio. **Sin pérdida de datos y sin incidente de seguridad.**

---

## Triage del ticket

| Campo | Valor |
|---|---|
| Categoría | Software / Aplicaciones (cliente Outlook, buzón Exchange Online) |
| Prioridad | P3 - Media (un usuario, un elemento, existe workaround; no está bloqueada) |
| Grupo | N1 (resuelto en primer contacto) |
| SLA inicial | Respuesta en 4 h |
| Escalado | No. Solo habría pasado a N2 Ciberseguridad si hubiera aparecido una regla de bandeja que mueve/oculta/reenvía correo (no fue el caso) |

---

## Solicitud recibida

> "I moved an email from my Outlook Inbox to a subfolder named 'Tax Advisor,' but the email isn't visible there. So, I searched for the tax advisor's name from the Inbox. The email appeared in the search results, but when I try to open it, the following error message appears: **'Ein Clientvorgang ist fehlgeschlagen'** (a client operation failed)."

Datos aportados por la usuaria:
- Remitente: **Christina Tunc** (`Tunc@s-e-j.de`)
- Asunto contiene: **"Rückstellungen"** (provisiones contables)
- Enviado: 14-07 / 17-07-2026 (la usuaria dio ambas fechas; el correo real es del **17.07.2026**)
- Movido a la carpeta que ella llama "Tax Advisor"

---

## Cronología

| Fecha | Evento |
|---|---|
| 17-jul | Christina Tunc envía "Rückstellungen aktueller Stand" (con adjunto Excel) a Angelika. |
| ~20-jul | Angelika mueve el correo a su carpeta "Tax Advisor". Deja de verlo en su Outlook de escritorio. |
| 21-jul | Abre el ticket: no ve el correo; al buscarlo y abrirlo desde resultados, error `Ein Clientvorgang ist fehlgeschlagen`. |
| 22-jul | Aporta remitente, asunto y fecha. |
| 23-jul | Diagnóstico. La captura ya descartaba lo obvio: Outlook **conectado** ("Verbunden mit Microsoft Exchange") y carpeta "al día" ("auf dem neusten Stand") → servidor sano, sospecha de caché local. |
| 23-jul | Confirmado buzón en la nube (Exchange Online, datacenter EU); localizado el correo en OWA. |

---

## Trabajo realizado (resumen técnico)

1. **Buzón en la nube:** salió como `UserMailbox` en Exchange Online (`EURPR09A002.PROD.OUTLOOK.COM`). Se descartó el Exchange on-prem `MEUAZEX001`.
2. **Primer intento read-only** con `Get-MailboxFolderStatistics -FolderScope All`: existe la carpeta **`Steuerberater`** (`/Posteingang/Steuerberater`, 88 elementos) y dentro una subcarpeta **`Rückstellungen`** con 1 elemento.
   - ⚠️ **Falso positivo:** ese 1 elemento de la subcarpeta resultó ser un correo **distinto** — de **Stefanie Zimmermann (HR)**, "Rückstellungen / Kostenträgerauswertung", 07.05.2026. Mismo asunto, remitente y fecha distintos. Coincidió el número por casualidad. **No era el de Tunc.** (Lo delató la captura de OWA de la usuaria.)
3. **Content Search** (`from:"Tunc@s-e-j.de" AND subject:"Rückstellungen"`): `Status: Completed`, **`Items: 2`** → confirmó que hay **2 correos de Christina Tunc** en el buzón, en el servidor. (No dice carpeta.)
4. **Localización definitiva vía OWA** (FullAccess temporal + "Abrir otro buzón", `from:Tunc@s-e-j.de` en todas las carpetas). Los 2 correos están **ambos en la carpeta `Steuerberater`** (según la etiqueta de carpeta de cada resultado):
   - **"Rückstellungen aktueller Stand"** — 17.07, con adjunto Excel → **el que busca la usuaria**.
   - "Reporting 2025 sowie Rück..." — 22.05.2026 → el segundo hit, más antiguo.

---

## Causa raíz

El correo **estaba exactamente donde la usuaria lo movió**: la carpeta "Steuerberater" (su "Tax Advisor"), sano en el servidor. El problema es que **su Outlook de escritorio no lo mostraba por caché local (OST) desincronizado** — por eso "no aparece" y da `Ein Clientvorgang ist fehlgeschlagen` al intentar abrirlo desde resultados. En webmail (OWA) el correo se ve y abre sin problema. No hubo pérdida de correo ni problema de buzón.

---

## Estado final

**RESUELTO PENDIENTE DE CONFIRMACIÓN.** Correo localizado y sano en `Steuerberater`. **Sin pérdida de datos, sin brecha de seguridad, sin incumplimiento de SLA.** No se tocó nada en producción.

Resolución para la usuaria:
- **Inmediato:** puede abrir el correo ya desde webmail (`outlook.office.com` → carpeta Steuerberater).
- **Escritorio:** cerrar Outlook por completo, esperar ~30 s y reabrir (fuerza resync). Si persiste: vaciar elementos sin conexión de la carpeta o recrear el perfil de Outlook. Se coordina en su equipo, **sin sesión remota**.

Acceso administrativo usado y revertido:
- Se concedió **FullAccess** temporal al buzón (`Add-MailboxPermission ... -AutoMapping:$false`) para localizar el correo en OWA, justificado por el ticket, y **se retiró al terminar** (`Remove-MailboxPermission`).
- Queda pendiente borrar el objeto de Content Search "TuncRueckstellung" desde una sesión IPPS (`Remove-ComplianceSearch`) — limpieza menor, sin impacto.

**Acción de cierre pendiente:** confirmación de Angelika de que ve/abre el correo tras reiniciar Outlook.

---

## Respuesta enviada a la clienta (inglés — la usuaria escribe en inglés)

> Hi Angelika,
> Found it — your email from Christina Tunc ("Rückstellungen aktueller Stand", 17 July, with the Excel attachment) is safe in your "Steuerberater" (Tax Advisor) folder.
> You can open it right now from Outlook on the web: go to outlook.office.com, open the Steuerberater folder, and it's there.
> On your desktop Outlook it wasn't showing because it was out of sync. Please close Outlook completely, wait about 30 seconds, and open it again — the message will appear in Steuerberater. If it still doesn't, tell me and I'll refresh it for you.
> Best, CoolNetworks Support

---

## Notas para casos similares

- **El conteo de `Get-MailboxFolderStatistics` no identifica un mensaje.** Una subcarpeta con "1 elemento" y el mismo asunto puede ser un correo **distinto** (aquí, el de Stefanie Zimmermann). Verifica el mensaje real (OWA o preview), no asumas por el nombre/conteo de carpeta.
- **`Items: N` del Content Search confirma existencia, no ubicación.** Barre todo el buzón (incluye "elementos recuperables"). Para la carpeta, hace falta OWA o Preview/Export.
- **Cuidado con la sesión activa:** `Get-Mailbox` / `Add-MailboxPermission` / `Get-InboxRule` → Exchange Online. `New/Start/Get/Remove-ComplianceSearch` + `-Preview`/`-Export` → sesión IPPS (y Preview/Export **no** funcionan con `-EnableSearchOnlySession`). Cambiar de sesión hace "desaparecer" los cmdlets de la otra.
- **OWA tras conceder FullAccess:** `AccessDenied` inmediato = propagación (hasta ~60 min). Es timing, no un error de permisos; reintentar tras esperar y re-loguear.

---

**Referencias internas:** [[maswer-servers-inventory]] · [[maswer-ad-domain-infra]] · [[maswer-m365-backup]] · [[conet-de-administers-maswer-infra]] · [[no-remote-sessions-endusers]]
