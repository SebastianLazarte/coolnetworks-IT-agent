# Caso — Traspaso de cuenta MGeisz → Jan-Lukas Paschold (Calden/KAS)

- **Fecha:** 2026-07-14
- **Cliente / contacto:** Maswer — Vincenzo Valle (portal), sede Calden (OU=KAS)
- **Ticket:** "New employee in Calden" (Jan-Lukas Paschold reemplaza a Michael Geisz)
- **Técnico:** Sebastian (IT-Support-Germany)
- **Categoría / Prioridad:** Accounts and Access · P2
- **Grupo:** N1 (ejecución por RDP en infra Maswer)

## Contexto
Michael Geisz **dejó la empresa el 31-may-2026**; su cuenta AD nunca se deshabilitó.
Jan-Lukas Paschold **empezó el 01-jul-2026** y lleva ~2 semanas trabajando **con la
cuenta completa de Michael** (login + correo). Confirmado por `LastLogonDate` de la
cuenta: 13-jul-2026 09:51 → Jan **sí** inicia sesión en Windows como esa cuenta.

Necesidad real de Vincenzo: continuidad de correo — que Jan siga recibiendo todo lo
enviado a la dirección de Michael, y quede trabajando cuanto antes, sin líos.

## Decisión
**No** cuenta nueva desde cero (obligaría a migrar a un usuario ya operativo) y **no**
seguir compartiendo la identidad de un empleado que ya se fue. Solución correcta:
**traspaso limpio remoto de la cuenta a Jan** (renombrar el objeto existente + resetear contraseña para
cortar a Michael + mantener la dirección de Michael como alias). MGeisz **no** es
cuenta privilegiada (memberOf vacío), así que renombrar no hereda permisos indebidos.

> **Corrección de método (revisión 14-jul):** Maswer tiene Exchange híbrido. El
> cambio de direcciones se hace en la **Exchange Management Shell de `MEUAZEX001`**
> con `Set-RemoteMailbox`, no sustituyendo `proxyAddresses` desde AD. Así se conserva
> la dirección de enrutamiento híbrida y cualquier alias existente. AD on-prem sigue
> siendo el origen de la identidad y `MEUAZAC011` realiza el sync a Entra/M365.

## Validaciones previas (solo lectura, ejecutadas en MDERZADC003)
| # | Comprobación | Resultado |
|---|---|---|
| 1 | Sufijos UPN del bosque | `nexproindustrial.com`, `maswer.com` → `maswer.com` válido ✅ |
| 2 | ¿`Jan.Paschold@maswer.com` / `JPaschold` ya existen? | Vacío → sin conflicto ✅ |
| 3 | Cuenta real tras el buzón | sam=`MGeisz`, UPN=`MGeisz@maswer.com`, DN en `OU=KAS,OU=DE,OU=User Accounts,OU=Office365` |
| 4 | ¿Privilegiada? | `memberOf {}` (sin grupos), no adminCount → cuenta normal ✅ |
| 5 | Estado de la cuenta | `Enabled=True`, UAC=66048 (normal, pwd-never-expires), LastLogon 13-jul |

**Incidencia de proceso detectada durante la validación:** los atributos sensibles
salían en blanco porque la primera consola **no estaba elevada** (token UAC filtrado —
`Administrators` marcado "solo para denegar"). Resuelto abriendo PowerShell **como
administrador**. Sin cambio de permisos ni escalado a conet.de.

## Convención de identidad (clave)
Login ≠ correo. Michael: login `MGeisz`, correo `michael.geisz@maswer.com`.
Por tanto Jan:

| Atributo | Objetivo |
|---|---|
| sAMAccountName (login) | `JPaschold` |
| UPN (inicio de sesión) | `JPaschold@maswer.com` |
| Nombre / DisplayName | Jan-Lukas Paschold |
| Email principal | `Jan.Paschold@maswer.com` |
| Alias (continuidad) | `michael.geisz@maswer.com` (+ `JPaschold@`, `MGeisz@`) |
| OU | sin cambios (KAS) |

## Runbook vigente (solo con ventana aprobada)
> **Precondiciones:** Vincenzo confirma una ventana corta; Jan queda **deslogueado**;
> la contraseña temporal se comunica por teléfono, nunca por correo/ticket. No ejecutar
> ningún cambio de producción hasta completar el preflight sin conflictos.

