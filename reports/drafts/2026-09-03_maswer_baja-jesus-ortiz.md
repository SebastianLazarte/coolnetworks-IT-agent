# Reporte del caso — Maswer / Baja de Jesús Ortiz Rodríguez: bloqueo de correo y accesos + dispositivos en su poder

- **Cliente:** Maswer (Maswer AG)
- **Solicitante:** Vincenzo Valle (`vincenzo.valle@maswer.com`) — contacto IT de sede, vía portal
- **Empleado afectado:** Jesús Ortiz Rodríguez (`Jesus.Ortiz@maswer.com`)
- **Canal:** Freshworks (portal), hilo a nombre de "Jesus Ortiz Rodriguez"
- **Técnico:** Sebastian Lazarte (CoolNetworks — IT de Maswer)
- **Fechas:** ticket abierto 03-sep-2026 10:20 · reporte iniciado 03-sep-2026
- **Estado actual:** **ABIERTO.** Verificado en AD el 03-sep-2026: **la cuenta sigue habilitada y nunca se ha deshabilitado**; lo que se dio por hecho ("ya quitamos las cuentas y sus accesos") corresponde a la ronda anterior (Rohner/Conow), no a esta. Además, la dirección del ticket **no es una cuenta personal: es un buzón compartido**. Detalle en "Verificación en AD".

---

## Triage del ticket

| Campo | Valor |
|---|---|
| Categoría | Cuentas y Accesos (baja de empleado) |
| Prioridad | P2 - Alta — si la salida ya se produjo, hay credenciales vivas de un ex-empleado (correo + posible VPN). En duda entre P2 y P4 se sube |
| Grupo | N1 — dentro de nuestro alcance (AD on-prem + Exchange Online + Intune/Defender). No requiere conet.de |
| SLA inicial | Respuesta en 1 h |
| Escalado | No |

---

## Solicitud recibida

**03-sep 10:20** (original alemán):

> "Bitte sperrt die Mail & den Zugang für Jesus Ortiz Rodriguez komplett. ( Jesus.Ortiz@maswer.com )
> Der Mitarbeiter ist am 13.09.2026 aus dem Unternehmen ausgeschieden.
> Könnt ihr herausfinden ob der Mitarbeiter noch Arbeitsgeräte von unserer Firma nutzt wie Laptop oder Tablets?"

Traducción: bloquear por completo el correo y los accesos de Jesús Ortiz Rodríguez; el empleado
causó baja el 13.09.2026; y averiguar si sigue usando equipos de la empresa (portátil, tablets).

---

## Verificación en AD — 03-sep-2026

Consultado el dominio `intern.maswer.com` (PDC `MDERZADC004`) con el módulo `ActiveDirectory`.
Todo lo de esta sección es **lectura directa del directorio**, no inferencia.

### 1. La cuenta nunca se ha deshabilitado

| Dato | Valor leído |
|---|---|
| Cuenta | `JOrtiz` — "Jesus Ortiz", `jesus.ortiz@maswer.com`, UPN `JOrtiz@maswer.com` |
| Ubicación | `OU=SharedMailbox,OU=DE,OU=User Accounts,OU=Office365` — **OU de buzones compartidos** |
| Company | Maswer Deutschland GmbH · creada 15-feb-2024 |
| **Estado** | **`Enabled: True`** |
| **`userAccountControl`** | último cambio originante **15-feb-2024** (versión 4, desde `MEUAZDC011`) → **nunca se deshabilitó**, ni hoy ni antes |
| Contraseña | `pwdLastSet` = 29-oct-2025 — **no se ha reseteado** |
| Último inicio de sesión | 20-mar-2026 16:02 (`lastLogonTimestamp`, hasta 14 días de retraso de replicación) |
| Grupos | **ninguno**: cero valores de vínculo, actuales o borrados. Solo el grupo primario `Domain Users` |
| `SSL_VPN` | **no es miembro** (sí lo son `JAOrtiz`, `AOrtiz`, `HOrtiz` — otras personas) |
| Direcciones | `proxyAddresses` sin tocar desde 15-feb-2024; `msExchHideFromAddressLists` **sin marcar** → sigue visible en la libreta |

Comprobaciones que descartan que se hiciera "en otro sitio" del directorio:

