---
name: maswer-m365-backup
description: "El backup de M365 de Maswer es Hornetsecurity 365 Total Backup (ex-Altaro); activo y con alcance total, pero la URL de consola y quién la opera siguen SIN confirmar"
metadata:
  type: reference
---

El backup de Microsoft 365 de Maswer (correo/Exchange, OneDrive, SharePoint, Teams) se hace con
**Hornetsecurity 365 Total Backup** (antes **Altaro Office 365 Backup** — Hornetsecurity compró
Altaro).

- **Confirmado activo:** los service principals del backup se autentican contra el tenant a
  diario y tuvieron éxito el 2026-07-01. En Entra → Enterprise Applications aparecen como
  *Altaro Office 365 Backup* (+ MEA/DEA), *Altaro Office 365 Teams Backup*,
  *Hornetsecurity 365 Total Backup*.
- **Permisos concedidos** (con consentimiento de admin): Exchange `full_access_as_app` (todos
  los buzones), SharePoint `Sites.FullControl.All`, Microsoft Graph (24) — el alcance cubre
  esencialmente todos los datos de M365.
- ⚠️ **URL de la consola NO confirmada.** El fabricante tiene varios portales (el viejo
  `office365.altaro.com` está muerto; opciones genéricas vistas online:
  `office365.manage.altaro.com`, `eu-m365.backup.hornetsecurity.com`) pero ninguna verificada
  como la de Maswer. Hay que preguntarle al operador la URL real — no inventarla
  ([[dont-invent-portal-navigation]]).
- ⚠️ **Quién opera la consola y tiene las credenciales sigue SIN confirmar** — no dar por hecho
  que es conet. El 2026-07-01 se mandó correo a conet preguntando si la gestionan ellos y
  pidiendo URL y credenciales; pendiente de respuesta.
- Las papeleras nativas de OneDrive/SharePoint (93 días) + el versionado son recuperación
  **complementaria**, NO el backup.
- Sin identificar: una segunda app conectada en el tenant, "BackApps Respaldos".

**How to apply:** antes de borrar nada en una baja, **verificar qué retiene de verdad este
backup** — es el paso que sostiene la política de [[leaver-accounts-disable-not-delete]].
Oliver Orth también tenía acceso a esta consola → [[oliver-orth-admin-accounts-still-enabled]].