### 0. Preflight y backup

En `MEUAZEX001`, abrir **Exchange Management Shell como administrador**. Las dos
direcciones de Jan deben estar libres; las de Michael pueden devolver el propio objeto
actual. Guardar tanto el estado de Exchange como el de AD antes de modificar nada.

```powershell
# Exchange Management Shell en MEUAZEX001
$oldSam  = 'MGeisz'
$newSam  = 'JPaschold'
$primary = 'Jan.Paschold@maswer.com'
$aliases = @('JPaschold@maswer.com','MGeisz@maswer.com','michael.geisz@maswer.com')

Get-Recipient -ResultSize Unlimited -Filter "EmailAddresses -eq 'smtp:Jan.Paschold@maswer.com'" |
  Format-List Name,PrimarySmtpAddress,RecipientTypeDetails,DistinguishedName
Get-Recipient -ResultSize Unlimited -Filter "EmailAddresses -eq 'smtp:JPaschold@maswer.com'" |
  Format-List Name,PrimarySmtpAddress,RecipientTypeDetails,DistinguishedName

if (-not (Test-Path C:\temp)) { New-Item -ItemType Directory C:\temp | Out-Null }
$stamp = Get-Date -Format yyyyMMdd_HHmm
$mbx = Get-RemoteMailbox -Identity $oldSam
$mbx | Export-Clixml "C:\temp\MGeisz_EXCHANGE_ANTES_$stamp.xml"
$mbx | Format-List DisplayName,Alias,PrimarySmtpAddress,EmailAddresses,RemoteRoutingAddress,EmailAddressPolicyEnabled

# AD PowerShell elevada en MDERZADC003
$guid = (Get-ADUser $oldSam).ObjectGUID
Get-ADUser -Identity $guid -Properties * |
  Export-Clixml "C:\temp\MGeisz_ANTES_$stamp.xml"
```

**Punto de control:** parar si cualquiera de las dos direcciones de Jan pertenece a
otro destinatario, si Jan sigue con sesión abierta o si aparece un grupo no revisado.

### 1. Cambiar correo y aliases (`MEUAZEX001`)

```powershell
# El parámetro PrimarySmtpAddress exige que la política de direcciones esté desactivada.
# Si estaba activa, se conserva su estado en el backup para el rollback.
if ($mbx.EmailAddressPolicyEnabled) {
  Set-RemoteMailbox -Identity $oldSam -EmailAddressPolicyEnabled $false
}

# Cambia la primaria sin reemplazar la colección completa de direcciones.
Set-RemoteMailbox -Identity $oldSam -PrimarySmtpAddress $primary -Alias $newSam

# Añade solo aliases que falten. No borra routing address ni aliases preexistentes.
$current = Get-RemoteMailbox -Identity $oldSam
$toAdd = $aliases | Where-Object { [string[]]$current.EmailAddresses -notcontains "smtp:$_" }
if ($toAdd) {
  Set-RemoteMailbox -Identity $oldSam -EmailAddresses @{Add = ($toAdd | ForEach-Object { "smtp:$_" })}
}

Get-RemoteMailbox -Identity $oldSam |
  Format-List DisplayName,Alias,PrimarySmtpAddress,EmailAddresses,RemoteRoutingAddress
```

**Punto de control:** la primaria debe ser `Jan.Paschold@maswer.com`; las direcciones
de Michael y `JPaschold@maswer.com` deben estar como aliases secundarios (`smtp:` en
minúscula); y debe seguir presente la dirección `…@maswer.mail.onmicrosoft.com`.

### 2. Renombrar identidad y resetear la contraseña (`MDERZADC003`)

```powershell
# El GUID evita depender del nombre durante el cambio.
Set-ADUser -Identity $guid -UserPrincipalName "JPaschold@maswer.com" `
  -SamAccountName $newSam -GivenName "Jan-Lukas" -Surname "Paschold" `
  -DisplayName "Jan-Lukas Paschold"
Rename-ADObject -Identity (Get-ADUser -Identity $guid).DistinguishedName `
  -NewName "Jan-Lukas Paschold"

