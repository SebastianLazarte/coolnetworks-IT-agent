# Reporte del caso — Maswer / Baja de Jewgenij Schachow: acceso al buzón y bloqueo de la dirección

- **Cliente:** Maswer (Maswer AG)
- **Solicitante:** Stefanie Zimmermann (`SZimmermann`, `stefanie.zimmermann@maswer.com`) — RRHH, sede Hennef (HEF)
- **En copia:** Vincenzo Valle (`vincenzo.valle@maswer.com`)
- **Canal:** Freshworks (portal), hilo a nombre de "Miguel Ángel Rubira García"
- **Técnico:** Sebastian Lazarte (CoolNetworks — IT de Maswer)
- **Fechas:** ticket abierto 01-sep-2026 08:35 · última actuación 02-sep-2026
- **Estado actual:** RESUELTO en lo solicitado. **Sin pérdida de datos, sin incidente de seguridad, sin borrado de cuentas.** Quedan acciones de cierre de la baja (ver "Acciones pendientes").

---

## Triage del ticket

| Campo | Valor |
|---|---|
| Categoría | Cuentas y Accesos (delegación de buzón + baja de empleado) |
| Prioridad | P3 - Media (petición planificada, la solicitante no está bloqueada) |
| Grupo | N1 — resuelto en primer contacto |
| SLA inicial | Respuesta en 4 h — cumplido |
| Escalado | No. No hizo falta conet.de: todo dentro de nuestro alcance (AD + Exchange Online) |

---

## Solicitud recibida

**01-sep 08:35** (original alemán):

> "bei mir im Profil für die IT steht Maswer-Espana, dies bitte auf Deutschland umstellen. Und bitte das komplette Postfach für Jewgenij Schachow für mich freischalten."

Traducción: (1) su perfil figura como *Maswer-Espana* y debe pasar a Alemania; (2) pide acceso al **buzón completo** de Jewgenij Schachow.

**01-sep 11:10** — a nuestra pregunta: *"Jewgenij Schachow arbeitet nicht mehr in unserem Unternehmen."* (ya no trabaja en la empresa).

**02-sep 08:26** — petición adicional: *"Können Sie bitte einstellen, dass auf diese E-Mail-Adresse auch keine Mails mehr zugestellt werden können."* (que esa dirección deje de recibir correo).

---

## Cronología

| Fecha | Evento |
|---|---|
| 01-sep 08:35 | Zimmermann abre el ticket: corregir su perfil + acceso al buzón de Schachow. |
| 01-sep | Se le pregunta por la situación laboral de Schachow antes de tocar nada. |
| 01-sep 11:10 | Confirma **por escrito** que Schachow ya no trabaja en Maswer. Queda como autorización documentada en el ticket. |
| 01-sep | Verificación en AD. La búsqueda por el nombre del ticket ("Yevgeny Shakhov") **no devuelve nada** — ver "Nota sobre el nombre". |
| 01-sep | Localizada la cuenta real `JSchachow` y verificada la de la solicitante (`SZimmermann`). |
| 01-sep | Concedido `FullAccess` sobre el buzón de Schachow a Zimmermann y verificado. |
| 02-sep 08:26 | Zimmermann pide bloquear la entrega de correo a esa dirección. |
| 02-sep 07:40 GMT | Creada la regla de flujo de correo que rechaza los envíos a esa dirección. Verificada: `Enabled` / `Enforce`. |

---

## Nota sobre el nombre — por qué la primera búsqueda no encontró nada

El ticket llegó traducido por Freshworks y mostraba **"Yevgeny Shakhov"**. Ese nombre **no existe en el directorio**: es la transliteración inglesa que hace la vista traducida del portal. El original alemán de la clienta dice **"Jewgenij Schachow"**, que es la grafía real de la cuenta.

**Regla para el futuro: buscar siempre en AD por la grafía del texto original, no por la traducción de Freshworks.** Con nombres eslavos, turcos o árabes la traducción del portal cambia la transliteración y la búsqueda devuelve cero, lo que puede leerse por error como "esa persona no existe".

---

## Trabajo realizado

### 1. Perfil de la solicitante — el error no estaba en el AD

Verificado en el directorio: `SZimmermann` tiene `Company = Maswer AG`, `OU=HEF,OU=DE` (Hennef, Alemania). **El AD era correcto y no se tocó.** Lo que estaba mal es su **ficha de contacto en Freshworks**, asociada a la compañía "Maswer spain" en vez de "Maswer Alemania" — el caso ya documentado en la estructura de entidades del helpdesk: se corrige en la ficha del contacto (Contactos → contacto → Editar → Empresa + Idioma), no en Admin → Empresas.

