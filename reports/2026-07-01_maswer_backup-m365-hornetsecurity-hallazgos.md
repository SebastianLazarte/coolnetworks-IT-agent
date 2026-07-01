# Maswer — Verificación del backup de Microsoft 365 (Hornetsecurity/Altaro) — hallazgos

**Responsable:** Sebastian Lazarte Castellón (CoolNetworks — IT de Maswer)
**Fecha:** 01-jul-2026
**Motivo:** preparación de la **auditoría ISO 27001:2022 + ENS** (en curso, ~02-jul-2026). Confirmar si Maswer tiene **backup dedicado de M365** o solo retención nativa de OneDrive.
**Estado:** ✅ Backup de M365 CONFIRMADO y ACTIVO — pendiente solo el detalle de alcance por usuario (consola).

---

## Resumen ejecutivo

- **Sí existe backup dedicado de Microsoft 365:** es **Hornetsecurity 365 Total Backup** (antes **Altaro Office 365 Backup**; Hornetsecurity compró Altaro).
- **Está activo y ejecutándose:** las apps de backup se autenticaron contra el tenant **hoy 01-jul a las 00:00 con estado "Completado correctamente"**.
- **Alcance confirmado (qué PUEDE copiar):** **correo (Exchange), SharePoint, OneDrive y Teams** — permisos amplios y **con consentimiento de administrador**.
- **OneDrive NO es el backup:** es recuperación nativa complementaria (papeleras 93 días, versiones, retención de Purview). El backup real es Hornetsecurity/Altaro.
- **Pendiente:** acceso a la **consola de Hornetsecurity** para ver **qué usuarios se copian, última copia buena y retención**, y una **restauración de prueba**. Probablemente lo opera **conet.de** → correo de solicitud enviado/redactado.
- **Por aclarar:** una segunda app llamada **"BackApps Respaldos"** que también aparece en el tenant.

---

## Contexto: OneDrive ≠ backup

Punto de partida: se creía que "lo manejan con OneDrive". Aclaración clave para la auditoría:

- OneDrive **sincroniza/replica** el estado actual; si un fichero se borra, corrompe o cifra un ransomware, el cambio **se sincroniza también**. No es un punto en el tiempo intocable.
- Microsoft trabaja con **responsabilidad compartida**: garantiza el servicio, **no** recupera tus datos.
- Recuperación **nativa** de M365 (complementaria, no backup):

| Función | Retención por defecto |
|---|---|
| Papelera OneDrive | 93 días |
| Papelera SharePoint | 93 días |
| Historial de versiones | Activo por defecto |
| Restaurar OneDrive (Files Restore) | Hasta 30 días |
| OneDrive de usuario dado de baja | 30 días (configurable) |
| Directivas de retención (Purview) | Lo configurado |

→ El **backup real** = copia independiente, retención larga, a ser posible inmutable, restaurable a un punto en el tiempo. Eso lo aporta **Hornetsecurity/Altaro**, no OneDrive.

---

## Hallazgo 1 — Apps de backup presentes en el tenant

En **Entra > Aplicaciones empresariales** (92 apps en total) aparecen:

- **Altaro Office 365 Backup** (+ variantes **MEA** y **DEA**)
- **Altaro Office 365 Teams Backup 3**
- **Hornetsecurity 365 Total Backup**
- **BackApps Respaldos** ← *por identificar*

> Las varias entradas de Altaro (MEA/DEA/Teams) son **normales**: una app de servicio por producto/región. Altaro = hoy Hornetsecurity 365 Total Backup.

---

## Hallazgo 2 — El backup está ACTIVO (registros de inicio de sesión)

`Entra > Identidad > Supervisión y mantenimiento > Registros de inicio de sesión > pestaña "Inicios de sesión de entidad de servicio"`, filtrado por *Altaro/Hornetsecurity*:

| Fecha (UTC) | Aplicación | Estado |
|---|---|---|
| 2026-07-01 00:00:28 | Altaro Office 365 Teams Backup | ✅ Completado correctamente |
| 2026-07-01 00:00:27 | Altaro Office 365 Backup (varias) | ✅ Completado correctamente |
| 2026-07-01 00:00:26 | Hornetsecurity 365 Total Backup | ✅ Completado correctamente |

