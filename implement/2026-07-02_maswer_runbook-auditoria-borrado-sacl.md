# Runbook — Auditoría de borrado de archivos (SACL) en Maswer Spain

**Autor:** Sebastian Lazarte Castellón (CoolNetworks — IT de Maswer)
**Fecha:** 02-jul-2026
**Servidor:** `MDERZFIL001.intern.maswer.com`
**Ámbito:** carpeta `D:\Shares\Maswer\maswerspainsl\QM` (unidad `R:` = *Maswer Spain S.L.*)
**Origen:** derivado del caso de recuperación `IntAudit_ES` (borrado sin rastro de autor por SACL vacía).

---

## Objetivo

Dejar registrado **quién y cuándo** borra archivos en la estructura `QM` (ISO 9001 / 14001 …),
para que un incidente como el de `IntAudit_ES` sea rastreable en el futuro.

Requiere **dos condiciones a la vez** (si falta una, no se genera ningún evento):

1. **Política de auditoría** del servidor activa para "Sistema de archivos" (object access).
2. **SACL** de auditoría de borrado en la carpeta.

Y, para que sirva de algo, **retención del log** suficiente.

---

## Requisitos previos

| Requisito | Detalle |
|---|---|
| Permisos | Cuenta con **administrador local** sobre `MDERZFIL001` (privilegio `SeSecurityPrivilege`). |
| Quién lo ejecuta | Sebastian si dispone de esa cuenta; **si no, conet.de** (gestionan el acceso admin al servidor). |
| Acceso | Sesión local/RDP en el servidor, **o** WinRM (`Invoke-Command` / `Enter-PSSession`). RPC está bloqueado. |
| Consola | PowerShell **elevado** (Ejecutar como administrador). |
| Ventana | Cambios de auditoría/ACL no interrumpen el servicio; no requieren ventana de mantenimiento. |

> **Nota de idioma:** el servidor está en **español**. Los nombres de subcategoría están traducidos
> ("Sistema de archivos"). Para evitar el error `0x57` usa el **GUID** cuando sea posible.

---

## Paso 1 — Verificar la política de auditoría (global)

> En este servidor **ya está activa** ("Aciertos y errores"), pero se documenta la comprobación.

```powershell
# Por GUID (independiente del idioma) — File System = {0CCE921D-69AE-11D9-BED3-505054503030}
auditpol /get /subcategory:{0CCE921D-69AE-11D9-BED3-505054503030}
```

Salida esperada:
```
Acceso de objetos
  Sistema de archivos            Aciertos y errores
```

Si apareciera "Sin auditoría", activarla (basta *Correcto* para borrados):

```powershell
auditpol /set /subcategory:{0CCE921D-69AE-11D9-BED3-505054503030} /success:enable
```

Para que sea **permanente vía GPO** (recomendado, no se revierte):
`Configuración del equipo → Directivas → Configuración de Windows → Configuración de seguridad →
Configuración de directiva de auditoría avanzada → Acceso a objetos → Auditar el sistema de archivos = Correcto`.
Conviene activar también *"Forzar configuración de subcategorías de directiva de auditoría"*.

---

## Paso 2 — Poner la SACL en la carpeta (lo que faltaba)

Se aplica en `QM` para que **herede** a todas las subcarpetas ISO (no solo a una).
`icacls` NO gestiona SACL de auditoría → se usa PowerShell.

**En sesión local del servidor:**

```powershell
$path = 'D:\Shares\Maswer\maswerspainsl\QM'
$acl  = Get-Acl -Path $path -Audit

$rule = New-Object System.Security.AccessControl.FileSystemAuditRule(
  'Everyone',                                 # a quién auditar
  'Delete, DeleteSubdirectoriesAndFiles',     # acciones de borrado
  'ContainerInherit, ObjectInherit',          # herencia: subcarpetas + archivos
  'None',                                      # no excluir la propia carpeta
  'Success'                                    # borrados efectivos
)
$acl.AddAuditRule($rule)
Set-Acl -Path $path -AclObject $acl
```

**Desde un equipo remoto (WinRM):**

