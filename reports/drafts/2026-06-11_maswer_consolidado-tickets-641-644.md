# Reporte consolidado de tickets — Maswer (Alemania)

- **Fuente:** Export Freshdesk `201000050189_tickets-June-11-2026-10_49.csv`
- **Cliente:** Maswer / Maswer Alemania
- **Técnico:** Sebastian Lazarte Castellón (CoolNetworks)
- **Fecha del reporte:** 11-jun-2026
- **Tickets incluidos:** 2 (ambos `Closed`, ambos `Within SLA`)

---

## Resumen ejecutivo

| Ticket | Asunto | Estado | Grupo | Resolución | Apertura | Solicitante | Detalle disponible |
|---|---|---|---|---|---|---|---|
| **641** | Speicherplatz voll - in 22 Tagen bekommen wir keine Email mehr | Closed | Cybersecurity - Germany | Within SLA | 9-jun-2026 | Alketa Vrella (alketa.vrella@maswer.com) | ⚠️ Solo datos del CSV — sin report detallado |
| **644** | Access permission to the HR folder | Closed | Soporte Software | Within SLA | 10-jun-2026 | Vincenzo Valle (vincenzo.valle@maswer.com) | ✅ Report completo (draft `2026-06-10_maswer_hr-folder-access.md`) |

**Lectura rápida:** ambos tickets se cerraron dentro de SLA. El 644 está completamente documentado abajo. El 641 solo cuenta con los metadatos del CSV; no existe un report técnico en `/reports`, por lo que su sección refleja únicamente lo exportado de Freshdesk.

---

## Ticket 641 — Speicherplatz voll / buzón a punto de bloquear correo

> ⚠️ **Sin report técnico.** No existe draft en `/reports` para este ticket. La información a continuación proviene exclusivamente del export CSV de Freshdesk.

| Campo | Valor |
|---|---|
| ID del ticket | 641 |
| Asunto | Speicherplatz voll - in 22 Tagen bekommen wir keine Email mehr |
| Traducción del asunto | "Almacenamiento lleno — en 22 días dejaremos de recibir correo" |
| Estado | Closed |
| Grupo | Cybersecurity - Germany |
| Estado de resolución | Within SLA |
| Tiempo de respuesta inicial | 2026-06-09 14:47:41 |
| Interacciones del agente | 2 |
| Fecha de apertura (Start Date) | 9-jun-2026 |
| Solicitante | Alketa Vrella (alketa.vrella@maswer.com) |
| Delegación | — (no especificada en el CSV) |

**Interpretación del caso (a partir del asunto):** alerta de cuota/almacenamiento de buzón. El sistema advierte que en ~22 días se agotará el espacio y dejará de entrar correo. Es un caso de capacidad/housekeeping de buzón (no incidente de seguridad pese al grupo "Cybersecurity - Germany").

**Pendiente de documentación:** no consta en el CSV la causa raíz, la acción correctiva ni la confirmación de cierre técnico. Solo 2 interacciones de agente y cierre dentro de SLA. *Si se requiere trazabilidad completa de este ticket, debe redactarse un report a partir del hilo en Freshdesk.*

**Nota:** Alketa Vrella es también el contacto del caso de caída de internet en Vaihingen (draft `2026-06-08_maswer_vaihingen-internet-outage-s2s-vpn.md`), pero ese caso es de red/infraestructura y no guarda relación con este ticket de almacenamiento.

---

## Ticket 644 — Acceso a la carpeta HR

| Campo | Valor |
|---|---|
| ID del ticket | 644 |
| Asunto | Access permission to the HR folder |
| Estado | Closed |
| Grupo | Soporte Software |
| Estado de resolución | Within SLA |
| Tiempo de respuesta inicial | 2026-06-11 09:31:16 |
| Interacciones del agente | 3 |
| Fecha de apertura (Start Date) | 10-jun-2026 |
| Fecha de cierre | 11-jun-2026 |
| Solicitante | Vincenzo Valle (vincenzo.valle@maswer.com) |
| Usuarios finales | Vincenzo Valle, Angelika Stangenberg (angelika.stangenberg@maswer.com) |

### Triage

