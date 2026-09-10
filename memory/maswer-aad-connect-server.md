---
name: maswer-aad-connect-server
description: "MEUAZAC011 = servidor Entra Connect (dir-sync) de Maswer. Autenticación PTA, no PHS — las contraseñas nunca sincronizan. Cómo forzar sync, error crónico de Export y cómo leer el connector space por WinRM."
metadata:
  type: reference
---

El servidor de **Azure AD Connect / Microsoft Entra Connect** de Maswer es **`MEUAZAC011`**
(el "AC" = Azure Connect). Sincroniza el AD on-prem `intern.maswer.com` → tenant M365
`maswerag.onmicrosoft.com`. Ver [[maswer-servers-inventory]].

## Forzar una sincronización

RDP a `MEUAZAC011`, PowerShell como admin:
```powershell
Start-ADSyncSyncCycle -PolicyType Delta     # normal, solo objetos cambiados
Start-ADSyncSyncCycle -PolicyType Initial   # reevaluación completa si Delta no ve diferencias
```
"Result: Success" significa que el ciclo **se ha iniciado**, no que haya terminado — un ciclo
completo tarda 1-2 min. En **Synchronization Service Manager**, un `Export` a
`maswerag.onmicrosoft.com` solo aparece si había algo que empujar; sin Export = sin diff
pendiente. La lista "Administrar buzones" de M365 cachea — verificar valores reales en el
centro de administración de Exchange o con Ctrl+F5. El auto-sync corre cada 30 min.

⚠️ **Antes del Delta, empuja el objeto a los DCs de Azure** o el alta no llega —
[[maswer-replicacion-dcs-azure-altas]].

## Modelo de autenticación — verificado 28-ago-2026

Password Hash Sync está **desactivado**; el agente de **Pass-through Authentication** está
instalado y corriendo en `MEUAZAC011`. Entra reenvía cada inicio de sesión al AD on-prem y lo
valida allí en tiempo real.

**Consecuencia: las contraseñas nunca sincronizan a M365.** Un reset en AD es efectivo en la
nube inmediatamente, y forzar un ciclo de sync por un cambio de contraseña es inútil. Verificar
un reset con `PrincipalContext.ValidateCredentials` contra los DCs — es la misma comprobación
que hace PTA. Sin *password writeback*, esto también condiciona las altas →
[[maswer-altas-password-no-expira]].

## Error crónico de Export — IDENTIFICADO 04-sep-2026 (no es tuyo)

El conector `intern.maswer.com` termina su perfil `Export` con exactamente 1 error en cada
ciclo (~48 eventos 6100/día). El objeto atascado es **`CN=Oliver Orth`**: error
`8344 INSUFF_ACCESS_RIGHTS` sobre **`msDS-KeyCredentialLink`** (writeback de Hello for
Business) — la cuenta de sync `MSOL_7ff5a7f81acc` no tiene permiso de escritura en ese
atributo. Falla desde el **27-mar-2026**, ~7.000 reintentos. **Nunca confundirlo con un efecto
secundario de un cambio propio.** Ver [[oliver-orth-admin-accounts-still-enabled]].

Tampoco tiene nada que ver con la falta de espacio en disco del mismo servidor →
[[meuazac011-disco-c-insuficiente]].

## Trabajar en remoto (sin RDP)

`Invoke-Command -ComputerName MEUAZAC011 { Import-Module ADSync; ... }`. El módulo `ADSync`
**no** está instalado en la estación del técnico. Ojo: `Get-ADSyncRunProfileResult` y
`Get-ADSyncCSObject` **fallan sobre WinRM** (`net.pipe://localhost/ADSyncManagement` no
alcanzable) — `Get-ADSyncConnector` y `Get-ADSyncScheduler` sí funcionan. El namespace WMI
`root\MicrosoftIdentityIntegrationServer` ya no existe en esta versión.

**Cómo leer el connector space igualmente** (funciona sobre WinRM, solo lectura): consultar
directamente la LocalDB de ADSync.
```powershell
Invoke-Command -ComputerName MEUAZAC011 {
  $c = New-Object System.Data.SqlClient.SqlConnection `
       "Server=(localdb)\.\ADSync2019;Database=ADSync;Integrated Security=True"
  $c.Open(); $cmd = $c.CreateCommand()
  $cmd.CommandText = @"
SELECT ma.ma_name, cs.rdn, cs.is_export_error, cs.export_error_code,
       cs.count_export_error_retries, CAST(cs.export_error_detail AS nvarchar(max)) AS detail
FROM mms_connectorspace cs JOIN mms_management_agent ma ON ma.ma_id = cs.ma_id
WHERE cs.is_export_error = 1
"@
  $r = $cmd.ExecuteReader(); while($r.Read()){ ,(0..($r.FieldCount-1) | % { "$($r.GetName($_))=$($r.GetValue($_))" }) -join ' | ' }
}
```
Columnas útiles de `mms_connectorspace`: `is_export_error`, `export_error_detail`,
`export_operation` (≠0 = export pendiente), `is_connector`, `rdn`, `anchor`. Unir
`mms_csmv_link` (`mv_object_id` ↔ `cs_object_id`) para comprobar si un objeto on-prem llegó
de verdad al connector space **AAD** — esa es la prueba de que un usuario existe en Entra. El
`rdn` de AAD es `CN={hex}`; el hex decodifica a base64 ASCII = el **ImmutableId**, cuyos bytes
son el `objectGUID` on-prem. Requiere pertenecer al grupo local `ADSyncAdmins` (la cuenta de
diario ya pertenece).

⚠️ Reiniciar el servicio dispara una alerta de Defender →
[[adsync-restart-triggers-defender-alert]]. Contexto: [[maswer-exchange-hybrid]].