```powershell
Invoke-Command -ComputerName MDERZFIL001 {
  $path = 'D:\Shares\Maswer\maswerspainsl\QM'
  $acl  = Get-Acl -Path $path -Audit
  $rule = New-Object System.Security.AccessControl.FileSystemAuditRule(
    'Everyone','Delete, DeleteSubdirectoriesAndFiles',
    'ContainerInherit, ObjectInherit','None','Success')
  $acl.AddAuditRule($rule)
  Set-Acl -Path $path -AclObject $acl
}
```

---

## Paso 3 — Verificar que la SACL quedó aplicada

```powershell
(Get-Acl 'D:\Shares\Maswer\maswerspainsl\QM' -Audit).Audit |
  Format-Table IdentityReference, FileSystemRights, AuditFlags, InheritanceFlags
```

Fila esperada:
```
Everyone   Delete, DeleteSubdirectoriesAndFiles   Success   ContainerInherit, ObjectInherit
```

Comprobar herencia en una subcarpeta (debe mostrar la misma regla como heredada):

```powershell
(Get-Acl 'D:\Shares\Maswer\maswerspainsl\QM\ISO 14001 Spain' -Audit).Audit
```

---

## Paso 4 — Ampliar la retención del log de Seguridad

El log actual (~20 MB) rota en ~6 días; con "Aciertos y errores" se llenará aún más rápido.
Sin margen de retención, la auditoría no sirve para investigar borrados pasados.

```powershell
wevtutil sl Security /ms:1073741824   # 1 GB (ajustar según disco)
wevtutil gl Security                  # comprobar maxSize / retention
```

**Ideal:** reenviar el log a un colector externo (WEF/SIEM) para retención larga
fuera del propio servidor.

---

## Paso 5 — Cómo consultar los borrados después

Eventos que se generan al borrar:

| Evento | Significado |
|---|---|
| **4660** | Objeto eliminado (marca el borrado) |
| **4663** | Acceso a objeto ejerciendo el permiso DELETE |
| **4656** | Se solicitó un handle con derecho DELETE |

El **4660** se correlaciona con el **4663/4656** por el mismo **`Handle ID`** para saber qué archivo y qué usuario.

Consulta rápida de los últimos borrados:

```powershell
Get-WinEvent -ComputerName MDERZFIL001 -FilterHashtable @{ LogName='Security'; Id=4660 } -MaxEvents 50 |
  Select-Object TimeCreated, @{n='Usuario';e={$_.Properties[1].Value}}, @{n='HandleId';e={$_.Properties[6].Value}}
```

Para el nombre del archivo, cruzar el `HandleId` con el 4663/4656 en la misma franja horaria.

---

## Rollback (revertir la SACL si hiciera falta)

```powershell
$path = 'D:\Shares\Maswer\maswerspainsl\QM'
$acl  = Get-Acl -Path $path -Audit
$acl.GetAuditRules($true,$false,[System.Security.Principal.NTAccount]) |
  Where-Object { $_.IdentityReference -eq 'Everyone' } |
  ForEach-Object { $acl.RemoveAuditRule($_) }
Set-Acl -Path $path -AclObject $acl
```

---

## Checklist

- [x] Paso 1 — Política "Sistema de archivos" activa (verificado: "Aciertos y errores").
- [ ] Paso 2 — SACL de borrado aplicada en `QM`.
- [ ] Paso 3 — Verificada la SACL + herencia.
- [ ] Paso 4 — Log de Seguridad ampliado (o reenvío a colector).
- [ ] Paso 5 — Prueba: borrar un archivo de test y localizar el 4660/4663.

---

## Consideraciones

- **Volumen:** auditar "Everyone" en una estructura muy usada genera muchos eventos; por eso importa el Paso 4. Si el ruido es excesivo, limitar a un grupo concreto (p. ej. `MaswES_QM_RW`) en lugar de `Everyone`.
- **Rendimiento:** la auditoría de borrado tiene impacto mínimo; el coste real es el tamaño del log.
- **Alcance:** aquí se audita solo *borrado*. Si se quisiera también *modificación/creación*, ampliar `FileSystemRights` (p. ej. `WriteData`, `AppendData`) — pero eso multiplica el volumen.