### 2. Estado real de la cuenta de Schachow (verificado en AD, 01-sep)

| Dato | Valor |
|---|---|
| Cuenta | `JSchachow` — Jewgenij Schachow |
| Correo | `Jewgenij.Schachow@maswer.com` — buzón en **Exchange Online** (`RemoteUserMailbox`) |
| Ubicación | `OU=RUM,OU=DE,OU=User Accounts,OU=Office365` (Rüsselsheim) |
| Creada | 23-oct-2024 |
| **Último inicio de sesión** | **07-abr-2026** (~5 meses antes del ticket) |
| Contraseña cambiada | 13-abr-2026 — **posterior** a su último acceso |
| Estado al abrir el ticket | **Activa**, y miembro del grupo `SSL_VPN` |

La lectura es directa: **la baja se empezó en abril y se dejó a medias.** Alguien le cambió la contraseña el 13-abr —gesto típico de offboarding— pero la cuenta quedó habilitada y con acceso VPN durante cinco meses. Es el mismo patrón ya documentado con la cuenta de Oliver Orth.

**Sus 11 grupos, separados por naturaleza:**

- **Datos (7)** — el "acceso" que se replicaría a un sustituto: `Masw_ALL_Intranet_R`, `MaswDEAG_Recruiting_RW`, `MaswDEAG_Vorlagen_R`, `MaswDEAG_Vorlagen_RW`, `MaswDEGMBH_Projekte_Commercial_RW`, `MaswDEGMBH_Projekte_Commercial_Qualifikationsmatrix MA_RW`, `MaswDEGMBH_Transition Spanish Employees_RW`
- **Infraestructura (4)** — nunca se copian: `SSL_VPN`, `MFA-MASWER`, `TPLINK_User`, `Webfilter_Standard`

### 3. Acceso al buzón — ejecutado y verificado

```powershell
Add-MailboxPermission -Identity Jewgenij.Schachow@maswer.com `
  -User stefanie.zimmermann@maswer.com -AccessRights FullAccess -AutoMapping:$true
```

Verificado con `Get-MailboxPermission`: `User: SZimmermann@maswer.com`, `AccessRights: {FullAccess}`, `IsInherited: False`.

Se eligió `AutoMapping:$true` (y no `$false`, como en accesos administrativos temporales) porque es una entrega definitiva a una usuaria no técnica: el buzón le aparece solo en su Outlook, sin que tenga que añadirlo a mano.

### 4. Bloqueo de la entrega — ejecutado y verificado

No se borró la dirección ni se tocaron los `proxyAddresses` del AD. Se creó una **regla de flujo de correo** en Exchange Online, que es reversible en un clic y deja registro:

```powershell
New-TransportRule -Name "Leaver - Schachow - reject inbound" `
  -SentTo "Jewgenij.Schachow@maswer.com","JSchachow@maswerag.onmicrosoft.com" `
  -RejectMessageReasonText "This address is no longer in use." `
  -RejectMessageEnhancedStatusCode 5.7.1
```

Verificada: `State: Enabled`, `Mode: Enforce`, prioridad 16. Quien escriba a esa dirección recibe un rebote indicando que ya no está en uso; el buzón sigue existiendo y Zimmermann conserva el acceso al histórico.

---

## Estado final

**RESUELTO** en las tres peticiones de la clienta. **Sin pérdida de datos, sin incidente de seguridad, sin incumplimiento de plazos.** No se borró ninguna cuenta ni ningún buzón.

### Acciones pendientes

| Acción | Estado | Cuándo |
|---|---|---|
| Cambiar la ficha de Freshworks de Zimmermann a *Maswer Alemania* + idioma alemán | **a confirmar que está hecho** | inmediato |
| Quitar `JSchachow` del grupo `SSL_VPN` | pendiente | inmediato |
| `Disable-ADAccount JSchachow` + ocultar de la libreta (`msExchHideFromAddressLists` en AD, no en M365) + `Start-ADSyncSyncCycle -PolicyType Delta` en `MEUAZAC011` | pendiente | inmediato |
| **No retirar la licencia** del buzón — si se retira, desaparece el buzón que acaba de recibir Zimmermann | — | hasta el cierre |
| Convertir el buzón a **compartido** cuando Maswer confirme qué se conserva: ella lo sigue viendo igual y se libera la licencia | pendiente | tras confirmación |
| Respuesta de Zimmermann a la pregunta de si el rebote debe indicar una dirección alternativa | esperando | — |

