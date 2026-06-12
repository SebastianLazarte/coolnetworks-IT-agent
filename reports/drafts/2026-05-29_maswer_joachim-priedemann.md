# Reporte del caso — Joachim Priedemann / Maswer

- **Cliente:** Maswer
- **Contacto principal:** Vincenzo Valle
- **Usuario final:** Joachim Priedemann (oficina de Calden)
- **Otros implicados:** Oliver Orth, Carlos Vila Conde
- **Técnico asignado:** Sebastian Lazarte Castellón (IT-Support-Germany / CoolNetworks)
- **Fecha de apertura:** 18-may-2026
- **Estado actual:** abierto · waiting on customer (disponibilidad para sesión remota + envío del equipo dañado)

---

## Cronología

| Fecha | Evento |
|---|---|
| 18-may | Vincenzo abre el ticket: (A) configurar portátil nuevo para Joachim, (B) problema de conexión con Starkis en Calden. |
| 18-may 21:00 | Respuesta inicial — acuse de recibo y solicitud de información (Miguel Rubira). |
| 18–19 may | Triage interno: se separan los dos asuntos. Intento de videollamada con Joachim → no se conectó. Comprobaciones de calidad de la conexión desde nuestro lado → todo en orden. Llamada a la oficina de Calden → no se pudo contactar. |
| 19-may | Vincenzo aporta info: portátil = HP EliteBook 840 G9 en su oficina, móvil de Joachim +49 170 3737610. Aclara que Joachim "no puede trabajar" por Starkis. |
| 19-may | Llamada a las 16:30 acordada con Vincenzo. Vincenzo reformula: el portátil actual de Joachim **se apaga cada ~10 min** (bloqueo real); Starkis es problema **separado y antiguo**. |
| 19-may | Se ejecuta la instalación del nuevo portátil. Fue necesario **deshabilitar temporalmente el doble factor** de la cuenta para completar el setup y volver a activarlo. **Ticket cerrado** con confirmación. |
| 22-may | El cliente **reabre** (ticket nuevo): el portátil no está completamente listo, debe tener exactamente la misma configuración y software, Joachim no puede hacerlo solo. Asumen que tenemos backup. |
| 22–28 may | Se aclara: **no existe backup**, y el portátil viejo **es demasiado inestable para clonarlo**. Se propone reinstalación estándar + lista de software/accesos facilitada por Joachim, recuperación de datos best-effort. Mensaje traducido al alemán por el idioma de Joachim. |
| 29-may | Respuesta de Oliver: el portátil se reenvía a Hennef, él irá en persona a configurarlo y propone llevar a Sebastian. Confirma que **aún no se ha creado perfil de usuario**, solo perfil local Win11, sin acceso al servidor. Joachim tiene 3 días antes de vacaciones. |
| 29-may | Constraint del técnico: post-operación de tendón de Aquiles, sin movilidad → se acuerda enfoque mixto: **Oliver en sitio + Sebastian remoto por AnyDesk**. A la espera de fecha. |
| 03-jun | Vincenzo pregunta por qué se solicitan los equipos — no había recibido contexto. Se le explica la situación. |
| 03-jun | Se propone a Vincenzo dos opciones: sesión remota (con alguien en sitio) o envío de ambos equipos a España. |
| 03-jun | Decisión acordada: **sesión remota** para configurar el nuevo HP EliteBook 840 G9 (domain join, perfil, acceso al servidor). El portátil dañado **se envía a España** por protocolo de devolución de equipos incluido en el contrato de servicio. Pendiente confirmar disponibilidad y hora de Vincenzo. |

---

## Trabajo realizado

### Comunicación con cliente
- 1 acuse de recibo con preguntas de scoping.
- 1 update de estado con resultados de las pruebas.
- 1 mensaje confirmando reunión 16:30.
- 1 mensaje de resolución (cierre del primer ticket) explicando la deshabilitación temporal del 2FA.
- 4 iteraciones tras la reapertura (sin backup, no se puede clonar, petición de lista de software/AnyDesk, respuesta a Oliver).
- Aclaración a Vincenzo sobre el motivo de solicitar los equipos.
- Coordinación del plan final: sesión remota para el nuevo portátil + envío del equipo dañado a España por protocolo contractual.

### Diagnóstico y pruebas técnicas
- Comprobaciones de calidad de conexión desde nuestro lado → todo OK (Starkis no es problema de infraestructura nuestra).
- Identificación del fallo del portátil viejo (apagado cada ~10 min).
- Constatación de que el clonado 1:1 no es viable (sin backup + máquina origen no estable).

### Decisiones de triage
- Separación de los dos asuntos en tickets independientes.
- Priorización: portátil = P2 (usuario bloqueado), Starkis = P3 (no bloqueante, problema antiguo, un solo usuario).
- Sin escalado: nada apuntó a Cybersecurity ni N2 Systems.

### Setup ejecutado en el primer ciclo
- Imagen del HP EliteBook 840 G9, 2FA gestionado de forma segura, devolución prevista a Joachim. Posteriormente el cliente reportó que faltaba domain join + perfil de usuario → de ahí la reapertura.

---

## Tiempo

- **Elapsed total:** 16 días (18-may → 03-jun), todavía abierto.
- **Primer ciclo (ticket original cerrado):** ~24–36 h desde apertura hasta resolución reportada.
- **Segundo ciclo (reapertura):** 7 días y contando, bloqueado mayormente en información del cliente y logística (devolución a Hennef, fecha de Oliver, lista de Joachim).
- **Tiempo activo del técnico (estimado):** 4–6 h efectivas repartidas en triage, intentos de contacto, llamada 16:30, primer setup con 2FA, redacción y traducción de comunicaciones.

---

## Estado actual y pendientes

**Estado:** abierto · waiting on customer

**Para cerrar el portátil necesitamos:**
1. Confirmación de disponibilidad y hora de Vincenzo para la sesión remota.
2. Alguien en sitio (Calden/Hennef) durante la sesión para gestionar el equipo.
3. Lista de software y accesos de Joachim.
4. Creación de cuenta AD / perfil de dominio antes de la sesión.
5. Envío del portátil dañado a España (protocolo contractual).

**Pendiente posterior:** verificación de **Starkis** sobre el portátil nuevo una vez Joachim trabaje con él (Ticket B, P3).
