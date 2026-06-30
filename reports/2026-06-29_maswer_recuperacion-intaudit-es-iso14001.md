# Maswer — Recuperación de Excel borrados en ISO 14001 Spain (R:)

**Responsable:** Sebastian Lazarte Castellón (CoolNetworks — IT de Maswer)
**Fecha:** 29-jun-2026
**Estado:** RESUELTO — archivo recuperado y restaurado en producción

---

## Petición original

Miguel reporta por correo que le faltan **dos archivos Excel** que deberían estar en la unidad `R:` (etiquetada *Maswer Spain S.L.*), ruta `R:\QM\ISO 14001 Spain`:

- `IntAudit_ES`
- `H_Necesidades_de_formación_ 2026`

Solo aportó un *screenshot* de la barra de direcciones del Explorador (unidad mapeada `R:`), sin la ruta UNC real del servidor. Petición derivada: averiguar **quién/cuándo** se borró.

---

## Resumen ejecutivo

- **`IntAudit_ES_20260514.xlsx`** (y su `Copia de…`) → estaba borrado. **Recuperado** desde copia instantánea y restaurado en su carpeta.
- **`H_Necesidades_de_formación_2026.xlsx`** → **nunca se borró**; estaba en la subcarpeta `Formación`, un nivel por debajo de donde Miguel lo buscaba.
- **Quién lo borró:** no determinable (sin auditoría en la carpeta + log de seguridad de solo 6 días). **Cuándo:** acotado a la tarde del **15/06/2026, entre 12:00 y 18:00**.

---

## Datos clave del entorno

| Dato | Valor |
|---|---|
| Dominio | `intern.maswer.com` (DC: `MEUAZDC011`) |
| Servidor de ficheros | `MDERZFIL001.intern.maswer.com` |
| Recurso compartido | `\\MDERZFIL001\maswer` → ruta local `D:\Shares\Maswer` |
| Mapeo de `R:` | GPO `{43D531D0-3B0C-4AE8-A271-DD873B5A1632}` → `\\MDERZFIL001.intern.maswer.com\maswer\maswerspainsl`, label *"Maswer Spain S.L."* |
| Ruta de la carpeta | `D:\Shares\Maswer\maswerspainsl\QM\ISO 14001 Spain` |
| Grupo de seguridad | `MaswES_QM_RW` (RW sobre la carpeta QM) |

---

## Pasos realizados

### 1. Encontrar la ruta UNC real detrás de `R:`
El screenshot solo mostraba la letra `R:`, no el servidor. Como el equipo del técnico está unido al dominio, se buscó la **definición del mapeo en las Group Policy Preferences** (Drive Maps), que se almacenan en SYSVOL:

```powershell
Get-ChildItem "\\intern.maswer.com\SYSVOL\intern.maswer.com\Policies" -Recurse -Filter "Drives.xml" |
  ForEach-Object { $c = Get-Content $_.FullName -Raw; if ($c -match 'letter="R"') { $_.FullName; $c } }
```

Resultado — `Drives.xml` de la GPO `{43D531D0-…}`:
```xml
<Drive name="R:" ...>
  <Properties action="R" path="\\MDERZFIL001.intern.maswer.com\maswer\maswerspainsl"
              label="Maswer Spain S.L." letter="R" .../>
</Drive>
```
→ Ruta confirmada: `\\MDERZFIL001\maswer\maswerspainsl\QM\ISO 14001 Spain`.

> Antes se intentó vía `gpmc.msc` (no abría) y vía perfil/logon-script de los usuarios del grupo `MaswES_QM_RW` en ADUC (vacío). SYSVOL fue la fuente fiable.

### 2. Intentar identificar al autor del borrado
- Acceso remoto al servidor: **RPC bloqueado**, pero **WinRM disponible** (`Invoke-Command -ComputerName MDERZFIL001`).
- La auditoría de acceso a objetos **sí genera eventos** (1228 eventos 4660/4663), pero:
  - **El registro de seguridad solo retiene ~6 días** (log de 20 MB lleno, eventos desde el 23/06/2026). El borrado del 15/06 quedó fuera.
  - **La carpeta `ISO 14001 Spain` tiene la SACL vacía** → los borrados ahí **no se auditan**. Los 1228 eventos provienen de otras carpetas con SACL.

