# Reporte del caso — Maurizio Carroccia / Instalación de Visio

- **Cliente:** [a confirmar]
- **Usuario final:** Maurizio Carroccia
- **Otros implicados:** Oliver Orth (admin de cuentas elevadas)
- **Técnico asignado:** Sebastian Lazarte (CoolNetworks)
- **Fecha de apertura:** 26-may-2026
- **Estado actual:** resuelto · pendiente rotación de contraseña localadmin

---

## Cronología

| Fecha | Evento |
|---|---|
| 26-may | Solicitud: instalar Microsoft Visio en el equipo de Maurizio. Office ya estaba instalado, solo faltaba Visio. |
| 26-may | Diagnóstico inicial: confirmada licencia Visio Plan 2 asignada al usuario, verificado canal/arquitectura del Office existente. |
| 26-may | Primer intento — despliegue por **Intune**: creación del grupo `Visio-Devices` en Entra ID, alta del dispositivo, app `Visio Pro Plan 2` con XML personalizado (`VisioProRetail`), asignación Required y sync forzado. La app no apareció en install status en tiempo razonable → se cambió a instalación manual. |
| 26-may | Solicitud de credenciales de admin local a Oliver Orth. Recibido `localadmin` + contraseña en correo separado. |
| 26-may | Intentos de conexión remota fallidos: **Quick Assist** quedó esperando aceptación del usuario; **TeamViewer** marcó la sesión como uso comercial y cortó; **AnyDesk** conectó pero sin capacidad de elevar UAC desde el lado del técnico. |
| 26-may | Coordinada reunión de Teams a las 11:00 para continuar la instalación con el usuario presente. |
| 26-may | Instalación manual vía `office.com` (Install apps → Visio). Ante imposibilidad de elevar UAC remotamente, se compartió la contraseña de `localadmin` con Maurizio para que la tipeara él. ⚠️ Incidente de seguridad documentado. |
| 26-may | Visio instalado y activado correctamente con la cuenta de Maurizio. Verificación con el usuario: abre sin pedir activación. |
| 26-may | Correo enviado a Oliver documentando el incidente, los fallos de herramientas remotas y las preguntas abiertas (privilegios de Maurizio, posible UPN mismatch). |

---

## Trabajo realizado

### Comunicación con cliente
- 1 correo a Maurizio solicitando instalación de AnyDesk y el código de conexión.
- 1 mensaje de Teams pidiendo reabrir AnyDesk cuando se desconectó.
- 1 invitación a reunión de Teams a las 11:00.
- 1 mensaje de cierre confirmando instalación exitosa.

### Comunicación interna
- 1 solicitud a Oliver pidiendo credenciales para elevar instalaciones.
- 1 correo a Oliver documentando el incidente de seguridad y solicitando:
  - rotación de contraseña `localadmin`,
  - herramienta estándar de soporte remoto con soporte de elevación UAC,
  - revisión de privilegios y posible UPN mismatch en la cuenta de Maurizio.

### Diagnóstico y pruebas técnicas
- Verificación de licencia Visio Plan 2 en M365 Admin Center.
- Identificación del canal/arquitectura del Office instalado para evitar conflicto en el `Add` de Visio.
- Validación de que la falta de privilegios del usuario impide UAC en su propia cuenta.

### Decisiones de triage
- Categoría: Software (M365 / Visio).
- Prioridad: P3 (solicitud estándar, sin impacto operativo).
- Grupo: N1, con escalado paralelo a N2 Systems para tooling y privilegios.

### Setup ejecutado
- Intune: grupo, app y assignment creados (queda configurado para futuros despliegues, aunque no se usó en este caso).
- Instalación manual de Visio completada vía portal Office.

---

## Tiempo

- **Elapsed total:** ~1h 40min (instalación esperada: ~15-20 min).
- **Tiempo extra:** ~80 min, atribuibles a:
  - despliegue Intune que no completó en ventana razonable (~25 min),
  - fallos sucesivos de Quick Assist, TeamViewer y AnyDesk (~30 min),
  - coordinación de reunión y workaround manual con el usuario (~25 min).
- **Tiempo activo del técnico:** ~1h 40min efectivos (no hubo waiting on customer prolongado).

---

## Estado actual y pendientes

**Estado:** resuelto · pendiente rotación de contraseña

**Para cerrar formalmente:**
1. Confirmación de rotación de contraseña `localadmin` por Oliver.
2. Definición de herramienta estándar de soporte remoto con elevación UAC (sugerido: Microsoft Remote Help).
3. Revisión de privilegios de Maurizio y posible UPN mismatch (`mcarroccia` vs `mauricio.carroccia`).

**Notas:**
- Instalación funcional para el usuario sin afectar al resto del Office.
- Incidente de seguridad (contraseña admin compartida con usuario final) documentado y escalado a Oliver el mismo día.
- Configuración Intune queda lista para futuros despliegues de Visio en otros usuarios.
