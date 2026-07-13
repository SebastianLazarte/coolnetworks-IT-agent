# Runbook — Alta de usuarios y acceso a carpetas (Maswer, AD híbrido)

Procedimientos y comandos que hay que ejecutar al **crear un usuario** o **dar acceso
a una carpeta** en el entorno de Maswer, y el **sync a M365** que los cierra.

> **Entorno:** AD on-prem `intern.maswer.com` → tenant M365 `maswerag.onmicrosoft.com`,
> sincronizado por **Azure AD Connect en `MEUAZAC011`** (ver `memory/maswer-aad-connect-server.md`).
> Para saber **qué host** toca en cada acción (DC, Exchange, VPN, file server), ver
> `memory/maswer-servers-inventory.md` → "Qué servidor para qué tarea".
> Exchange es **híbrido**: nombre/alias de buzón se gobiernan en AD on-prem, no en M365
> (ver `memory/maswer-exchange-hybrid.md`).

> **⚠️ VERIFICAR antes de usar en producción** — los siguientes valores dependen de
> vuestra infraestructura y **no** están confirmados en el repo. Rellénalos/corrígelos:
> - OU de usuarios (DN): `OU=Usuarios,OU=Maswer,DC=intern,DC=maswer,DC=com` (ejemplo)
> - Servidor de ficheros y rutas de recursos compartidos: `\\SERVIDOR\Share\...`
> - Convención de grupos de seguridad de carpeta (p. ej. `FS-<Carpeta>-RW` / `-RO`)
> - Sufijo UPN / dominios de correo permitidos
> - Grupos de licencia (group-based licensing) que asignan la licencia M365

---

## 1. Crear un usuario

Ejecutar en un **Domain Controller** o equipo con RSAT (módulo `ActiveDirectory`), como admin.

```powershell
# --- Datos del usuario ---
$given   = "Nombre"
$sur     = "Apellido"
$sam     = "napellido"                       # sAMAccountName (login corto)
$upn     = "$sam@maswer.com"                 # ⚠️ VERIFICAR sufijo UPN
$ou      = "OU=Usuarios,OU=Maswer,DC=intern,DC=maswer,DC=com"   # ⚠️ VERIFICAR
$pwd     = Read-Host "Contraseña inicial" -AsSecureString

New-ADUser `
  -Name "$given $sur" `
  -GivenName $given -Surname $sur `
  -DisplayName "$given $sur" `
  -SamAccountName $sam `
  -UserPrincipalName $upn `
  -Path $ou `
  -AccountPassword $pwd `
  -ChangePasswordAtLogon $true `
  -Enabled $true

# --- Grupos (pertenencia / licencia M365 por grupo) ---
Add-ADGroupMember -Identity "GRUPO-LICENCIA-M365" -Members $sam   # ⚠️ VERIFICAR nombre
# Add-ADGroupMember -Identity "OtroGrupoDepartamento" -Members $sam
```

**Notas:**
- El **buzón** se aprovisiona vía sync + licencia (Exchange híbrido). El nombre/alias
  se edita en **ADUC**, no en M365.
- Tras crear/mover/asignar grupos → **forzar sync** (sección 3).
- Comprobar el alta en M365 solo después de que el sync haya hecho *Export*.

---

## 2. Dar acceso a una carpeta

**Regla:** permisos **por grupo de seguridad**, nunca al usuario directo sobre la ACL.
Se añade al usuario al grupo que ya tiene el permiso NTFS sobre la carpeta.

### 2a. Añadir un usuario a un recurso ya existente (caso normal)
```powershell
Add-ADGroupMember -Identity "FS-Contabilidad-RW" -Members $sam   # ⚠️ VERIFICAR convención
# La pertenencia a grupo se aplica al usuario tras nuevo login / renovación de token Kerberos.
```

### 2b. Carpeta nueva: crear grupo + asignar NTFS (una sola vez, por carpeta)
```powershell
$folder = "\\SERVIDOR\Share\Contabilidad"        # ⚠️ VERIFICAR ruta
$grpRW  = "FS-Contabilidad-RW"                    # ⚠️ VERIFICAR convención

New-ADGroup -Name $grpRW -GroupScope DomainLocal -Path "OU=Grupos,DC=intern,DC=maswer,DC=com"  # ⚠️ VERIFICAR

# Permiso NTFS Modify (RW) al grupo, heredado por subcarpetas y archivos
$acl  = Get-Acl $folder
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
          "INTERN\$grpRW","Modify",
          "ContainerInherit,ObjectInherit","None","Allow")
$acl.AddAccessRule($rule)
Set-Acl -Path $folder -AclObject $acl

# Alternativa con icacls (RW):
# icacls "$folder" /grant "INTERN\${grpRW}:(OI)(CI)M" /T
```

**Comprobar permisos:**
```powershell
Get-Acl "\\SERVIDOR\Share\Contabilidad" | Format-List
Get-ADGroupMember -Identity "FS-Contabilidad-RW" | Select Name,SamAccountName
```

> Los grupos de fichero (recurso local/NTFS) **no** necesitan sync a M365 — son on-prem.
> Solo necesitas sync si el cambio afecta a objetos que se replican a M365.

---

## 3. Forzar sincronización a M365 (cierre)

Tras crear usuario, cambiar grupos de licencia o editar atributos que van a M365:
**RDP a `MEUAZAC011`** → PowerShell admin:

```powershell
Start-ADSyncSyncCycle -PolicyType Delta     # cambios recientes (lo habitual)
Start-ADSyncSyncCycle -PolicyType Initial   # re-evaluación completa si Delta no ve diffs
```

- `"Result: Success"` = el ciclo se **inició**, no que haya terminado (~1–2 min).
- En **Synchronization Service Manager** solo aparece un `Export` a
  `maswerag.onmicrosoft.com` si hubo cambio que empujar.
- El auto-sync corre cada **30 min**; forzar solo acelera.
- La lista de M365 **cachea** — verifica valores reales en Exchange admin center o con `Ctrl+F5`.

---

## Checklist rápido

**Alta de usuario:**
1. [ ] `New-ADUser` en la OU correcta
2. [ ] Añadir a grupos (licencia M365 + departamento + carpetas)
3. [ ] `Start-ADSyncSyncCycle -PolicyType Delta` en MEUAZAC011
4. [ ] Verificar licencia/buzón en M365 tras el Export

**Acceso a carpeta:**
1. [ ] `Add-ADGroupMember` al grupo del recurso (o crear grupo + NTFS si es carpeta nueva)
2. [ ] Confirmar con `Get-Acl` / `Get-ADGroupMember`
3. [ ] El usuario re-inicia sesión para refrescar el token de grupo
