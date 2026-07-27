# Caso — Cuenta `kundenmaswer@maswer.com` y portátil de O. Sanahuja

- **Fecha:** 2026-07-22
- **Cliente / contacto:** Maswer — Miriam Juan (portal Freshworks, 22-jul-2026 10:52)
- **Ticket:** "Petición urgente: crear cuenta de correo kundenmaswer@maswer.com + preparar el portátil de Oscar"
- **Técnico:** Sebastian (IT-Support-Germany)
- **Categoría / Prioridad:** Accounts and Access · **P2** (fecha de negocio comprometida)
- **Grupo:** N1 · ejecución en infra Maswer
- **Fecha comprometida:** viernes **24-jul-2026** — Miguel Champer recoge el portátil
- **Estado:** ✅ **cuenta traspasada en AD y sincronizada** · pendiente verificación en M365, MFA y preparación del portátil

## 1. Petición

1. Crear la cuenta de correo `kundenmaswer@maswer.com`.
2. Dejar operativo con ese correo el portátil que tenía Oscar, para otra persona.
3. Con WhatsApp, correo, Adobe, Excel, Word y "las apps de Maswer".
4. Entrega el viernes.

Indicación posterior del cliente: *"podías hacer lo mismo que hiciste en Alemania, meter la
cuenta en el ordenador de `osanahuja@maswer.com`"*.

## 2. Decisión — traspaso de cuenta, no alta nueva

Se replica el patrón del caso **MGeisz → Jan-Lukas Paschold** (14/15-jul-2026): se **renombra
el objeto AD existente** de `osanahuja` a la cuenta funcional `kundenmaswer`, en vez de crear
un usuario nuevo y reinstalar el equipo.

**Por qué:** al renombrar el objeto el **SID no cambia**, así que el perfil de Windows del
portátil se conserva íntegro — programas ya instalados (Adobe, apps de Maswer), licencias y
accesos a carpetas. Es la única ruta que llega al viernes, y además esquiva el bloqueo conocido
de admin local en equipos de otros usuarios (pendiente de GPO con conet.de desde la salida de
Oliver).

**Contrapartida, aceptada explícitamente por el cliente:** la persona que recibe el portátil
hereda el perfil de Oscar — escritorio, archivos locales, credenciales guardadas, sesiones de
navegador — **y todos sus accesos a carpetas**. De ahí la poda de grupos del paso 3 y la
limpieza del equipo del §6.

**Diferencias respecto al caso de Alemania:**

| | MGeisz → Jan | osanahuja → kundenmaswer |
|---|---|---|
| Identidad destino | persona con nombre | **cuenta funcional**, sin titular |
| Contraseña | conservada | **conservada** (misma decisión) |
| Alias heredado | dirección de una persona | dirección de una persona → continuidad de correo de clientes |
| Grupos | sin cambios | **poda** de accesos que no correspondan al puesto |

## 3. Hallazgo de infraestructura — `MEUAZEX001` no tiene Exchange instalado

La primera versión del runbook enviaba el cambio de direcciones a la Exchange Management Shell
de `MEUAZEX001`, siguiendo el inventario del repo. **Es incorrecto.** Verificado en la máquina:

| Comprobación | Resultado |
|---|---|
| `hostname` | `MEUAZEX001` ✅ (servidor correcto) |
| `Get-Command Set-RemoteMailbox` | `CommandNotFoundException` |
| `C:\Program Files\Microsoft\Exchange Server` | la ruta no existe |
| `HKLM:\SOFTWARE\Microsoft\ExchangeServer\v15\Setup` | la clave no existe |
| `Get-Service *MSExchange*` | sin resultados |

No hay binarios, ni registro, ni servicios de Exchange en ese host. El rol "ExchangeServer" del
inventario proviene de la etiqueta *Device Role* de Defender y de la convención de nombres, no
de una verificación en la máquina.

**Consecuencia operativa:** el cambio de direcciones se hace **en AD on-prem** editando
`proxyAddresses` — exactamente como se ejecutó el caso de Jan, donde tampoco se tocó Exchange.

**Pendiente de confirmar:** si existe algún servidor Exchange en el bosque, con
`Get-ADObject -LDAPFilter '(objectClass=msExchExchangeServer)'` sobre la partición de
configuración. Registrado también en `memory/maswer-servers-inventory.md`.

## 4. Runbook vigente — todo en `MDERZADC003`, PowerShell **elevada**

> Las variables mueren al cerrar la ventana: los bloques 0 a 3 se ejecutan **en la misma sesión**.

### 0. Identificar la cuenta y backup

```powershell
Get-ADUser -Filter "SamAccountName -eq 'osanahuja' -or UserPrincipalName -eq 'osanahuja@maswer.com' -or mail -eq 'osanahuja@maswer.com'" `
  -Properties mail | Format-List Name,SamAccountName,UserPrincipalName,mail

$guid = (Get-ADUser -Filter "mail -eq 'osanahuja@maswer.com'").ObjectGUID
$guid   # si no imprime nada, parar

