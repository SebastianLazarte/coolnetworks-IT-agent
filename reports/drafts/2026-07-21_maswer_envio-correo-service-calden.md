# Reporte del caso — Envío de correo de Joachim vía cuenta de servicio de Calden

- **Cliente:** Maswer (oficina de Calden)
- **Solicitante:** Vincenzo Valle — ver [[maswer-calden-contacts]]
- **Usuario final:** Joachim Priedemann (envía "como" service.calden@maswer.com desde el "central computer")
- **Buzón implicado:** service.calden@maswer.com (buzón de servicio compartido de la sede)
- **Técnico asignado:** Sebastian Lazarte Castellón (CoolNetworks)
- **Fecha de apertura:** 21-jul-2026 (mismo ticket "IT Issues in Calden")
- **Estado actual:** ABIERTO · lado servidor descartado (23-jul) · pendiente de 2-3 ejemplos de Joachim para confirmar causa A (junk del receptor) vs B (Outlook del "central computer")

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
- **Alternativas:** permiso **Send-As** mal configurado (Send-As vs Send-on-Behalf); filtrado antispam del lado del destinatario; mensaje **entregado pero en la carpeta de correo no deseado** del destinatario.
- **Nota de infra:** el correo de Maswer vive en **Exchange Online** (híbrido solo de identidad). `MEUAZEX001` **no** corre Exchange — verificado 22-jul-2026 (sin binarios/servicios; etiqueta Defender errónea) — ver [[maswer-servers-inventory]]. Por tanto el flujo de salida y SPF/DKIM/DMARC se revisan en **M365 / Exchange Online**, no en una cola on-prem.
- **Sin confirmación de pérdida de datos ni de brecha.** No es un incidente de seguridad según nuestras señales actuales.

---

## Pasos para el técnico

1. **Message trace** en Exchange Online (EAC / M365 Defender) para el emisor service.calden@maswer.com, últimos 7-10 días. Identificar los envíos fallidos y su estado (Delivered / Failed / Quarantined / FilteredAsSpam / Pending). **Paso decisivo** — muestra dónde se detienen los mensajes. No requiere a Joachim, aunque 2-3 ejemplos concretos (destinatario + fecha aprox.) lo agilizan mucho.
2. Verificar si Joachim recibe **NDR/rebote** en los envíos fallidos; capturar el código (p. ej. 5.7.x). Sin NDR + no entregado = filtrado/descartado aguas abajo.
3. Verificar el permiso **Send-As** de Joachim sobre el buzón compartido (Exchange híbrido → MEUAZEX001 / EAC). Distinguir Send-As de Send-on-Behalf.
4. Revisar **SPF, DKIM y DMARC** de maswer.com y el conector/ruta de salida de la sede de Calden.
5. ⚠️ Mientras se revisan ambos buzones (service.calden **y** el de Joachim), comprobar reglas de **reenvío o de bandeja** inesperadas. Si aparecen → **parar y escalar a N2 Cybersecurity**, sin borrar la regla (preservar evidencia).
6. Verificar **DKIM** del dominio `maswer.com` en M365 Defender (¿habilitado y firmando?) y el registro **SPF** TXT + política **DMARC**. Un DKIM no habilitado explica el patrón intermitente (receptores estrictos, típicos en dominios alemanes, ponen en cuarentena/rechazan).

---

## Propuesta de solución

El síntoma (envío **como** el buzón de servicio compartido que **a veces** no llega, según destinatario) es un patrón clásico de **alineación de autenticación de correo** o de **entrega en la carpeta de no deseado del destinatario**, no de pérdida real. Como el buzón está en **Exchange Online**, todo se diagnostica y se corrige desde M365, sin depender de Joachim salvo para 2-3 ejemplos.

### Hipótesis de causa raíz (ordenadas por probabilidad)
1. **Entregado pero en "correo no deseado" del destinatario.** El trace marca *Delivered* pero el receptor no lo ve. Muy común con cuentas de servicio compartidas. Fix: habilitar/confirmar **DKIM** de `maswer.com` + alinear **DMARC**, y pedir al destinatario que lo mueva a "correo deseado".
2. **SPF/DKIM/DMARC desalineado al enviar como buzón compartido.** Si DKIM no está firmando para el dominio, receptores estrictos ponen en cuarentena/rechazan de forma intermitente. Fix: **habilitar DKIM** para `maswer.com` en M365 y verificar que el SPF incluye Exchange Online.
3. **Send-As mal configurado** (tiene Send-on-Behalf en vez de Send-As). Fix: conceder **Send-As** de service.calden a Joachim en EAC.

