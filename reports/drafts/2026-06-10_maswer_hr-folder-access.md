# Reporte del caso — Maswer / Acceso a carpeta HR

- **Cliente:** Maswer (Maswer Alemania)
- **Solicitante:** Vincenzo Valle (vía portal)
- **Usuarios finales:** Vincenzo Valle, Angelika Stangenberg (angelika.stangenberg@maswer.com)
- **Técnico asignado:** Sebastian Lazarte Castellón (CoolNetworks)
- **Fecha de apertura:** 10-jun-2026
- **Fecha de cierre:** 11-jun-2026
- **Estado actual:** RESUELTO — ambos usuarios confirman acceso; ticket cerrado

---

## Triage del ticket

| Campo | Valor |
|---|---|
| Categoría | Cuentas y Acceso (permisos de carpeta) |
| Prioridad | P4 - Baja (solicitud de acceso no bloqueante) |
| Grupo | N1 configuración de cliente; N2 Systems si requiere acceso admin al servidor |
| SLA inicial | Respuesta en 1 día hábil |
| Escalado | No escalado finalmente — el acceso se confirmó antes de derivar a conet (admin externo de la infra) |

---

## Solicitud recibida

> "Please grant Ms. Stangenberg and me access to the HR folder."

Solicitud de acceso a la carpeta HR para dos usuarios. Ubicación de la carpeta, nivel de acceso y autorización no especificados en el mensaje inicial.

---

## Cronología

| Fecha | Evento |
|---|---|
| 10-jun | Ticket recibido vía portal: solicitud de acceso a la carpeta HR para Vincenzo Valle y Angelika Stangenberg. |
| 10-jun | Triage: Cuentas y Acceso, P4. Identificada la carpeta HR como contenido sensible → requiere verificar autorización antes de conceder. |
| 10-jun | Localización del control de permisos en el file server: pestaña **Effective Access** (Propiedades → Seguridad → Opciones avanzadas → Acceso efectivo), que muestra check verde / cruz roja por tipo de permiso. |
| 10-jun | Incidencia: pestaña **Seguridad** no visible. Causa probable identificada — acceso vía ruta UNC/unidad mapeada en lugar de ruta local, o "Asistente para compartir" activo. |
| 10-jun | Permisos concedidos sobre la carpeta HR para ambos usuarios. |
| 10-jun | Redactado mensaje de confirmación al solicitante (inglés). Pendiente confirmación de acceso por los usuarios. |
| 11-jun | Usuarios añadidos vía AD; tras logoff/login seguían sin acceso. Intento de verificar la ACL desde la pestaña Seguridad: **no accesible** desde la cuenta N1 (herencia desactivada, propietario Oliver Orth). Identificado que la infra de Maswer la administra **conet.de** (empresa externa, cuenta `conetadmin`), no CoolNetworks. |
| 11-jun | Antes de escalar a conet, **Angelika confirma que ambos ya tienen acceso** a la carpeta HR y pide cerrar el ticket. |
| 11-jun | Enviado mensaje de cierre. Ticket cerrado. |

---

## Trabajo realizado

### Diagnóstico técnico
- Identificado el control de verificación de permisos en Windows Server: pestaña **Effective Access** (Propiedades → Seguridad → Opciones avanzadas → Acceso efectivo). Muestra check verde / cruz roja por usuario combinando permisos directos y pertenencia a grupos.
- Resuelta la falta de la pestaña **Seguridad**: navegar la **ruta local** del servidor (no `\\servidor\recurso`) y/o desactivar "Usar el Asistente para compartir" en Opciones de carpeta → Ver.

### Concesión de permisos
- Permisos NTFS concedidos sobre la carpeta HR para Vincenzo Valle y Angelika Stangenberg.

### Comunicación con cliente
- Redactado mensaje "listo para verificar" (inglés) con instrucciones de acceso: abrir Explorador → pegar la ruta del recurso compartido → cerrar y volver a iniciar sesión si estaban logueados durante el cambio (el token de seguridad se construye en el inicio de sesión).

### Decisiones de triage
- Categoría: Cuentas y Acceso. Prioridad: P4. Grupo: N1.

---

## Estado final

**Estado:** RESUELTO — Angelika Stangenberg confirmó (11-jun, 11:12) que ella y Vincenzo Valle tienen acceso a la carpeta HR. Ticket cerrado.

**Causa raíz: no confirmada.** No se verificó *qué* destrabó finalmente el acceso — pudo ser la propagación tardía del cambio en AD, o que una cuenta con permiso sobre la ACL (conet / Oliver) lo aplicara por su lado. Se cierra por confirmación del cliente, no por causa raíz verificada.

**Lecciones / notas para casos similares:**
- **La infra de Maswer la administra conet.de**, empresa externa (NO CoolNetworks). La cuenta `conetadmin` aparece con Vollzugriff en las ACLs. Cualquier acceso server-side que N1 no pueda hacer va a conet, no a N2 de CoolNetworks. Ver [[conet-de-administers-maswer-infra]].
- **La carpeta HR está blindada:** herencia desactivada y la pestaña Seguridad no es accesible desde la cuenta N1. Propietario (Besitzer): Oliver Orth. Modificar su ACL excede N1.
- **Autorización RR.HH.:** el acceso se concedió/confirmó sin que constara en el ticket quién lo autorizaba. Para futuros accesos a HR (datos sensibles / RGPD), exigir aprobación registrada de un responsable antes de conceder.
- **Permisos efectivos = el más restrictivo entre Share y NTFS.** Si un usuario no ve la carpeta pese a NTFS correcto, revisar permisos de Recurso compartido (Freigabe).
