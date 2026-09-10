# Reporte del caso — Maswer / Alta de Héctor Mauricio Calvo Lopez

- **Cliente:** Maswer Spain SL
- **Usuario final:** Héctor Mauricio Calvo Lopez (BCN)
- **Técnico:** Sebastian Lazarte Castellón (CoolNetworks)
- **Fecha:** 04-sep-2026
- **Estado:** **EN CURSO** — cuenta creada en AD; pendiente purga en M365 + sync + licencia

---

## Triaje

| Campo | Valor |
|---|---|
| Categoría | Accounts and Access (alta de usuario) |
| Prioridad | P3 - Media |
| Grupo | N1 |
| Escalado | No |

---

## Qué pasó

La cuenta se creó primero **en el centro de administración de Microsoft 365**
(`hcalvo@maswer.com`, licencia Microsoft 365 Empresa Premium). Al intentar unir el portátil
al dominio, Windows devolvió:

> Error al intentar unirse al dominio "INTERN.MASWER.COM": El nombre de usuario o la
> contraseña no son correctos.

**El error es literal y correcto.** Maswer es híbrido con el **AD on-prem como maestro**: los
usuarios nacen en ADUC y suben a M365 por Azure AD Connect (`MEUAZAC011`). Una cuenta creada
en M365 es **solo-nube**: no existe en `intern.maswer.com`. El diálogo de unión al dominio
autentica contra el DC, que no la conoce.

**Verificado:** búsqueda en AD por `sn`, `displayName`, `sAMAccountName` y `userPrincipalName`
con patrón `*calvo*` → **cero resultados** antes del alta.

---

## Convención deducida del entorno (no inventada)

Muestreo de la OU `BCN` y de dos altas recientes (`JLujan`, `CSaucedo`):

| Atributo | Patrón | Valor aplicado |
|---|---|---|
| `sAMAccountName` / `UPN` | inicial + apellido | `HCalvo` / `HCalvo@maswer.com` |
| `mail` (SMTP principal) | todos los nombres concatenados **.** todos los apellidos concatenados, sin acentos | `HectorMauricio.CalvoLopez@maswer.com` |
| `mailNickname` | = `sAMAccountName` | `HCalvo` |
| `targetAddress` | `SMTP:<sam>@maswerag.onmicrosoft.com` | `SMTP:HCalvo@maswerag.onmicrosoft.com` |
| Tipo de destinatario | `RemoteUserMailbox` | `2147483648` / `1` / `-2147483642` |
| Grupos base | los 5 que lleva todo usuario | ver abajo |

Referencias de la convención de correo: `Monica.IsaacSoto@`, `MarielaJazmin.DuarteValenzuela@`,
`Joan.GuerraGalvez@`, `Nicolas.Cardozo@`. Es concatenación, no inicial.

⚠️ **Corrección:** en el primer análisis se propuso `hector.calvo@maswer.com`. Es incorrecto
según la convención observada. Se aplicó `HectorMauricio.CalvoLopez@maswer.com` como principal
y se añadió `HCalvo@maswer.com` como alias secundario (patrón que ya usa `KSotelo`).

---

## Acción ejecutada — 04-sep-2026 12:08

`New-ADUser` en `OU=BCN,OU=ES,OU=User Accounts,OU=Office365,DC=intern,DC=maswer,DC=com`,
ejecutado contra `MDERZADC003`.

- `DisplayName` quedó vacío en el `New-ADUser` inicial → corregido con `Set-ADUser`.
- Contraseña inicial aleatoria, **cambio obligatorio en el primer inicio de sesión**
  (no se registra aquí).
- `proxyAddresses`: `SMTP:HectorMauricio.CalvoLopez@maswer.com` (principal),
  `smtp:HCalvo@maswer.com`, `smtp:HectorMauricio.CalvoLopez@maswerag.mail.onmicrosoft.com`,
  `smtp:HCalvo@maswerag.onmicrosoft.com`
- Grupos base añadidos: `Masw_ALL_Intranet_R`, `MFA-MASWER`, `SSL_VPN`, `TPLINK_User`,
  `Webfilter_Standard`
- Replicación confirmada en `MDERZADC003` y `MDERZADC004`. `MEUAZDC011` y `MUSAZDC011`
  pendientes (enlace de sitio Azure, replicación programada).

### Atributos de Exchange puestos a mano — justificación

`MEUAZEX001` **no es alcanzable** desde el equipo del técnico (puertos 5985, 80 y 443 cerrados),
así que no se pudo usar `Enable-RemoteMailbox`, que es la vía soportada. En su lugar se
replicaron **exactamente** los atributos de `NCardozo` (misma OU, patrón completo).
**Conviene que conet.de lo verifique en el servidor de Exchange.**

---

## Pendiente — en este orden

1. **Purgar la cuenta de nube.** M365 → Usuarios → **Usuarios eliminados** → *Eliminar
   permanentemente*. No basta con borrarla: el objeto eliminado conserva UPN y direcciones SMTP
   **30 días**, y el siguiente sync haría **soft-match** contra él en vez de crear un objeto
   limpio.
   ⚠️ **Carrera:** el auto-sync de AAD Connect corre **cada 30 min**. La cuenta on-prem se creó
   a las 12:08. Si el ciclo se dispara antes de la purga, habrá error de export o soft-match.
2. **Forzar sync** en `MEUAZAC011`: `Start-ADSyncSyncCycle -PolicyType Delta`.
   **No ejecutado** — a la espera de la confirmación del paso 1.
3. **Asignar la licencia** Microsoft 365 Empresa Premium al objeto ya sincronizado. El buzón se
   aprovisiona solo.
4. **Unir el portátil al dominio** con `MASWER\IT-Support-Germany`. **Precrear el objeto de
   equipo en `OU=BCN,OU=ES,OU=Clients`**: si se deja caer en `CN=Computers` no le llegan las GPO
   enlazadas a OU (es justo lo que le pasa a `MESZAZCLI21478` y otros cuatro equipos detectados
   en el caso Cardozo).
5. **Acceso a carpetas / unidades de red:** no asignado. Los 5 grupos base no dan acceso a
   ningún proyecto. Hace falta que el cliente diga a qué carpetas debe entrar.

---

## Observación colateral

`MaxPasswordAge` del dominio es **00:00:00** → las contraseñas **no caducan a nivel de dominio**.
Explica que la de `NCardozo` siga siendo la del alta (25-feb-2026). No es un incidente, pero es
una política que merece revisión aparte.