### Plan de resolución (todo del lado servidor)
1. **Message trace** de service.calden@maswer.com (7-10 días) → clasificar Delivered / Quarantined / Failed / FilteredAsSpam.
2. Según el resultado:
   - *Delivered* → es filtrado del destinatario (junk) → habilitar/confirmar DKIM + DMARC y pedir allowlist al receptor.
   - *Quarantined / Failed con NDR 5.7.x* → arreglar **SPF/DKIM** (habilitar DKIM, revisar SPF).
3. Verificar **DKIM/SPF/DMARC** de `maswer.com` en M365 Defender (tenant `maswerag.onmicrosoft.com`).
4. Verificar el permiso **Send-As** (no Send-on-Behalf) de Joachim sobre service.calden en EAC.
5. ⚠️ Mientras revisas ambos buzones, comprobar **reglas de reenvío/bandeja inesperadas**. Si aparecen → **parar y escalar a N2 Cybersecurity**, sin borrar (preservar evidencia).

### Único dato que pedir al usuario
A Joachim, **vía Vincenzo**: 2-3 ejemplos concretos recientes (destinatario + fecha/hora aprox.) de correos que no llegaron, para localizarlos en el trace. Nada más — no hace falta sesión ni que pruebe nada.

### Resultado esperado
El 90% de estos casos se resuelve habilitando/confirmando DKIM + DMARC y ajustando Send-As. Solo si el trace muestra fallo real de transporte se investiga más a fondo.

---

## Hallazgos (23-jul-2026)

Ejecutado el diagnóstico de lado servidor. **La salida de correo está sana; se descarta causa de nuestro lado:**

- **Message trace** de service.calden@maswer.com (últimos 10 días): **todos los envíos `Delivered`**. Ni un `Failed`, `Quarantined` ni `FilteredAsSpam`. Destinos externos (thitronik.de, glinicke.de, gmail.com) e internos, todos aceptados por el servidor destino.
- **DKIM** de `maswer.com`: `Enabled: True`, `Status: Valid` → **firma correctamente**.
- **SPF**: `v=spf1 ip4:195.20.133.27 include:spf.protection.outlook.com ~all` → válido, incluye Exchange Online.
- **DMARC**: `_dmarc.maswer.com` **no existe** (NXDOMAIN). No es la causa (DKIM+SPF pasan); es un hueco de hardening/reputación aparte.
- **Send-As**: no llega a ser el problema — si estuviera mal, los envíos no aparecerían como Delivered.

**Conclusión:** los correos que salen por la cuenta de servicio se entregan y están bien autenticados. La incidencia de "a veces no llegan" solo puede ser:
- **(A)** entregados pero archivados como no deseado en el destinatario (por reputación/contenido, NO por autenticación), o
- **(B, principal)** que los correos "fallidos" **nunca salieron por la cuenta de servicio** → problema de **Outlook en el "central computer"** (Bandeja de salida atascada, modo caché, o enviados desde la cuenta propia y no "como" service.calden). Eso no aparece en el trace porque no pasó por Exchange Online.

**Paso decisivo pendiente:** obtener 2-3 ejemplos concretos de Joachim (destinatario + fecha/hora) y cruzarlos contra el trace:
- Aparecen como Delivered → causa A (junk del receptor) → pedir allowlist al destinatario.
- No aparecen → causa B confirmada → diagnosticar Outlook en el "central computer".

**Dato suelto a confirmar:** el SPF autoriza `ip4:195.20.133.27` (fuente de envío distinta a EXO) — ¿relay/gateway de Calden? Si el "central computer" enviara por esa vía, tampoco saldría en el trace de EXO.

**Mejora aparte (no es el fix):** publicar DMARC básico `v=DMARC1; p=none; rua=mailto:...` vía conet.de para visibilidad y reputación.

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

**Estado:** ABIERTO · lado servidor descartado (ver "Hallazgos 23-jul") · pendiente de ejemplos de Joachim.

**Próximos pasos:**
1. ⏳ Pedido a Vincenzo: 2-3 ejemplos concretos de Joachim (destinatario + fecha/hora) de correos que no llegaron.
2. Cruzarlos contra el message trace: Delivered → causa A (junk del receptor); ausentes → causa B (Outlook del "central computer").
3. Si causa B → diagnosticar Outlook en el "central computer" (Bandeja de salida, modo caché, From = service.calden vs cuenta propia).
4. Confirmar qué es el host SPF `195.20.133.27` (¿relay/gateway de Calden?).
5. Aparte (no bloqueante): proponer DMARC `p=none` vía conet.de.

**Notas:**
- Sin pérdida de datos ni brecha confirmadas.
- Sin incumplimiento de SLA a la fecha de este reporte.
- Contactos de la sede en [[maswer-calden-contacts]]: Joachim no es técnico, se le llega vía Vincenzo.