# El orden importa: PasswordNeverExpires impide ChangePasswordAtLogon.
$tmp = Read-Host "Contraseña temporal para Jan" -AsSecureString
Set-ADAccountPassword -Identity $guid -Reset -NewPassword $tmp
Set-ADUser -Identity $guid -PasswordNeverExpires $false
Set-ADUser -Identity $guid -ChangePasswordAtLogon $true

Get-ADUser -Identity $guid -Properties Enabled,UserPrincipalName,SamAccountName,DisplayName,PasswordNeverExpires |
  Format-List DisplayName,SamAccountName,UserPrincipalName,Enabled,PasswordNeverExpires
```

### 3. Sincronizar, limpiar MFA y verificar

1. En `MEUAZAC011`, ejecutar `Start-ADSyncSyncCycle -PolicyType Delta` y esperar al
   **Export** hacia `maswerag.onmicrosoft.com`; `Result: Success` solo indica que el
   ciclo se inició.
2. En Entra ID, abrir Jan-Lukas Paschold → *Authentication methods*: eliminar los
   métodos de Michael y revocar sesiones MFA e inicio de sesión.
3. En Exchange admin center, actualizar la vista y comprobar nombre, primaria y aliases.
4. Probar el envío a `michael.geisz@maswer.com`; debe llegar al buzón de Jan.
5. Con Jan, verificar el acceso con `JPaschold@maswer.com`, el cambio obligatorio de
   contraseña y el registro de MFA. Confirmar con Vincenzo antes de cerrar el ticket.

## Rollback vigente

Solo si falla una verificación crítica durante la ventana. Restaurar con los dos
backups de esta ejecución, sincronizar y comprobar de nuevo el flujo de correo.

```powershell
# Exchange Management Shell en MEUAZEX001
$x = Import-Clixml "C:\temp\MGeisz_EXCHANGE_ANTES_<STAMP>.xml"
Set-RemoteMailbox -Identity JPaschold -PrimarySmtpAddress $x.PrimarySmtpAddress `
  -Alias $x.Alias -EmailAddresses ([string[]]$x.EmailAddresses)
if ($x.EmailAddressPolicyEnabled) {
  Set-RemoteMailbox -Identity JPaschold -EmailAddressPolicyEnabled $true
}

# AD PowerShell elevada en MDERZADC003
$b = Import-Clixml "C:\temp\MGeisz_ANTES_<STAMP>.xml"
$g = $b.ObjectGUID
Set-ADUser -Identity $g -UserPrincipalName $b.UserPrincipalName `
  -SamAccountName $b.SamAccountName -GivenName $b.GivenName -Surname $b.Surname `
  -DisplayName $b.DisplayName
Rename-ADObject -Identity (Get-ADUser -Identity $g).DistinguishedName -NewName $b.Name

# Finalmente, en MEUAZAC011
Start-ADSyncSyncCycle -PolicyType Delta
```

## Script descartado — no ejecutar
> ⚠️ Este bloque se conserva solo como histórico. Reemplazar manualmente
> `proxyAddresses` desde AD puede eliminar aliases o la dirección de enrutamiento
> híbrida. Usar exclusivamente el runbook vigente que aparece antes de este bloque.

```powershell
# PASO 0 — Backup
if (-not (Test-Path C:\temp)) { New-Item -ItemType Directory C:\temp | Out-Null }
$guid  = (Get-ADUser MGeisz).ObjectGUID
$stamp = Get-Date -f yyyyMMdd_HHmm
Get-ADUser -Identity $guid -Properties * | Export-Clixml "C:\temp\MGeisz_ANTES_$stamp.xml"

# PASO 1 — Renombrar identidad
Set-ADUser -Identity $guid -UserPrincipalName "JPaschold@maswer.com" `
  -SamAccountName "JPaschold" -GivenName "Jan-Lukas" -Surname "Paschold" -DisplayName "Jan-Lukas Paschold"
Rename-ADObject -Identity (Get-ADUser -Identity $guid).DistinguishedName -NewName "Jan-Lukas Paschold"

# PASO 2 — Direcciones (Jan principal; Michael como alias)
Set-ADUser -Identity $guid -Replace @{
  mail         = "Jan.Paschold@maswer.com"
  mailNickname = "JPaschold"
  proxyAddresses = @(
    "SMTP:Jan.Paschold@maswer.com",
    "smtp:JPaschold@maswer.com",
    "smtp:michael.geisz@maswer.com",
    "smtp:MGeisz@maswer.com"
  )
}

