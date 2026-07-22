# Reporte del caso — Envío de correo de Joachim vía cuenta de servicio de Calden

- **Cliente:** Maswer (oficina de Calden)
- **Solicitante:** Vincenzo Valle — ver [[maswer-calden-contacts]]
- **Usuario final:** Joachim Priedemann (envía "como" service.calden@maswer.com desde el "central computer")
- **Buzón implicado:** service.calden@maswer.com (buzón de servicio compartido de la sede)
- **Técnico asignado:** Sebastian Lazarte Castellón (CoolNetworks)
- **Fecha de apertura:** 21-jul-2026 (mismo ticket "IT Issues in Calden")
- **Estado actual:** ABIERTO · en investigación (revisando logs de correo)

---

## Triage del ticket

| Campo | Valor |
|---|---|
| Categoría | Cloud (Microsoft 365 / Exchange híbrido) — flujo de correo |
| Prioridad | P2 - Alta (pérdida silenciosa de correo saliente en una cuenta de servicio → comunicaciones del negocio degradadas y en riesgo) |
| Grupo | N1 - Soporte general (first touch) → N2 Systems (Exchange/DNS). ⚠️ Pivota a N2 Cybersecurity solo si aparecen reglas/reenvíos sospechosos. |
| SLA inicial | Respuesta en 1 h · resolución objetivo 8 h hábiles |

---

## Solicitud recibida

> "The second issue concerns Joachim Priedemann's email inbox. When he sends emails from the central computer via the Calden service account, his messages sometimes do not reach the recipients. Could you please investigate this issue as well and contact Joachim directly?"

---

## Diagnóstico inicial

- Síntoma: correo saliente enviado **como** buzón de servicio compartido (service.calden@maswer.com) que **a veces** no llega al destinatario.
- **Hipótesis principal:** fallo de alineación **SPF/DKIM/DMARC** al enviar como buzón compartido → algunos servidores receptores lo ponen en cuarentena o lo rechazan (intermitente según el dominio destino).
- **Alternativas:** permiso **Send-As** mal configurado (Send-As vs Send-on-Behalf); filtrado antispam del lado del destinatario; mensajes atascados en la ruta híbrida (Exchange en MEUAZEX001 — ver [[maswer-servers-inventory]]).
- **Sin confirmación de pérdida de datos ni de brecha.** No es un incidente de seguridad según nuestras señales actuales.

---

## Pasos para el técnico

1. **Message trace** en el Exchange admin center para el emisor service.calden@maswer.com, últimos 7 días. Identificar los envíos fallidos y su estado (Delivered / Failed / Quarantined / FilteredAsSpam / Pending). **Paso decisivo** — muestra dónde se detienen los mensajes. No requiere a Joachim.
2. Verificar si Joachim recibe **NDR/rebote** en los envíos fallidos; capturar el código (p. ej. 5.7.x). Sin NDR + no entregado = filtrado/descartado aguas abajo.
3. Verificar el permiso **Send-As** de Joachim sobre el buzón compartido (Exchange híbrido → MEUAZEX001 / EAC). Distinguir Send-As de Send-on-Behalf.
4. Revisar **SPF, DKIM y DMARC** de maswer.com y el conector/ruta de salida de la sede de Calden.
5. ⚠️ Mientras se revisan ambos buzones (service.calden **y** el de Joachim), comprobar reglas de **reenvío o de bandeja** inesperadas. Si aparecen → **parar y escalar a N2 Cybersecurity**, sin borrar la regla (preservar evidencia).
6. Si el trace muestra mensajes atascados en la ruta híbrida → revisión de transporte/cola en MEUAZEX001.

---

## Customer reply (EN)

Se envió **un único acuse combinado** a Vincenzo cubriendo las dos incidencias del ticket. Parte relativa al correo:

```
Email sending (Calden service account): we'll start by checking our mail logs on
our side, so this shouldn't need anything from Joachim for now.

We'll come back to you once we've had a look.
```

---

## ¿Escalar?

**Todavía no.** N1 ejecuta el message trace, la revisión de NDR y la de Send-As. Luego → **N2 Systems** para SPF/DKIM/DMARC + transporte Exchange (config de servidor/DNS). Pivota a **N2 Cybersecurity** solo si aparecen reglas/reenvíos/spoofing. **No es P1:** no hay incidente de seguridad activo.

---

## Estado actual y pendientes

**Estado:** ABIERTO · en investigación.

**Próximos pasos:**
1. Ejecutar el message trace (nuestro lado, sin depender de Joachim).
2. Según el resultado: revisar SPF/DKIM/DMARC y el permiso Send-As.
3. Involucrar a Joachim solo si hace falta verlo en vivo, vía Vincenzo.

**Notas:**
- Sin pérdida de datos ni brecha confirmadas.
- Sin incumplimiento de SLA a la fecha de este reporte.
- Contactos de la sede en [[maswer-calden-contacts]]: Joachim no es técnico, se le llega vía Vincenzo.
