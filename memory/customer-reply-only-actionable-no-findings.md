---
name: customer-reply-only-actionable-no-findings
description: "La respuesta al cliente lleva solo lo que tiene que HACER — nunca hallazgos internos ('tu cuenta no está bloqueada') ni coletillas de empatía"
metadata:
  type: feedback
---

El bloque CUSTOMER REPLY contiene solo las acciones que el usuario tiene que ejecutar, más una
línea sobre qué hacer si falla. Todo lo que *encontré* diagnosticando se queda en los bloques
internos / la nota del ticket.

**Why:** Sebastian, en el ticket Sophos de Stangenberg (31-ago-2026), sobre mi frase "Tu cuenta
está bien — no está bloqueada y tu contraseña no ha caducado": *"¿De qué le sirve saber que su
password no está bloqueado y no ha expirado?"* — y después *"evita hacer ese tipo de cosas"*. Un
usuario no técnico no puede actuar sobre un hallazgo; solo alarga el correo. Mismo veredicto
sobre el relleno empático ("month-end noted"): *"¿qué se supone que es month-end noted?"*.

**How to apply:**
- Cortar de la respuesta al cliente: estado de la cuenta/AD, lo que he descartado, qué significa
  el código de error, por qué ha pasado, y cualquier acuse de su urgencia. Ya saben que tienen
  prisa.
- Mantener: acciones numeradas + "si sigue sin funcionar, dímelo / mándame lo que ves".
- Los hallazgos sí van al ticket como **nota interna**, para que conet o el siguiente turno no
  los repitan.
- Con un usuario con poca soltura informática, recortar aún más: una acción que ya sabe hacer
  (apagar y encender), y ofrecer hacerlo juntos por teléfono.

Extiende [[customer-replies-non-technical-by-default]] y [[reply-tone-direct-not-nice]]; la
otra mitad es no pedirle lo que ya ha hecho ([[dont-instruct-what-user-already-did]]) ni lo que
puedo averiguar yo ([[customer-reply-only-ask-operational-info]]).
