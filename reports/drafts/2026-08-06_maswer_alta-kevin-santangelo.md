# Reporte del caso — Maswer / Alta de cuenta de correo (Kevin Santangelo)

- **Cliente:** Maswer Deutschland GmbH — sede Kippenheim
- **Solicitante:** Vincenzo Valle (contacto IT del sitio)
- **Técnico:** Sebastian Lazarte Castellón (CoolNetworks)
- **Ticket:** "New Email Adress" — abierto 05-ago-2026 13:37
- **Estado actual:** **en curso** — datos parciales recibidos, cuenta aún no creada

---

## Triage

| Campo | Valor |
|---|---|
| Categoría | Accounts and Access (provisioning) — con marca de ciberseguridad |
| Prioridad | P3 (petición P4, elevada por las señales de abajo) |
| Grupo | N1 |
| SLA inicial | Respuesta en 4 h |
| Escalado | No. Ruta P1 → N2 Ciberseguridad preparada por si la verificación de identidad fallaba; no se activó |

## Petición recibida

Crear `Kevin.Santangelo@maswer.com` para uso en el dispositivo personal de Kevin,
y **enviar las credenciales al solicitante** "por un canal seguro".

**Señales marcadas en la entrada (observadas, no inferidas):**
1. Mensaje firmado "**Can**" pero enviado desde la cuenta de portal de Vincenzo.
2. Credenciales pedidas para el solicitante, no para el titular de la cuenta.
3. Dispositivo personal, no gestionado.
4. Sin fecha de alta, departamento ni aprobador.

Hipótesis principal (benigna): Vincenzo retransmitió el texto de un compañero dejando su
firma — es el relevo documentado del sitio. Alternativa no descartada en ese momento:
suplantación o cuenta de portal comprometida (patrón BEC clásico). **Artefacto que lo
resolvía:** llamada telefónica al número conocido, no el hilo del ticket.

**Estado de esa duda:** la respuesta del 06-ago llegó desde el buzón propio de Vincenzo, con
detalle de entidad y sede y erratas propias, coherente con el Vincenzo real. La hipótesis de
suplantación pierde casi todo el peso. La llamada de verificación **no se ha hecho**; a estas
alturas vale como llamada para recoger los datos que faltan, no como control de identidad.

---

## Datos confirmados por el cliente (06-ago 9:24)

| Dato | Valor |
|---|---|
| Nombre | Kevin-Giuseppe-Santangelo (según el cliente, sin separar nombres de apellido) |
| Entidad | Maswer Deutschland GmbH (la del drive **Q:**, prefijo de grupos `MaswDE*`) |
| Sede | Kippenheim — **no documentada en el repo**, sede nueva para nosotros |
| Alcance | Solo correo: recibir y responder. Nada más |
| Equipo | **No recibe equipo.** Usará su teléfono personal |

**Pendientes de cliente:** fecha de incorporación · móvil de Kevin (único canal de entrega,
es su teléfono personal) · visto bueno de la dirección de Maswer para el dispositivo privado
· confirmar si la dirección lleva "Giuseppe" o se queda en `Kevin.Santangelo@maswer.com`.

---

## Criterio aplicado

- **Contraseña:** la fija el propio usuario en el primer inicio de sesión. No se envían
  credenciales a un tercero, ni siquiera al contacto IT del sitio.
- **Dispositivo privado:** el correo corporativo en un móvil personal exige el visto bueno
  de la dirección de Maswer. Pedido por escrito, aún sin respuesta.
- **Licencia y control BYOD son la misma decisión:** la forma correcta de poner correo de
  empresa en un móvil personal es protección a nivel de aplicación en Outlook (borrado
  selectivo del correo corporativo sin gestionar el teléfono), y eso exige una licencia que
  incluya Intune. Una SKU barata de solo correo no la trae. Hay licencia libre en el tenant;
  falta confirmar cuál.

---

## Plan de ejecución

**Identidad — ADUC en `MDERZADC003`** (OU del sitio bajo `OU=DE,OU=User Accounts,OU=Office365`):

