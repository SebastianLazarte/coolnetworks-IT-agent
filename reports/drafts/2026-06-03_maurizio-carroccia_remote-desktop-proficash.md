# Reporte del caso — Maurizio Carroccia / Remote Desktop + Profi Cash

- **Cliente:** Maswer AG
- **Usuario final:** Maurizio Carroccia
- **Técnico asignado:** Sebastian Lazarte (CoolNetworks)
- **Fecha de apertura:** 03-jun-2026
- **Estado actual:** pendiente confirmación de acceso por parte del usuario

---

## Cronología

| Fecha | Evento |
|---|---|
| 03-jun | Ticket recibido: solicitud de instalar Remote Desktop en el equipo de Maurizio y dar acceso al acceso directo de Profi Cash. |
| 03-jun | Diagnóstico inicial: "Remote Desktop" no es RDP tradicional — el acceso a Profi Cash se realiza mediante **Azure Virtual Desktop (AVD)** vía web client en `windows.cloud.microsoft`. |
| 03-jun | Identificado el link AVD con loginHint `IT-Support-Germany@maswer.com`. Se descarta compartir credenciales de cuenta de soporte con el usuario final (violación de seguridad). |
| 03-jun | Intento de gestionar el AVD desde Azure Portal (`portal.azure.com`) con la cuenta `IT-Support-Germany@maswer.com`: el recurso AVD no aparece — la cuenta no tiene permisos de administración sobre el recurso. |
| 03-jun | Decisión: enviar el link AVD directamente a Maurizio para que intente acceder con su propia cuenta Maswer. Si el acceso falla (error de permisos), se requerirá al administrador de Azure de Maswer para añadirle al Application Group. |
| 03-jun | Link enviado a Maurizio. Pendiente confirmación de que puede acceder. |

---

## Trabajo realizado

### Diagnóstico técnico
- Identificación del entorno: AVD (Azure Virtual Desktop), no RDP on-prem ni RDS clásico.
- Verificación de permisos: la cuenta `IT-Support-Germany@maswer.com` no tiene rol de administrador sobre el recurso AVD en Azure — no es posible gestionar Application Groups desde ella.
- Descartada la opción de compartir credenciales de cuenta compartida con el usuario final.

### Comunicación con cliente
- 1 mensaje a Maurizio con el link AVD y las instrucciones para acceder con su cuenta Maswer.

### Decisiones de triage
- Categoría: Software / Aplicaciones + Cuentas y Acceso.
- Prioridad: P4 (solicitud planificada, sin bloqueo operativo).
- Grupo: N1 para configuración del lado del cliente; N2/Azure Admin si Maurizio no tiene asignación en el Application Group.

---

## Estado actual y pendientes

**Estado:** pendiente confirmación de acceso por Maurizio

**Para cerrar formalmente:**
1. Maurizio confirma que puede acceder al AVD y ver Profi Cash con su cuenta.
2. Si acceso denegado: identificar al administrador Azure de Maswer (Owner/Contributor en la suscripción) y solicitar que añada la cuenta de Maurizio al Application Group correspondiente.

**Notas:**
- El adminisrador Azure de Maswer es desconocido para CoolNetworks a fecha de este ticket. Si se necesita escalar, preguntar al contacto que abrió el ticket.
- Relacionado con ticket anterior: [2026-05-26 — Visio install](2026-05-26_maurizio-carroccia_visio-install.md). UPN mismatch (`mcarroccia` vs `mauricio.carroccia`) sigue sin resolverse — relevante si el login falla por cuenta no encontrada.
- No se requiere instalación de software en el equipo de Maurizio: el acceso es 100% vía navegador web.