```powershell
Invoke-Command -ComputerName MDERZFIL001 { (Get-Acl 'D:\Shares\Maswer\maswerspainsl\QM\ISO 14001 Spain' -Audit).Audit }  # vacío
```
→ **Conclusión: el autor no es determinable** con la configuración actual.

### 3. Buscar los archivos y comprobar copias instantáneas (VSS)
- Inventario actual de la carpeta + búsqueda recursiva en `QM`:
  - `H_Necesidades_de_formación_2026.xlsx` → **presente** en `…\ISO 14001 Spain\Formación\`.
  - `IntAudit_ES` → **ausente** (solo existían versiones alemanas `IntAudit_HEF_*` bajo `ISO 14001 GmbH`).
- El volumen `D:` del servidor tiene **shadow copies** (2 diarias, ~06:00 y ~12:00/18:00) desde el **29/05/2026**.

### 4. Acotar la fecha del borrado (línea temporal por snapshots)
Se recorrieron las copias instantáneas comprobando la presencia del archivo. Acceso a cada snapshot por su `DeviceObject` (ej. `\\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy64\Shares\Maswer\…`):

| Snapshot | `IntAudit_ES` |
|---|---|
| 15/06/2026 12:00 | ✅ presente |
| 15/06/2026 18:00 | ❌ ausente |

→ **Borrado el 15/06/2026 entre las 12:00 y las 18:00.**

### 5. Recuperar y restaurar
Copia desde el último snapshot con el archivo (15/06 12:00) a la carpeta de producción (sin sobrescribir nada):

```powershell
Invoke-Command -ComputerName MDERZFIL001 {
  $snap = Get-CimInstance Win32_ShadowCopy | Where-Object { $_.InstallDate -ge '2026-06-15 12:00' -and $_.InstallDate -lt '2026-06-15 12:05' }
  $src  = $snap.DeviceObject + '\Shares\Maswer\maswerspainsl\QM\ISO 14001 Spain'
  $dest = 'D:\Shares\Maswer\maswerspainsl\QM\ISO 14001 Spain'
  Copy-Item -LiteralPath "$src\IntAudit_ES_20260514.xlsx" -Destination $dest
  Copy-Item -LiteralPath "$src\Copia de IntAudit_ES_20260514.xlsx" -Destination $dest
}
```

| Archivo restaurado | Tamaño | Modif. original |
|---|---|---|
| `IntAudit_ES_20260514.xlsx` | 32.628 bytes | 16/05/2026 19:17 |
| `Copia de IntAudit_ES_20260514.xlsx` | 32.937 bytes | 04/06/2026 18:07 |

Ubicación final: `\\MDERZFIL001\maswer\maswerspainsl\QM\ISO 14001 Spain\` (= `R:\QM\ISO 14001 Spain\`).

---

## Respuesta a Miguel (borrador)

```
Hola Miguel,

Ya está resuelto:

- IntAudit_ES: estaba borrado; lo he recuperado de una copia de seguridad y
  vuelve a estar en R:\QM\ISO 14001 Spain (también la "Copia de…").
- H_Necesidades_de_formación_2026: no estaba borrado, está dentro de la
  subcarpeta "Formación": R:\QM\ISO 14001 Spain\Formación\

Avísame si los ves bien.

Un saludo
```

---

## Recomendaciones (prevención)

Los archivos se borraron **sin dejar rastro de autor**. Para que en el futuro sí se pueda saber quién borra y para tener más margen de recuperación:

1. **Activar SACL de auditoría de borrado** en `…\maswerspainsl` (o al menos en `QM`): *Delete / Delete subfolders and files* para *Everyone* → Success.
2. **Ampliar el registro de seguridad** de `MDERZFIL001` (los 20 MB actuales rotan en ~6 días) y/o reenviarlo a un colector (WEF/SIEM).
3. Revisar que la política de auditoría de "File System" (object access) esté efectivamente activa por GPO.
4. Confirmar la frecuencia/retención de las shadow copies (hoy salvaron el caso, pero conviene asegurarlas).

> Cambios de auditoría/ACL a nivel servidor en Maswer los administra **conet.de**. Ver [[2026-06-23_maswer_recuperacion-accesos-post-oliver]].
```