- **Nada borrado:** la Papelera de reciclaje de AD está habilitada en los cuatro DCs y **no hay ningún objeto de usuario eliminado** que coincida con Ortiz/Jesus.
- **Ninguna baja de grupo en todo el dominio en 3 días:** ningún objeto de grupo tiene `whenChanged` posterior al 31-ago. Si se hubieran retirado accesos, el grupo lo registraría.
- Los objetos de usuario **sí** cambian a diario (25 en 3 días), así que la ausencia de cambios en `JOrtiz` no es un artefacto de la consulta.

**De dónde viene la impresión de "ya está hecho":** la ronda anterior sí se ejecutó — `FRohner` y
`SConow` figuran **`Enabled: False`** desde el 06-ago-2026. Ortiz no formaba parte de esa ronda.

### 2. Control cruzado — Schachow sigue pendiente

El cierre de baja que quedó listado ayer en el caso Schachow **tampoco está ejecutado**:
`JSchachow` está **habilitado**, **sigue en `SSL_VPN`** y **no está oculto de la libreta**
(`whenChanged` 13-abr-2026). Lo que sí se hizo ayer fue en la nube (delegación del buzón y regla de
flujo), que no toca AD. Va en la misma tanda que Ortiz.

### 3. El hallazgo que cambia el ticket: no es una cuenta personal

`msExchRecipientTypeDetails = 34359738368` (**RemoteSharedMailbox**), con **versión 1 y fecha de
creación** — es decir, el objeto **nació como buzón compartido** en feb-2024, no es un buzón personal
convertido al irse el empleado. Consecuencias directas:

- **No hay licencia que retirar** y no hay accesos de datos que quitar: nunca tuvo grupos.
- **Puede haber más gente usando esa dirección.** Los permisos de un buzón compartido se conceden en
  Exchange Online, no en AD, así que desde aquí no se ve quién más entra. Bloquear la entrega a ciegas
  puede cortar una función compartida, no la cuenta de una persona.
- **Contradicción a resolver:** un buzón compartido con contraseña propia (oct-2025) e inicio de sesión
  interactivo (mar-2026) significa que **alguien entra directamente con esa cuenta**. En la misma OU hay
  16 objetos, 12 habilitados y 5 con inicio de sesión registrado; `JOrtiz` es el más reciente de todos.
- **No aparece ninguna cuenta personal** para esta persona en el dominio: cero coincidencias por
  `Ortiz`/`Jesus`/`Rodrig` en CN o displayName, y la dirección del ticket solo resuelve a este objeto.
  Queda una vía sin comprobar: una **cuenta solo-nube en Entra** no se ve desde el AD on-prem.

---

## Lo que bloquea la ejecución

### 1. La fecha de baja no es coherente

El ticket dice **"ist am 13.09.2026 ausgeschieden"** — verbo en pasado, fecha **dentro de diez días**
(hoy es 03-sep-2026). Las dos lecturas posibles llevan a acciones distintas:

| Lectura | Qué implica |
|---|---|
| Errata de **13.08.2026** | Lleva tres semanas fuera con la cuenta viva → bloquear hoy, y revisar accesos del periodo |
| Baja **prevista** el 13.09.2026 | Sigue trabajando → bloquear ese día, no antes; cortarle el correo hoy le impide trabajar |

No se asume ninguna de las dos. Se pregunta al cliente por el último día trabajado.

### 2. Falta la autorización escrita

Un ticket del contacto de sede es una **petición, no una aprobación**. El bloqueo de accesos es un
cambio registrado, así que la confirmación de baja (RRHH/dirección, con fecha y remitente) se adjunta
al ticket **antes** de tocar la cuenta. Precedente inmediato: en el caso Schachow (01-sep) la línea
escrita de RRHH en el propio ticket sirvió como autorización documentada.

**Punto abierto de fondo, ya conocido:** sigue sin estar documentado **quién en Maswer aprueba** una
baja de accesos. Es el mismo hueco de la ronda Rohner/Conow, cuya fecha límite (01-sep-2026) acaba de
vencer — revisar ese hilo en la misma tanda.

---

## Plan de actuación

### Fase A — verificación en AD ✅ HECHA (03-sep-2026)

Resultado en "Verificación en AD": la cuenta sigue habilitada, sin grupos, sin VPN, sin ocultar,
contraseña de oct-2025, y el objeto es un buzón compartido, no una cuenta personal.