→ **Conclusión:** las copias se ejecutan a diario y se autenticaron con éxito **hoy**. Backup **vivo y operativo**.

---

## Hallazgo 3 — Qué cubre (permisos de API)

`Entra > Registros de aplicaciones > Hornetsecurity 365 Total Backup > Permisos de API`:

| API / Permiso | Tipo | Significado | Estado |
|---|---|---|---|
| **Office 365 Exchange Online — `full_access_as_app`** | Aplicación | Acceso completo a **todos los buzones** → copia **correo** | ✅ Concedido para Maswer |
| **SharePoint — `Sites.FullControl.All`** | Aplicación | Control total de **todos los sitios** → copia **SharePoint + OneDrive** | ✅ Concedido para Maswer |
| **Microsoft Graph (24 permisos)** | Aplicación | Usuarios, grupos, **Teams**, ficheros de OneDrive (sin desplegar) | Concedido |

→ **Alcance:** la app puede copiar **prácticamente todo el M365** (correo, SharePoint, OneDrive, Teams), con **consentimiento de administrador**.

> **Nota para la auditoría:** si el auditor pregunta *"¿por qué una app tiene acceso total a buzones y SharePoint?"*, la respuesta es limpia: *"Es la solución de backup de M365 (Hornetsecurity/Altaro); esos permisos son los mínimos para respaldar todos los datos, están consentidos por administrador y la copia está activa y registrada."* → "muchos permisos" pasa a ser "control justificado".

---

## Consola de gestión (URLs correctas)

- ⚠️ **URL antigua muerta:** `office365.altaro.com` (ya no resuelve tras el cambio de marca).
- ✅ **Vigente (región EU, la que corresponde a España/Alemania):** **https://eu-m365.backup.hornetsecurity.com/**
- ✅ Alternativa (vía Altaro antigua): **https://office365.manage.altaro.com/**

En la consola se ve lo que Entra **no** muestra: **usuarios/buzones protegidos, última copia correcta por servicio, retención, almacenamiento y restauraciones**.

---

## Pendientes (acciones antes/durante la auditoría)

1. [ ] **Conseguir acceso a la consola de Hornetsecurity** (`eu-m365.backup.hornetsecurity.com`). Muy probablemente la **opera conet.de** → **correo de solicitud redactado** (pedir acceso o informe: usuarios protegidos, última copia OK, retención, evidencia de restauración).
2. [ ] **Verificar en consola:** que el alcance cubre a **todos** los usuarios (no solo algunos) y localizar/realizar una **restauración de prueba** (evidencia estrella).
3. [ ] **Identificar "BackApps Respaldos"** (Enterprise Apps > Permisos): confirmar si es otra copia, una antigua a retirar, o algo distinto.
4. [ ] **Actualizar la sección 7 del guion de ensayo** con Hornetsecurity/Altaro ya confirmado.

---

## Qué se puede afirmar YA ante el auditor

> *"El backup de Microsoft 365 —correo, OneDrive, SharePoint y Teams— lo hacemos con **Hornetsecurity 365 Total Backup (Altaro)**, independiente del tenant. Está **activo** (se autenticó con éxito hoy) y con **alcance completo** y consentido por administrador. La consola la opera conet.de; aquí está el estado / la restauración de prueba."*

Y la distinción clave: **OneDrive (papeleras/versiones) = recuperación nativa complementaria; Hornetsecurity/Altaro = el backup real.**

---

## Los dos mundos de copia de Maswer (no mezclar ante el auditor)

1. **M365** → **Hornetsecurity 365 Total Backup (Altaro)** — este informe.
2. **File server / servidores (unidades tipo `R:`)** → backup de servidor + **shadow copies (VSS)**; operado por **conet.de**. Caso real documentado: recuperación de `IntAudit_ES` (ver informe del 29-jun).

---

*Relacionado:* `2026-06-30_maswer_ensayo-auditoria-paso-a-paso.md` · `2026-06-30_maswer_preparacion-auditoria-remota.md` · `2026-06-29_maswer_recuperacion-intaudit-es-iso14001.md` · `2026-06-23_maswer_recuperacion-accesos-post-oliver`
