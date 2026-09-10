---
name: maswer-altas-password-no-expira
description: "En las altas de Maswer nunca forzar cambio de contraseña en el primer login; crear con PasswordNeverExpires — PTA sin password writeback deja al usuario bloqueado"
metadata:
  type: feedback
---

Al dar de alta un usuario en Maswer: **`-ChangePasswordAtLogon $false` y
`-PasswordNeverExpires $true`**. Nunca forzar el cambio de contraseña en el primer inicio
de sesión. Indicado por Sebastian el 07-sep-2026 tras el alta de `LCervantes`.

**Why:** el dominio autentica por **PTA** (ver [[maswer-aad-connect-server]]): la contraseña
vive solo en el AD on-prem y M365 no puede cambiarla sin *password writeback* (SSPR, Entra
ID P1), que no está activado. Un usuario con `pwdLastSet = 0` que intenta entrar en M365 recibe
*"La organización no permite actualizar la contraseña en este sitio"* y queda bloqueado hasta
que la cambie en un PC del dominio — cosa que un alta nueva normalmente todavía no tiene.
El entorno ya lo refleja: en la OU de Puebla, **0 de 30** cuentas activas tenían la marca de
cambio obligatorio y **28 de 30** tienen la contraseña sin caducidad. `MaxPasswordAge` del
dominio es `00:00:00`, así que la marca no cambia nada funcionalmente, solo desbloquea.

**How to apply:**
- En `New-ADUser`: omitir `-ChangePasswordAtLogon`, y después
  `Set-ADUser -PasswordNeverExpires $true` (AD rechaza las dos marcas a la vez).
- La contraseña inicial se entrega fuera del ticket y el usuario la cambia cuando tenga un
  equipo unido al dominio (Ctrl+Alt+Supr → Cambiar contraseña), no desde el portal. Encaja con
  la regla de no pasar credenciales por el ticket (`core/rules.md`) y con el encuadre de
  proceso de [[reply-tone-direct-not-nice]]: "se la pone él en el primer inicio de sesión, así
  que no hay nada que pasar de mano en mano".
- Si ya se creó con la marca puesta: `Set-ADUser -ChangePasswordAtLogon $false` +
  `-PasswordNeverExpires $true` y **empujar el objeto a los DCs de Azure** con `Sync-ADObject`,
  o el agente de PTA sigue viendo el estado viejo — ver [[maswer-replicacion-dcs-azure-altas]].
