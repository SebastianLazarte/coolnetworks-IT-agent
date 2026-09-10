# Reporte del caso — Maswer / Alta de Luis Joel Cervantes Lopez

- **Cliente:** Maswer México (site Puebla)
- **Usuario final:** Luis Joel Cervantes Lopez — Supervisor de Calidad, área Proyectos
- **Solicita:** Florencio Olguín (AGU) · CC: Andrea Muñoz (PBC)
- **Técnico:** Sebastian Lazarte Castellón (CoolNetworks)
- **Fecha:** 07-sep-2026
- **Estado:** **EN CURSO** — cuenta AD creada y **verificada en los 4 DCs**; pendiente
  confirmar alta en M365 + licencia

---

## Triaje

| Campo | Valor |
|---|---|
| Categoría | Accounts and Access (alta de usuario) |
| Prioridad | P3 - Media (4 h respuesta / 2 días resolución) |
| Grupo | N1 |
| Escalado | No |

---

## Convención aplicada (deducida del sitio, no inventada)

Muestreo de las 12 altas más recientes de `OU=PBC` y volcado completo de `AMunoz` y `DMunoz`
(alta más reciente del sitio, 04-mar-2026):

| Atributo | Patrón en PBC | Valor aplicado |
|---|---|---|
| `sAMAccountName` / `UPN` | inicial + primer apellido | `LCervantes` / `LCervantes@maswer.com` |
| `mail` (SMTP principal) | nombre.primerapellido, minúsculas, sin acentos | `luis.cervantes@maswer.com` |
| `mailNickname` | = `sAMAccountName` | `LCervantes` |
| `targetAddress` | `SMTP:<sam>@maswerag.onmicrosoft.com` | `SMTP:LCervantes@maswerag.onmicrosoft.com` |
| `givenName` / `sn` | minúsculas, solo primer nombre y primer apellido | `luis` / `cervantes` |
| Tipo de destinatario | `RemoteUserMailbox` | `2147483648` / `-2147483642` / `1` |
| País | `co=Mexico`, `c=MX`, `countryCode=484` | aplicado |

> Ojo: la convención de correo de **MX** (`nombre.apellido`) **no** es la de BCN
> (`NombresConcatenados.ApellidosConcatenados`, caso Calvo). Se confirmó contra el sitio,
> no contra el alta anterior.

**Grupos base del sitio** — frecuencia sobre los 29 usuarios activos de PBC:
`MFA-MASWER` (28), `Masw_ALL_Intranet_R` (27), `TPLINK_User` / `SSL_VPN` / `Webfilter_Standard` (26).
`MaswMEX-AzureFiles-RWD` solo lo tienen 6 → **no es base**, no se asignó.

---

## Acción ejecutada — 07-sep-2026 20:39

`New-ADUser` contra `MDERZADC003`, en
`OU=PBC,OU=MX,OU=User Accounts,OU=Office365,DC=intern,DC=maswer,DC=com`.

- Pre-flight sin colisiones: no existía ningún objeto con ese `sAMAccountName`, UPN, `mail`,
  `proxyAddresses` ni CN. El único "Cervantes" del dominio es `ACaballero` (Alan Noe Caballero
  Cervantes, PBC, **deshabilitado**) — apellido materno, no es la misma persona.
- `proxyAddresses`: `SMTP:luis.cervantes@maswer.com` (principal),
  `smtp:luis.cervantes@maswerag.mail.onmicrosoft.com`, `smtp:LCervantes@maswerag.onmicrosoft.com`
- Grupos base añadidos: `Masw_ALL_Intranet_R`, `MFA-MASWER`, `SSL_VPN`, `TPLINK_User`,
  `Webfilter_Standard`
- Contraseña inicial aleatoria (no se registra aquí; se entrega por canal aparte). Se creó con
  **cambio obligatorio en el primer inicio de sesión** — decisión equivocada para este entorno,
  ver el segundo incidente más abajo; se revirtió a las 22:3x.
- Replicación inicial: `MDERZADC003` y `MDERZADC004` inmediatos; los DCs de Azure, no
  (ver incidente abajo).

### Atributos de Exchange puestos a mano — justificación

`MEUAZEX001` **sigue sin ser alcanzable** desde el equipo del técnico (5985 y 443 cerrados), así
que no se pudo usar `Enable-RemoteMailbox`, que es la vía soportada. Se replicaron exactamente
los atributos de `DMunoz` / `AMunoz` (misma OU, patrón completo). **Conviene que conet.de lo
verifique en el servidor de Exchange.**

---

## Incidente durante el alta — el usuario no aparecía en M365

Tras forzar `Start-ADSyncSyncCycle -PolicyType Delta`, la cuenta **seguía sin aparecer** en la
lista de usuarios de M365.

**Observado (20:54, 15 min después del alta):**

| DC | Sitio | ¿Tiene el objeto? |
|---|---|---|
| `MDERZADC003` | Default-First-Site-Name | sí |
| `MDERZADC004` | Default-First-Site-Name | sí |
| `MUSAZDC011` | Azure-Site-US | sí |
| `MEUAZDC011` | **Azure-Site** (EU) | **no** |