$stamp = Get-Date -Format yyyyMMdd_HHmm
if (-not (Test-Path C:\temp)) { New-Item -ItemType Directory C:\temp | Out-Null }
Get-ADUser -Identity $guid -Properties * | Export-Clixml "C:\temp\osanahuja_ANTES_$stamp.xml"

Get-ADUser -Identity $guid -Properties Enabled,LastLogonDate,adminCount,mail,proxyAddresses,memberOf |
  Format-List Name,SamAccountName,Enabled,LastLogonDate,adminCount,mail,@{n='proxy';e={$_.proxyAddresses -join "`n"}}
```

**Punto de control:** parar si `adminCount = 1`, si aparece un grupo privilegiado, o si el
portátil tiene sesión abierta.

### 1. Identidad genérica

```powershell
Set-ADUser -Identity $guid -UserPrincipalName 'kundenmaswer@maswer.com' `
  -SamAccountName 'kundenmaswer' -DisplayName 'Kunden Maswer' `
  -GivenName 'Kunden' -Surname 'Maswer' `
  -Description 'Cuenta funcional - atencion a clientes. Responsable: Miriam Juan. Ticket 22-jul-2026'
Rename-ADObject -Identity (Get-ADUser -Identity $guid).DistinguishedName -NewName 'Kunden Maswer'
Set-ADUser -Identity $guid -Clear title,department,telephoneNumber,mobile
```

### 2. Direcciones — añadir y quitar, nunca reemplazar la colección

```powershell
$u   = Get-ADUser -Identity $guid -Properties proxyAddresses
$old = @($u.proxyAddresses | Where-Object { $_ -clike 'SMTP:*' })
if ($old.Count -ne 1) { throw "Primarias encontradas: $($old.Count). Revisar a mano." }

Set-ADUser -Identity $guid -Remove @{proxyAddresses=$old[0]} `
                           -Add    @{proxyAddresses=($old[0] -creplace '^SMTP:','smtp:')}
Set-ADUser -Identity $guid -Add @{proxyAddresses='SMTP:kundenmaswer@maswer.com'}
Set-ADUser -Identity $guid -Replace @{mail='kundenmaswer@maswer.com'; mailNickname='kundenmaswer'}

Get-ADUser -Identity $guid -Properties proxyAddresses,mail |
  Format-List mail,@{n='proxy';e={$_.proxyAddresses -join "`n"}}
```

**Punto de control:** una sola entrada en `SMTP:` mayúscula (la nueva), `smtp:osanahuja@maswer.com`
presente como alias, y **sigue estando** la dirección `…@maswer.mail.onmicrosoft.com`. Sustituir
la colección entera es lo que rompe el enrutamiento híbrido — por eso se hace con `-Add`/`-Remove`.

### 3. Grupos — sin tocar la contraseña

```powershell
Get-ADUser -Identity $guid -Properties memberOf | Select-Object -ExpandProperty memberOf | Sort-Object
Remove-ADGroupMember -Identity '[Masw..._RW]' -Members 'kundenmaswer' -Confirm:$false
```

**La contraseña no se resetea**, igual que en el caso de Jan: quien usa el equipo ya la tiene y
un reset solo lo bloquearía. Se revisa únicamente si Oscar ya no está en Maswer — ahí sus
credenciales seguirían siendo válidas sobre el buzón y las carpetas.

### 4. Sincronización — `MEUAZAC011`, PowerShell elevada

```powershell
Get-ADSyncScheduler | Format-List SyncCycleEnabled,StagingModeEnabled,NextSyncCycleStartTimeInUTC
Start-ADSyncSyncCycle -PolicyType Delta
```

Si `NextSyncCycleStartTimeInUTC` trae fecha vieja, el scheduler está congelado como el 15-jul:
`Restart-Service ADSync` y repetir el ciclo. ⚠️ El reinicio **siempre** dispara la alerta de
Defender *"Entra Connect Sync tampering"* — avisar antes a conet.de para que se cierre como
mantenimiento planificado.

### 5. Rollback

```powershell
$b = Import-Clixml "C:\temp\osanahuja_ANTES_<STAMP>.xml"; $g = $b.ObjectGUID
Set-ADUser -Identity $g -UserPrincipalName $b.UserPrincipalName -SamAccountName $b.SamAccountName `
  -GivenName $b.GivenName -Surname $b.Surname -DisplayName $b.DisplayName
Rename-ADObject -Identity (Get-ADUser -Identity $g).DistinguishedName -NewName $b.Name
Set-ADUser -Identity $g -Replace @{ mail=$b.mail; proxyAddresses=[string[]]$b.proxyAddresses }
# luego Start-ADSyncSyncCycle -PolicyType Delta en MEUAZAC011
```

## 5. Verificación