| Campo | Valor |
|---|---|
| Categoría | Cuentas y Acceso (permisos de carpeta) |
| Prioridad | P4 - Baja (solicitud de acceso no bloqueante) |
| Grupo | N1 configuración de cliente; N2 Systems si requiere acceso admin al servidor |
| SLA inicial | Respuesta en 1 día hábil |
| Escalado | No escalado finalmente — el acceso se confirmó antes de derivar a conet (admin externo de la infra) |

### Solicitud recibida

> "Please grant Ms. Stangenberg and me access to the HR folder."

Solicitud de acceso a la carpeta HR para dos usuarios. Ubicación de la carpeta, nivel de acceso y autorización no especificados en el mensaje inicial.

### Cronología

| Fecha | Evento |
|---|---|
| 10-jun | Ticket recibido vía portal: solicitud de acceso a la carpeta HR para Vincenzo Valle y Angelika Stangenberg. |
| 10-jun | Triage: Cuentas y Acceso, P4. Identificada la carpeta HR como contenido sensible → requiere verificar autorización antes de conceder. |
| 10-jun | Localización del control de permisos en el file server: pestaña **Effective Access** (Propiedades → Seguridad → Opciones avanzadas → Acceso efectivo). |
| 10-jun | Incidencia: pestaña **Seguridad** no visible. Causa probable — acceso vía ruta UNC/unidad mapeada en lugar de ruta local, o "Asistente para compartir" activo. |
| 10-jun | Permisos concedidos sobre la carpeta HR para ambos usuarios. |
| 10-jun | Redactado mensaje de confirmación al solicitante (inglés). Pendiente confirmación de acceso. |
| 11-jun | Usuarios añadidos vía AD; tras logoff/login seguían sin acceso. ACL no accesible desde la cuenta N1 (herencia desactivada, propietario Oliver Orth). Identificado que la infra de Maswer la administra **conet.de** (cuenta `conetadmin`), no CoolNetworks. |
| 11-jun | Antes de escalar a conet, **Angelika confirma que ambos ya tienen acceso** y pide cerrar el ticket. |
| 11-jun | Enviado mensaje de cierre. Ticket cerrado. |

### Trabajo realizado

- **Diagnóstico:** control de verificación = pestaña **Effective Access** (combina permisos directos y de grupo). Falta de pestaña **Seguridad** resuelta navegando la **ruta local** del servidor (no `\\servidor\recurso`) y/o desactivando "Usar el Asistente para compartir".
- **Concesión:** permisos NTFS sobre la carpeta HR para Vincenzo Valle y Angelika Stangenberg.
- **Comunicación:** mensaje "listo para verificar" (inglés) con instrucciones — pegar la ruta del recurso compartido y cerrar/reiniciar sesión (el token de seguridad se construye en el login).

### Estado final

**RESUELTO** — Angelika Stangenberg confirmó (11-jun, 11:12) que ella y Vincenzo Valle tienen acceso. Ticket cerrado.

**Causa raíz: no confirmada.** No se verificó *qué* destrabó el acceso (propagación tardía de AD, o aplicación server-side por conet/Oliver). Se cierra por confirmación del cliente.

**Lecciones / notas:**
- La infra de Maswer la administra **conet.de** (externo, cuenta `conetadmin` con Vollzugriff). Accesos server-side que N1 no pueda hacer van a conet, no a N2 CoolNetworks.
- La carpeta HR está blindada: herencia desactivada, pestaña Seguridad no accesible desde N1. Propietario: Oliver Orth.
- **Autorización RR.HH.:** el acceso se concedió sin registro de quién lo autorizó. Para futuros accesos a HR (RGPD), exigir aprobación registrada de un responsable.
- Permisos efectivos = el más restrictivo entre Share y NTFS.

---

## Conclusión

| Métrica | Valor |
|---|---|
| Tickets totales | 2 |
| Cerrados | 2 / 2 |
| Dentro de SLA | 2 / 2 |
| Con report detallado | 1 (ticket 644) |
| Pendiente de documentar | 1 (ticket 641 — solo metadatos del CSV) |

**Acción recomendada:** redactar un report técnico para el ticket 641 (almacenamiento de buzón) si se necesita trazabilidad de causa raíz y acción correctiva; actualmente solo existe el metadato del export.