`MEUAZDC011` tiene un **único partner de replicación entrante** en la partición de dominio:
`MUSAZDC011`. Su última réplica correcta fue a las **20:40:16** — un minuto después del alta, o
sea *antes* de que el objeto llegara al DC de EE. UU. La siguiente réplica intersitio aún no
había ocurrido. Cadena real: `MDERZADC003` → `MUSAZDC011` → `MEUAZDC011`.

**Inferencia (no verificada en consola):** `MEUAZAC011` lee del DC de su propio sitio,
`MEUAZDC011`. Encaja con el síntoma — el motor de sync no puede exportar lo que no ve en su
import. Se confirma en *Synchronization Service Manager* → **Connectors** → conector de AD →
*Properties* → DC fijado. No pude comprobarlo yo: la ejecución remota contra `MEUAZAC011` está
bloqueada desde mi entorno.

**Solución aplicada — 20:55:**

```powershell
Sync-ADObject -Object "CN=Luis Joel Cervantes Lopez,OU=PBC,OU=MX,OU=User Accounts,OU=Office365,DC=intern,DC=maswer,DC=com" `
              -Source MUSAZDC011.intern.maswer.com -Destination MEUAZDC011.intern.maswer.com
```

Replicación de objeto único, sin tocar topología ni forzar un `repadmin /syncall`. Objeto
presente en `MEUAZDC011` de inmediato.

> **Patrón, no caso aislado:** en el alta de Héctor Calvo (04-sep) los DCs de Azure también
> quedaron pendientes. Cualquier alta que se cree contra `MDERZADC003` tarda en llegar al DC
> desde el que lee AAD Connect. **Para futuras altas: `Sync-ADObject` hacia `MEUAZDC011` antes
> de lanzar el Delta**, y el usuario aparece en el primer ciclo.

---

## Verificación final — 20:56

- Objeto presente en los **4 DCs** (`MDERZADC003`, `MDERZADC004`, `MUSAZDC011`, `MEUAZDC011`).
- `Enabled = True`, `LockedOut = False`. (`pwdLastSet = 0` en ese momento; revertido después —
  ver el segundo incidente.)
- `mail`, `mailNickname`, `targetAddress`, `proxyAddresses` (un solo SMTP en mayúsculas),
  los tres atributos `msExch*` y `co`/`c`/`countryCode`: coinciden con el patrón de `DMunoz`.
- Los 5 grupos base, ninguno de más.
- **No verificado desde aquí:** que el objeto haya llegado a Entra/M365 y el estado de la
  licencia. Requiere el centro de administración o Graph con sesión iniciada.

---

## Pendiente — en este orden

1. **Relanzar el sync** en `MEUAZAC011`: `Start-ADSyncSyncCycle -PolicyType Delta`, ya con el
   objeto visible en `MEUAZDC011`. Si aún no aparece: *Operations* (¿el `Import` trae `adds`?,
   ¿el `Export` a `maswerag.onmicrosoft.com` da error?) y disco C: del servidor.
2. **Asignar la licencia** en el centro de administración M365 → Usuarios activos →
   *Luis Joel Cervantes Lopez* → Licencias. Misma SKU que sus compañeros de Puebla
   (Microsoft 365 Empresa Premium, ver `memory/maswer-m365-copilot-licensing.md`). El buzón se
   aprovisiona solo al asignarla.
3. **Entregar credenciales** al usuario por canal aparte (nunca por el ticket).
4. ~~**Confirmar el sitio real.**~~ **Descartado — no afecta.** El asunto dice *supervisor de
   Querétaro* y el cuerpo *SITE PUEBLA*, pero la OU de sitio no cambia nada técnico: **ninguna
   OU de la rama tiene GPO enlazada** (`gPLink` vacío en `PBC`, `MTY`, `AGU`, `MX`,
   `User Accounts` y `Office365`, verificado 08-sep). Las GPO bajan de nivel dominio y se filtran
   **por grupo de seguridad**, y los grupos de México son de entidad (`MaswMex_*`), no de sitio.
   Tampoco existe OU de Querétaro ni ningún objeto del dominio que lo mencione. La OU es
   organizativa; si hiciera falta, un `Move-ADObject` y el usuario ni se entera.
   ⚠️ **Corrección:** la primera versión de este informe decía que el sitio cambiaba las unidades
   de red mapeadas por GPO. Es falso para estas OUs.
5. **Accesos de Calidad / Proyectos:** no asignados. Los 5 grupos base no dan acceso a ninguna
   carpeta de proyecto. Existen `MaswMex_QM_R` / `MaswMex_QM_RW`,
   `MaswMex_Projects_Operations_RW` y `MaswMex_Projects_Business_RW` — hace falta que el cliente
   diga a cuáles debe entrar y con qué nivel.
6. **Equipo:** el ticket no menciona portátil ni alta de equipo. Si lo hay, precrear el objeto en
   la OU de clientes de PBC (no dejarlo caer en `CN=Computers`, no le llegarían las GPO).

---

## Segundo incidente — "La organización no permite actualizar la contraseña en este sitio"

**22:21.** El usuario intenta entrar en M365 y recibe ese mensaje. Que llegue a la pantalla de
inicio de sesión confirma, de paso, que el objeto **sí** había llegado a Entra.

**Causa:** la cuenta se creó con `-ChangePasswordAtLogon $true` (`pwdLastSet = 0`). El dominio
autentica por **PTA**: la contraseña vive solo en el AD on-prem y M365 no puede cambiarla sin
*password writeback* (SSPR, Entra ID P1), que no está activado. El portal responde exactamente
ese texto y el usuario queda bloqueado — no tiene todavía equipo unido al dominio, que es el
único sitio donde podría cambiarla.

**El entorno ya lo decía y no lo leí al crear la cuenta:** en PBC, **0 de 30** cuentas activas
tenían la marca de cambio obligatorio y **28 de 30** tienen `PasswordNeverExpires = True`.
El sitio está montado para no forzar el cambio, precisamente por esto. `MaxPasswordAge` del
dominio es `00:00:00`, así que la marca no aportaba nada funcional.

**Resuelto — 22:3x**, ejecutado por el técnico:

```powershell
Set-ADUser -Server MDERZADC003 -Identity LCervantes -ChangePasswordAtLogon $false
Set-ADUser -Server MDERZADC003 -Identity LCervantes -PasswordNeverExpires $true
Sync-ADObject -Object "<DN>" -Source MDERZADC003.intern.maswer.com -Destination MEUAZDC011.intern.maswer.com
Sync-ADObject -Object "<DN>" -Source MDERZADC003.intern.maswer.com -Destination MUSAZDC011.intern.maswer.com
```

El `Sync-ADObject` no es opcional: el agente de PTA pregunta al DC de su sitio, así que sin
empujar el cambio seguiría viendo el estado viejo. Verificado: `pwdLastSet` puesto y
`PasswordNeverExpires = True` en los **4 DCs**.

> **Regla para las próximas altas** (indicada por el técnico, 07-sep-2026): crear siempre con
> `-ChangePasswordAtLogon $false` y `-PasswordNeverExpires $true`. La contraseña inicial se
> entrega fuera del ticket y el usuario la cambia cuando tenga equipo en el dominio
> (Ctrl+Alt+Supr → *Cambiar contraseña*), nunca desde el portal.

---

## Tercer incidente — 35 intentos fallidos de contraseña (08-sep, madrugada)

**Observado a las 10:40 del 08-sep**, contadores por DC:

| DC | `badPwdCount` | Último fallo | Último logon correcto |
|---|---|---|---|
| `MEUAZDC011` | 22 | 08-sep 01:38 | 08-sep 00:29 |
| `MDERZADC004` | 12 | 08-sep 01:38 | nunca |
| `MUSAZDC011` | 1 | 07-sep 23:54 | 07-sep 22:48 |
| `MDERZADC003` | 0 | ninguno | nunca |

La cuenta **no llegó a bloquearse**: `LockoutThreshold = 0` en la política de dominio, no se
bloquea nunca. Y hubo **dos autenticaciones correctas**, así que la credencial era válida — se
estaba tecleando mal.

**Causa: la contraseña generada era mala para transcribir.** `pU4a@7HFkXlX8nDX` contiene una
**`l` minúscula entre dos equis** (indistinguible de `I` o `1` por chat) y una **`@`**, que en
teclado español/latino es AltGr+Q. Error mío al generarla.

No se pudo determinar el origen de los intentos: la lectura remota del registro de seguridad de
los DCs falla con *"El servidor RPC no está disponible"* (puertos cerrados desde el equipo del
técnico). Por tanto **no se distingue** entre una persona tecleando mal y un dispositivo
reintentando con credencial cacheada.

**Resuelto — 08-sep 10:41:** `Set-ADAccountPassword -Reset` con una contraseña sin símbolos ni
caracteres ambiguos (mayúsculas + minúsculas + dígitos ya cumplen la complejidad: 3 de 5
categorías), replicada con `Sync-ADObject` a los 3 DCs restantes. `PasswordNeverExpires` sigue en
`True` y no hay cambio obligatorio.

> **Para las próximas altas:** contraseña inicial **dictable** — sin `@`, sin `l`/`I`/`1`/`O`/`0`
> sueltos. Palabras + dígitos cumplen la política del dominio de sobra.

---

## Pendiente de confirmar con el usuario

1. Si tras el cambio de contraseña **sigue sin entrar**, ya no es autenticación. Los dos
   sospechosos son la **licencia sin asignar** (sin licencia no hay buzón: entra al portal pero
   no tiene correo) y el **registro de MFA** (la cuenta está en `MFA-MASWER`).
2. Hace falta el **texto exacto del error** y dónde sale (portal de inicio de sesión, Outlook,
   móvil). Sin eso no se puede separar un caso del otro.
