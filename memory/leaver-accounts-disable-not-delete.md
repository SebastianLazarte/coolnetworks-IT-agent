---
name: leaver-accounts-disable-not-delete
description: "Nada se borra a petición — las cuentas de bajas, licencias y equipos obsoletos se deshabilitan y se retienen hasta que Maswer confirme por escrito, con fecha límite; el silencio no es aprobación"
metadata:
  type: feedback
---

Cuando un contacto de Maswer pide "borrar los accesos" de gente que se va, **no borramos las
cuentas a petición**. Se deshabilitan y se retienen, y el cliente recibe una **fecha fija** en
la que tiene que decir qué se conserva y quién se queda el correo.

**La autorización por escrito de dirección va primero — antes de ejecutar nada.** Un ticket
del contacto de la sede (p. ej. Vincenzo) es una petición, no una aprobación. Los cambios de
acceso quedan registrados, así que el correo de autorización tiene que adjuntarse al ticket con
fecha y remitente antes de tocar la cuenta. No ofrecer "lo apagamos hoy y el papeleo después".
**Quién en Maswer cuenta como aprobador no está documentado — asunto abierto.**

**Why:** la posición de Sebastian — no pueden pedirnos sin más que borremos cuentas, así se
pierde información y no tiene vuelta atrás. La fecha existe porque hay gente de vacaciones y la
decisión necesita a todos de vuelta antes de ser definitiva.

**How to apply:** la respuesta dice con todas las letras que borrar elimina también buzones y
ficheros, da la fecha de corte y pregunta qué hay que conservar. Por dentro: deshabilitar en
ADUC contra el DC, forzar sync en [[maswer-aad-connect-server]], mantener la licencia hasta que
expire la retención, y **verificar qué retiene de verdad el backup de Hornetsecurity/Altaro
antes de borrar nada** — ver [[maswer-m365-backup]]. **El silencio en la fecha límite no es
aprobación:** las cuentas siguen deshabilitadas y el ticket abierto hasta que llegue la
confirmación escrita. Caso: Florian Rohner + Steven Conow, ticket "Delete Acccess and Update IT"
(Vincenzo Valle, 2026-08-06), retención hasta el **2026-09-01**.

**La misma regla para licencias y datos maestros de equipos.** Limpiar licencias M365 sin uso u
objetos de equipo obsoletos en AD es el mismo acto de borrado, así que sigue la misma forma:
mandamos una hoja de confirmación (una fila por usuario/máquina, último inicio de sesión o
última vez visto, propietario supuesto, y una columna vacía "¿sigue haciendo falta? / usuario
confirmado"), Maswer rellena el propietario, y solo entonces se retira algo. AD y Defender
muestran cuándo se vio una máquina por última vez pero nunca **quién la usa** — esa columna solo
la puede rellenar el cliente, así que pedirla no es burocracia, es el dato que falta. Mismo
hueco con las licencias: el tenant muestra qué cuentas existen y cuándo entraron por última vez,
nunca quién sigue contratado, y la actividad de inicio de sesión por sí sola confunde bajas
maternales, bajas por enfermedad y cuentas compartidas con cuentas muertas. Así que **pedir a
Maswer la lista de empleados activos antes de empezar cualquier limpieza de licencias**, y no
comprometer fecha hasta que llegue — cuadrar lista de RRHH contra cuentas del tenant contra
actividad es trabajo largo de verdad. Esa lista se pide **a través de Vincenzo**, no por la
carpeta de RRHH (nuestro acceso ahí sigue siendo el asunto abierto con conet.de).

Dar a todas esas rondas **una sola fecha límite compartida** en vez de perseguir fechas
separadas. El caso de mayor riesgo con este patrón es [[oliver-orth-admin-accounts-still-enabled]].
Relacionado: [[maswer-calden-contacts]], [[reply-tone-direct-not-nice]].