---

## Respuestas al cliente

Redactadas en **alemán**, excepción acordada expresamente con el técnico (la norma del repositorio es responder en inglés a los tickets alemanes), por no constar que la clienta hable inglés.

**Tras conceder el acceso (01-sep):**

> Guten Tag Frau Zimmermann,
>
> Ihr Profil steht jetzt auf Maswer Deutschland.
>
> Das komplette Postfach von Jewgenij Schachow ist für Sie freigeschaltet. Es erscheint automatisch in Ihrem Outlook — das kann bis zu einer Stunde dauern. Falls es danach nicht sichtbar ist, schließen Sie Outlook bitte einmal komplett und öffnen es neu.
>
> Viele Grüße
> CoolNetworks Support

**Tras bloquear la dirección (02-sep):**

> Guten Morgen Frau Zimmermann,
>
> die Adresse von Herrn Schachow ist gesperrt. Neue Nachrichten werden nicht mehr zugestellt; Absender erhalten automatisch die Rückmeldung, dass die Adresse nicht mehr verwendet wird. Die Umstellung kann bis zu 30 Minuten dauern. Auf das Postfach selbst haben Sie weiterhin Zugriff.
>
> Soll in dieser Rückmeldung eine Ersatzadresse genannt werden, an die sich Absender wenden können?
>
> Viele Grüße
> CoolNetworks Support

---

## Riesgo a señalar a dirección — no es un caso aislado

El caso Schachow destapó un patrón. Barrido del grupo `SSL_VPN` el 03-sep-2026:

> **De las 217 cuentas con acceso VPN, 64 están habilitadas y no registran inicio de sesión desde hace más de 90 días.** Doce de ellas no registran ninguno. Las más antiguas datan de **2020**.

Qué es dato verificado y qué no:

- **Verificado:** la cuenta está habilitada, pertenece a `SSL_VPN` y su `lastLogonTimestamp` es anterior a 90 días o está vacío.
- **No verificado:** que todas sean bajas. En la lista hay cuentas funcionales y compartidas (compras, nóminas, teamleaders, cuentas de sede) que pueden ser legítimas, y `lastLogonTimestamp` se replica con hasta 14 días de retraso. Entre ellas figura también `conetadm`, cuenta del proveedor.
- **Lo que lo resolvería:** el **listado de empleados activos de RRHH**. El directorio dice qué cuentas existen y cuándo se usaron por última vez; nunca dice quién sigue contratado. Esa columna solo la puede rellenar Maswer.

**Recomendación:** una sola ronda de depuración, con hoja de confirmación (una fila por cuenta: último acceso, titular supuesto, columna vacía "¿sigue en uso?"), una fecha límite común, y nada se borra — se deshabilita y se retiene. Pedir el listado a través de Vincenzo Valle. El coste hoy de no hacerlo es que cada cuenta de esas es una vía de acceso remoto viva a la red de Maswer a nombre de alguien que quizá ya no trabaja allí.

---

## Notas para casos similares

- **La traducción de Freshworks cambia los nombres propios.** Buscar en AD siempre por el original.
- **Nunca borrar la dirección para "cortar el correo".** En híbrido los `proxyAddresses` son del AD on-prem y el borrado es difícil de revertir. Una regla de flujo de correo hace lo mismo, es reversible y queda registrada.
- **`RejectMessageEnhancedStatusCode` solo admite `5.7.1` o el rango `5.7.900`–`5.7.999`.** Cualquier otro código (p. ej. `5.1.1`) hace fallar la creación de la regla. Usar un código del rango libre si se quiere distinguir después en los registros de mensajes.
- **Bloquear la entrega y deshabilitar la cuenta no chocan con la delegación.** El delegado entra con su propia identidad: se puede deshabilitar al empleado que se va sin quitarle el buzón a quien lo hereda. Lo único intocable es la **licencia**.
- **Separar siempre los grupos de datos de los de infraestructura** al replicar accesos de un sustituto. `SSL_VPN`, `MFA-MASWER` y el resto no se copian nunca por herencia.

---

**Referencias internas:** [[maswer-ad-domain-infra]] · [[maswer-servers-inventory]] · [[maswer-exchange-hybrid]] · [[maswer-access-via-ad-security-groups]] · [[leaver-accounts-disable-not-delete]] · [[oliver-orth-admin-accounts-still-enabled]] · [[freshworks-entity-structure]] · [[maswer-vpn-sophos]]