### Fase B — lo que falta comprobar, y solo se ve en la nube (hacer antes de bloquear)

3. En **Exchange Online**, `Get-MailboxPermission Jesus.Ortiz@maswer.com` y `Get-RecipientPermission`:
   **quién más tiene acceso a ese buzón compartido.** Es lo que decide si bloquear la entrega corta a
   una persona que se fue o a una función que sigue viva.
4. En **Entra ID / `admin.microsoft.com`**, buscar "Ortiz" entre los usuarios: comprobar si existe una
   **cuenta solo-nube** a nombre de esta persona (no se sincroniza desde AD y por eso no se ve on-prem),
   y revisar licencias e inicios de sesión de los últimos 90 días.

### Fase C — ejecución (con fecha confirmada + autorización en el ticket)

5. `Disable-ADAccount JOrtiz`, contraseña a valor aleatorio y `msExchHideFromAddressLists = $true`
   **en AD** (híbrido: no se edita en M365) → `Start-ADSyncSyncCycle -PolicyType Delta` en
   `MEUAZAC011`. Con **PTA** el corte de autenticación es inmediato tras el sync; además
   `Revoke-MgUserSignInSession` para tumbar sesiones ya abiertas. No hay grupos que quitar.
   ⚠️ Deshabilitar la cuenta **no** quita el buzón a sus delegados: entran con su propia identidad.
6. Cortar la entrada de correo con **regla de flujo** en Exchange Online, no borrando direcciones
   (`New-TransportRule … -RejectMessageEnhancedStatusCode 5.7.1`) — **solo si el paso 3 confirma que
   nadie más usa la dirección**. Reversible en un clic y deja registro.
   ⚠️ No borrar el buzón. Verificar antes qué retiene la copia de Hornetsecurity/Altaro 365.
7. **Misma tanda, caso Schachow:** `JSchachow` sigue habilitado, en `SSL_VPN` y visible en la libreta.
   Quitar del grupo, deshabilitar, ocultar y sincronizar.

### Fase C — dispositivos (respuesta a la segunda pregunta)

6. Cruzar cuatro fuentes y montar la lista con nombre, modelo, número de serie y última conexión:
   `admin.microsoft.com` → Usuarios → ficha → **Dispositivos**; Entra ID → usuario → Dispositivos;
   Intune → filtrar por **usuario principal**; Defender → *Advanced hunting* →
   `DeviceLogonEvents` por `AccountName` (90 días). Objetos de equipo en AD como contraste.

**Límite que hay que decir claro:** las consolas solo ven lo que está inscrito o unido al dominio.
Un portátil sí; **una tablet o un móvil que nunca se registró no aparece en ningún sitio**, y ninguna
consola dice **quién tiene físicamente** el aparato — solo cuándo se vio por última vez. Esa columna
la rellena Maswer, no nosotros.

---

## Acciones pendientes

| Acción | Estado | Cuándo |
|---|---|---|
| Fase A — verificación en AD | ✅ hecha 03-sep-2026 | — |
| Fecha real del último día trabajado (13.08 vs 13.09) | preguntado al cliente | bloqueante |
| Confirmación escrita de la baja adjunta al ticket | preguntado al cliente | bloqueante |
| **Quién más usa el buzón compartido `Jesus.Ortiz@maswer.com`** (EXO + preguntar a Vincenzo) | pendiente | **bloqueante para el bloqueo de correo** |
| Buscar cuenta solo-nube a nombre de Ortiz en Entra ID | pendiente | inmediato, no bloqueante |
| Fase C — deshabilitar, ocultar, sincronizar, regla de flujo | pendiente | tras confirmación |
| Lista de dispositivos (Entra/Intune/Defender) + envío a Vincenzo | pendiente | inmediato, no bloqueante |
| Quién hereda el correo y qué se conserva — **fecha límite 01-oct-2026** | preguntado al cliente | silencio ≠ aprobación: el ticket queda abierto |
| **Cierre de la baja de Schachow** (SSL_VPN, disable, ocultar, sync) | pendiente desde el 02-sep | misma tanda |
| Revisar el hilo Rohner/Conow — cuentas ya deshabilitadas el 06-ago, plazo vencido el 01-sep-2026 | pendiente | misma tanda |

