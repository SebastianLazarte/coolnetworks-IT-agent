# Reporte del caso — Maswer / Alta de Alex Quijano Reyes

- **Cliente:** Maswer México (site Puebla)
- **Usuario final:** Alex Quijano Reyes — Ingeniero IT México-USA
- **Solicita:** Florencio Olguín (AGU) · CC: Andrea Muñoz (PBC, 222 347 0540)
- **Técnico:** Sebastian Lazarte Castellón (CoolNetworks)
- **Fecha:** 08-sep-2026
- **Estado:** **EN CURSO** — cuenta AD creada y replicada a los 4 DCs; pendiente sync + licencia

---

## Triaje

| Campo | Valor |
|---|---|
| Categoría | Accounts and Access (alta de usuario) |
| Prioridad | P3 - Media (4 h respuesta / 2 días resolución) |
| Grupo | N1 |
| Escalado | No |

---

## Acción ejecutada — 08-sep-2026

`New-ADUser` contra `MDERZADC003`, en
`OU=PBC,OU=MX,OU=User Accounts,OU=Office365,DC=intern,DC=maswer,DC=com`.

| Atributo | Valor |
|---|---|
| `sAMAccountName` / UPN | `AQuijano` / `AQuijano@maswer.com` |
| `mail` | `alex.quijano@maswer.com` |
| `mailNickname` | `AQuijano` |
| `targetAddress` | `SMTP:AQuijano@maswerag.onmicrosoft.com` |
| `proxyAddresses` | principal `SMTP:alex.quijano@maswer.com` + los dos de rutado a la nube |
| Exchange híbrido | `msExchRecipientTypeDetails/DisplayType/RemoteRecipientType` = RemoteUserMailbox |
| País | `co=Mexico`, `c=MX`, `countryCode=484` |

- Pre-flight sin colisiones: ningún objeto previo con ese `sAMAccountName`, UPN, `mail`,
  `proxyAddresses` ni CN, y **ningún homónimo** `Quijano` en el dominio.
- Grupos base del sitio: `Masw_ALL_Intranet_R`, `MFA-MASWER`, `SSL_VPN`, `TPLINK_User`,
  `Webfilter_Standard`. Nada más.
- **Contraseña sin caducidad y sin cambio obligatorio** desde la creación, y **dictable**
  (solo letras y dígitos, sin `@` ni caracteres ambiguos). Las dos lecciones del alta de
  `LCervantes` del día anterior — ver `2026-09-07_maswer_alta-luis-cervantes.md`.
- **`Sync-ADObject` a los 3 DCs restantes antes de cualquier sync.** Replicación confirmada en
  los **4 DCs** de inmediato, incluido `MEUAZDC011`, que es el que rompió el alta anterior.
- Atributos de Exchange puestos a mano: `MEUAZEX001` sigue sin ser alcanzable desde el equipo del
  técnico, así que no se pudo usar `Enable-RemoteMailbox`. Conviene que conet.de lo verifique.

---

## Pendiente

1. **Sync** en `MEUAZAC011`: `Start-ADSyncSyncCycle -PolicyType Delta`. El objeto ya está en el
   DC del que lee, así que debería salir en el primer ciclo.
2. **Licencia** en M365 → Usuarios activos → *Alex Quijano Reyes* → Licencias, misma SKU que sus
   compañeros de Puebla. Sin licencia no hay buzón.
3. **Contraseña inicial:** se entrega en la nota privada del ticket, nunca en el cuerpo del correo.
4. **Equipo.** El ticket pide *"configuración de equipo y usuario"*, pero no da nombre ni modelo
   de máquina. Cuando lo den: precrear el objeto de equipo en la OU de clientes de PBC — si cae
   en `CN=Computers` no le llegan las GPO enlazadas a OU.
5. **Accesos de su puesto.** Es **Ingeniero IT México-USA** y solo tiene los 5 grupos base. Si va
   a administrar, existen `MaswMex_IT_RW` y los grupos `MaswUS_*` para el lado de Estados
   Unidos. **No asignados**: hace falta que el cliente diga qué alcance tiene el puesto.
   Un perfil de IT con acceso a dos entidades merece que lo pidan por escrito.