- Login (UPN): **`KSantangelo@maswer.com`**
- Dirección de correo: **`Kevin.Santangelo@maswer.com`**
- Marcar *User must change password at next logon*
- Grupos: **solo** el de licencia M365 y `MFA-MASWER`. Ningún `MaswDE_*_RW` — solo necesita correo
- No usar "Copy" de un compañero: arrastra grupos de carpetas que no le tocan

⚠️ **Crear en AD on-prem, nunca en el centro de administración de M365.** El tenant es
híbrido; un usuario creado en la nube nace solo-en-nube y fusionarlo después exige un
hard-match por ImmutableID.

⚠️ **El login no es la dirección de correo.** El patrón de Maswer es `VValle`,
`AStangenberg`, `JPaschold@maswer.com` para iniciar sesión y `nombre.apellido@maswer.com`
como dirección. El alias nunca sirve para iniciar sesión — es lo que costó un día en el caso
`gabrera`. A Kevin se le entrega el UPN, no la dirección de correo.

**Sync:** `MEUAZAC011` → `Start-ADSyncSyncCycle -PolicyType Delta`. Sin prisa, el ciclo
automático corre cada 30 min.

**Licencia:** M365 admin → Usuarios activos → Licencias y aplicaciones. El buzón se
aprovisiona solo, no hay paso de "activar correo".

**Dirección de correo:** `proxyAddresses` en `MDERZADC003` con `-Add`/`-Remove`, nunca
`-Replace` de la colección — eso se lleva por delante la dirección de enrutado
`@maswer.mail.onmicrosoft.com` y rompe el flujo de correo. **`MEUAZEX001` no tiene Exchange**
(verificado 22-jul-2026: sin binarios, sin clave de Setup, sin servicios `MSExchange*`; los
cmdlets `*-RemoteMailbox` no existen ahí), así que no hay ruta por consola de Exchange.

**Móvil personal:** Intune → Directivas de protección de aplicaciones → iOS/Android →
Outlook → PIN obligatorio, bloquear copiar/guardar hacia apps no gestionadas → asignar al
grupo de Kevin. Si la SKU asignada no incluye Intune, la directiva no le aplicará y se verá
en el estado de la asignación.

**Entrega:** por teléfono, cuando llegue el móvil. Usuario = `KSantangelo@maswer.com`. Aviso
de que en el primer inicio de sesión pedirá cambiar contraseña y registrar la verificación.

---

## Cronología

| Fecha | Evento |
|---|---|
| 05-ago 13:37 | Ticket abierto. Petición de cuenta + credenciales al solicitante + dispositivo personal. Firmado "Can". |
| 06-ago 8:29 | Respuesta: la contraseña la fija el usuario; el dispositivo privado necesita OK de dirección; se piden nombre completo y fecha, sede/departamento y aprobador, móvil y si recibe equipo. |
| 06-ago 9:24 | Vincenzo responde: nombre, Maswer Deutschland GmbH / Kippenheim, solo correo, sin equipo, usa su teléfono. Sin fecha, sin aprobador, sin móvil. |

---

## Siguiente paso

1. Crear la cuenta en ADUC con el criterio de arriba — no depende de los datos que faltan.
2. Reclamar fecha de incorporación, móvil de Kevin y el visto bueno de la dirección para el
   teléfono personal. Si la incorporación queda lejos, dejar el objeto **deshabilitado y sin
   licencia** hasta el día de alta: ni se paga licencia ni queda una cuenta viva sin dueño.
3. La directiva de Intune, una vez confirmada la SKU libre del tenant.

## Abierto, más allá de este ticket

- **Kippenheim** no está en la documentación de sedes del repo.
- **No hay política BYOD** documentada del lado de Maswer. Este es el segundo caso que la
  pide (el primero, el acceso VPN desde Kosovo). Merece una decisión de la dirección, no una
  respuesta ticket a ticket.
- **Viene una tanda de altas.** Monta el formulario con los campos que faltaron aquí: nombre
  completo, fecha de incorporación, entidad, sede, departamento, quién aprueba, móvil de
  contacto y equipo sí/no.