---

## Respuesta al cliente (borrador, inglés)

> Hi Vincenzo,
>
> Jesus has no access to any of our devices. His account has not signed in to a company machine since 20 March. A laptop or tablet that was handed to him without ever being registered with us would not show up in any of our systems, so that part has to be checked against your own handover list.
>
> Two things before we close the mail side:
>
> 1. His last working day. The ticket says 13.09.2026, and that date is still ten days away. Send it to us in writing — the leaving confirmation from HR is enough, we keep it with the ticket.
> 2. Jesus.Ortiz@maswer.com is not a personal mailbox, it is a shared one. Tell us who else works with it, so we don't close an address other people still use.
>
> Best,
> CoolNetworks Support

**Base de cada frase:** "no ha iniciado sesión desde el 20 de marzo" = `lastLogonTimestamp` leído en AD
(±14 días de replicación). "No tiene acceso a ningún equipo" lo aporta el técnico; desde el directorio
solo consta que **ningún objeto de equipo en AD lo referencia**, y los equipos de Maswer no llevan el
nombre de la persona, así que la comprobación buena es Intune/Entra (usuario principal) + Defender
(`DeviceLogonEvents`). Queda además la contradicción abierta: mientras `JOrtiz` siga habilitado con su
contraseña de oct-2025, "sin acceso" es cierto de hecho, no de derecho.

---

## Notas para casos similares

- **Una fecha de baja en el futuro escrita en pasado no se interpreta, se pregunta.** Cortar el correo
  a alguien que aún trabaja y dejar viva la cuenta de alguien que ya se fue son errores simétricos.
- **Bloquear ≠ borrar.** Cuenta deshabilitada + regla de flujo + licencia intacta deja todo reversible
  y auditable; borrar direcciones o buzones en híbrido es difícil de revertir.
- **La pregunta "¿qué equipos tiene?" se responde en dos mitades:** la nuestra (qué dispositivos
  registrados usó su cuenta) y la del cliente (qué hay físicamente sin devolver). Prometer solo la primera.
- **"Ya está hecho" se comprueba, no se firma.** El estado real se lee en dos consultas:
  `Get-ADUser <sam> -Properties Enabled,whenChanged` y, sobre todo,
  `Get-ADReplicationAttributeMetadata -Object <dn> -Server <PDC>`, que dice **cuándo cambió
  `userAccountControl` por última vez**. Si esa fecha es la de creación, la cuenta nunca se
  deshabilitó, diga lo que diga la memoria del equipo. Para los accesos, `-ShowAllLinkedValues`
  muestra también los grupos **retirados** y su fecha; si no hay vínculos, no había nada que quitar.
- **Trampa de la consulta:** `Get-ADUser -Filter "whenChanged -ge 'yyyy-MM-dd'"` con la fecha como
  cadena devuelve **cero resultados sin error** — parece "no ha cambiado nada" cuando sí. Hay que
  pasar una variable `[datetime]`: `$cut = (Get-Date).AddDays(-3); Get-ADUser -Filter { whenChanged -ge $cut }`.
- **Un buzón compartido no se trata como una baja.** Si el objeto nació como `RemoteSharedMailbox`
  (`msExchRecipientTypeDetails = 34359738368`, versión 1), no hay licencia ni accesos personales que
  retirar y puede haber terceros dependiendo de la dirección: primero `Get-MailboxPermission`, después
  bloquear. Y una cuenta de buzón compartido **con contraseña propia e inicios de sesión** es un
  hallazgo por sí sola: esas cuentas deberían estar deshabilitadas.
- **Falta un runbook de bajas** en `reference/` — hoy solo existe el de altas. Con Schachow, Rohner,
  Conow y Ortiz en cinco semanas, y dos cierres a medias detectados hoy, el procedimiento ya está
  estabilizado y merece ficharse.

---

**Referencias internas:** [[leaver-accounts-disable-not-delete]] · [[maswer-ad-domain-infra]] · [[maswer-servers-inventory]] · [[maswer-exchange-hybrid]] · [[maswer-aad-connect-server]] · [[maswer-vpn-sophos]] · [[maswer-m365-backup]] · [[maswer-calden-contacts]] · [[maswer-diagnostico-endpoint-sin-live-response]] · [[reply-tone-direct-not-nice]]