# PASO 3 — Reset de contraseña (ojo al orden: pwd-never-expires bloquea ChangePasswordAtLogon)
$tmp = Read-Host "Contraseña temporal para Jan" -AsSecureString
Set-ADAccountPassword -Identity $guid -Reset -NewPassword $tmp
Set-ADUser -Identity $guid -PasswordNeverExpires $false
Set-ADUser -Identity $guid -ChangePasswordAtLogon $true

# PASO 4 — Verificar en AD
Get-ADUser -Identity $guid -Properties Enabled,mail,proxyAddresses,UserPrincipalName,SamAccountName,DisplayName |
  Format-List DisplayName,SamAccountName,UserPrincipalName,Enabled,mail,@{n='proxy';e={$_.proxyAddresses -join '; '}}

# PASO 5 — Sync (en MEUAZAC011)
Start-ADSyncSyncCycle -PolicyType Delta
```

**PASO 6 — MFA (portal Entra ID):** Jan-Lukas Paschold → Authentication methods →
borrar métodos de Michael → Revoke MFA sessions + Revoke sessions. Jan re-registra
en su primer login.

**PASO 7 — Verificación final:** correo de prueba a `michael.geisz@maswer.com` debe
llegar al buzón de Jan; Jan entra con `JPaschold@maswer.com` + temporal → la cambia →
registra MFA.

## Rollback descartado — no ejecutar
> ⚠️ Este bloque también sustituye `proxyAddresses` directamente. El rollback vigente
> está documentado antes de este bloque y debe ejecutarse con `Set-RemoteMailbox`.
```powershell
$b = Import-Clixml "C:\temp\MGeisz_ANTES_<STAMP>.xml"; $g = $b.ObjectGUID
Set-ADUser -Identity $g -UserPrincipalName $b.UserPrincipalName -SamAccountName $b.SamAccountName -DisplayName $b.DisplayName
Rename-ADObject -Identity (Get-ADUser -Identity $g).DistinguishedName -NewName $b.Name
Set-ADUser -Identity $g -Replace @{ mail=$b.mail; proxyAddresses=[string[]]$b.proxyAddresses }
# luego Start-ADSyncSyncCycle -PolicyType Delta en MEUAZAC011
```

## Pendiente histórico / sustituido — no usar
- Confirmar ubicación del buzón (on-prem `MEUAZEX001` vs EXO) desde EMS/`Connect-ExchangeOnline`
  — solo para saber dónde verificar; el cambio de direcciones va por `proxyAddresses` en AD (híbrido).
- Registrar el hallazgo de higiene: cuenta de un baja (31-may) siguió activa y usada por otra
  persona ~6 semanas. Recomendado revisar otras cuentas de bajas aún habilitadas.
- Confirmar con Vincenzo la ventana para ejecutar y avisar a Jan (login = `JPaschold@maswer.com`).

## Estado actual y continuación

**Estado:** listo para ejecutar de forma remota, pendiente únicamente de una ventana
aprobada por Vincenzo y de que Jan cierre sesión. No se ha realizado ningún cambio en
producción.

1. Pedir a Vincenzo una ventana corta y confirmar que Jan estará deslogueado.
2. Ejecutar el **Runbook vigente**: Exchange en `MEUAZEX001`, identidad en
   `MDERZADC003`, sync en `MEUAZAC011`.
3. Probar el alias de Michael, el nuevo inicio de sesión y el registro MFA de Jan.
4. Confirmar el resultado con Vincenzo antes de cerrar el ticket.

## Respuesta preparada para Vincenzo (inglés)

```text
Hi Vincenzo,

I have prepared the remote account handover for Jan-Lukas. His current access will be
moved to his own name, while messages sent to Michael's address will continue to reach him.

To make the change safely, I need a short time window when Jan-Lukas can be signed out.
What time works best for you and Jan today or tomorrow? No on-site visit is needed.

After the change, Jan-Lukas will sign in with JPaschold@maswer.com and will be asked to
set a new password and register his verification method.

Best,
CoolNetworks Support
```