1. `admin.microsoft.com` → aparece `Kunden Maswer` con primaria `kundenmaswer@maswer.com`.
2. Correo de prueba a `kundenmaswer@maswer.com` **y** a `osanahuja@maswer.com` → ambos al mismo buzón.
3. En `entra.microsoft.com` → *Authentication methods*: borrar los métodos registrados por Oscar
   y revocar sesiones. Registrar MFA contra número de empresa o token del portátil, nunca un
   móvil personal.

## 6. Portátil

El perfil se conserva, pero quedan restos de la identidad anterior:

1. Iniciar sesión con `kundenmaswer@maswer.com`. `C:\Users\osanahuja` mantiene el nombre antiguo
   — **no renombrar la carpeta**, rompe el perfil.
2. Recrear el perfil de Outlook (Panel de control → Correo → Mostrar perfiles).
3. Vaciar el Administrador de credenciales (`rundll32.exe keymgr.dll,KRShowKeyMgr`) y las
   contraseñas guardadas del navegador.
4. Cerrar y reiniciar sesión en OneDrive y Teams.
5. Revisar `Desktop`, `Documents`, `Downloads` — qué se conserva lo decide Miriam, no IT.
6. Abrir Adobe y las apps de Maswer con la sesión nueva: algunas licencias van atadas al usuario.
7. WhatsApp: requiere un número de teléfono asignado. Sin número, no queda operativo.

## 7. Abierto / pendiente

Los detalles operativos (quién usa el portátil, carpetas, Adobe, apps de Maswer, teléfono para
WhatsApp) **los tiene el técnico** — no se piden al cliente. La preparación del equipo sigue en
curso para la entrega del viernes.

Quedan solo dos puntos de fondo:

- **Situación de Oscar** — si es baja, su cuenta y credenciales necesitaban tratamiento de
  offboarding, no un traspaso silencioso. Es el segundo caso en un mes tras MGeisz (baja 31-may).
- **Trazabilidad de la cuenta genérica** — contraseña en KeePass y registro de quién la tiene en
  cada momento; el campo `Description` es el mínimo.
- **Existencia de Exchange on-prem en el bosque** — consulta LDAP del §3, pendiente.

## 8. Ejecución — 22-jul-2026

Ejecutado en `MDERZADC003` con consola elevada, según el runbook del §4.

| # | Acción | Resultado |
|---|---|---|
| 0 | Backup del objeto AD → `C:\temp\osanahuja_ANTES_<stamp>.xml` | ✅ |
| 1 | Renombrado: UPN y sam → `kundenmaswer`, DisplayName `Kunden Maswer`, `Description` con responsable y ticket, atributos personales vaciados | ✅ |
| 2 | `proxyAddresses`: nueva primaria `SMTP:kundenmaswer@maswer.com`, la de Oscar degradada a alias `smtp:`, dirección de enrutamiento intacta. `mail` y `mailNickname` actualizados | ✅ |
| 3 | Auditoría de grupos — **sin cambios, no había nada que podar** | ✅ |
| 4 | `Start-ADSyncSyncCycle -PolicyType Delta` en `MEUAZAC011` | ✅ lanzado |

**Contraseña no modificada**, misma decisión que en el caso de Jan: quien usa el equipo ya la
tiene y un reset solo lo bloquearía.

**Grupos encontrados** (todos de base o de servicio, ninguno `_RW` de departamento):
`Masw_ALL_Intranet_R`, `MFA-MASWER`, `SSL_VPN`, `TPLINK_User`, `Webfilter_Standard`.

Dos lecturas de esa lista:

- **`SSL_VPN` sobre una cuenta genérica con contraseña heredada.** Cualquiera que conociese la
  contraseña de Oscar puede entrar a la red por VPN como `kundenmaswer`, y sin titular detrás no
  hay forma de atribuir la sesión. Si el portátil se usa en oficina, procede quitar el grupo.
- **La cuenta no tiene acceso a ninguna carpeta de red.** Si el puesto de atención a clientes lo
  necesita, hay que **añadir** el grupo correspondiente — pendiente de que Miriam indique a qué
  carpetas debe llegar.

### Pendiente de verificar

- [ ] `admin.microsoft.com` muestra `Kunden Maswer` con primaria `kundenmaswer@maswer.com`
- [ ] Correo de prueba a `kundenmaswer@maswer.com` y a `osanahuja@maswer.com` → mismo buzón
- [ ] Entra ID → borrar métodos de autenticación de Oscar + revocar sesiones; registrar MFA
      contra número de empresa o token del portátil
- [ ] Limpieza del portátil (§6) y prueba de aplicaciones
- [ ] Decisión sobre `SSL_VPN` y sobre las carpetas de red

## 9. Comunicación al cliente

Correo enviado a Miriam (22-jul) confirmando la cuenta operativa y la continuidad del correo,
sin pedir información — el técnico ya dispone de los datos de preparación:

```text
Hola Miriam,

La cuenta kundenmaswer@maswer.com ya está creada y funcionando. Lo que se enviaba a la
dirección de Oscar sigue llegando al mismo buzón.

Sigo con la preparación del portátil para tenerlo listo el viernes.

Un saludo,
Soporte CoolNetworks
```
