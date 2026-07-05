# GESTIÓN DE CONTINGENCIA — RECUPERACIÓN DE DATOS

**Cliente:** Maswer Spain S.L.
**Área:** Calidad / Documentación ISO (unidad `R:` — `QM\ISO 14001 Spain`)
**Gestionado por:** CoolNetworks — Soporte IT
**Fecha del caso:** junio 2026

---

## Resumen

Ante la falta de dos archivos de documentación ISO reportada por una usuaria del área de
Calidad, CoolNetworks ejecutó un procedimiento de investigación y recuperación que concluyó
con **el 100 % de la documentación restaurada en producción y sin pérdida de datos**.

El presente documento detalla el procedimiento seguido, paso a paso, desde la localización
del recurso hasta la restauración y verificación final.

---

## Situación reportada

Una usuaria del área de Calidad indicó que faltaban dos archivos Excel que debían estar
en la unidad corporativa `R:` (documentación del sistema de gestión ISO):

- `IntAudit_ES`
- `H_Necesidades_de_formación 2026`

La usuaria aportó una captura de la unidad mapeada `R:`, sin la ruta real del servidor.

---

## Datos clave del entorno

| Dato | Valor |
|---|---|
| Servidor de ficheros | `MDERZFIL001.intern.maswer.com` |
| Recurso compartido | `\\MDERZFIL001\maswer` (ruta local `D:\Shares\Maswer`) |
| Unidad `R:` | `\\MDERZFIL001\maswer\maswerspainsl` (etiqueta *Maswer Spain S.L.*) |
| Carpeta de la documentación | `D:\Shares\Maswer\maswerspainsl\QM\ISO 14001 Spain` |

---

## Procedimiento realizado (paso a paso)

### 1. Localización de la ruta real detrás de `R:`
La captura solo mostraba la letra `R:`, no el servidor. Como los equipos están unidos al
dominio, se localizó la definición del mapeo de unidad en las directivas de grupo (Drive Maps),
almacenadas en `SYSVOL`:

```powershell
Get-ChildItem "\\intern.maswer.com\SYSVOL\intern.maswer.com\Policies" -Recurse -Filter "Drives.xml" |
  ForEach-Object { $c = Get-Content $_.FullName -Raw; if ($c -match 'letter="R"') { $_.FullName; $c } }
```

Resultado: `R:` → `\\MDERZFIL001\maswer\maswerspainsl`, confirmando la carpeta exacta
`\\MDERZFIL001\maswer\maswerspainsl\QM\ISO 14001 Spain`.

### 2. Investigación de los dos archivos
Inventario de la carpeta y búsqueda recursiva bajo `QM`:

- **`H_Necesidades_de_formación 2026.xlsx`** → **localizado**. No estaba borrado; se encontraba
  en la subcarpeta `Formación`, un nivel por debajo de donde se buscaba.
- **`IntAudit_ES`** → **ausente** de la carpeta: confirmado que había sido eliminado.

### 3. Comprobación de las copias de seguridad (instantáneas de volumen)
Se verificó que el volumen `D:` del servidor mantiene **copias instantáneas (Shadow Copies)**,
con dos copias diarias. Cada copia conserva el estado de la carpeta en un momento anterior:

```powershell
Invoke-Command -ComputerName MDERZFIL001 { Get-CimInstance Win32_ShadowCopy |
  Select-Object InstallDate, DeviceObject | Sort-Object InstallDate }
```

### 4. Identificación de la copia válida para restaurar
Se recorrieron las copias instantáneas comprobando en cuáles seguía existiendo el archivo,
para restaurar desde la **última copia que aún lo contenía**:

| Copia instantánea | `IntAudit_ES` |
|---|---|
| 15/06/2026 12:00 | Presente |
| 15/06/2026 18:00 | Ausente |

→ La copia del **15/06/2026 12:00** era la última con el archivo intacto: la fuente de restauración.

### 5. Recuperación y restauración
Se copió el archivo (y su copia asociada) desde esa instantánea a la carpeta de producción,
**sin sobrescribir ni alterar ningún otro dato**:

```powershell
Invoke-Command -ComputerName MDERZFIL001 {
  $snap = Get-CimInstance Win32_ShadowCopy |
          Where-Object { $_.InstallDate -ge '2026-06-15 12:00' -and $_.InstallDate -lt '2026-06-15 12:05' }
  $src  = $snap.DeviceObject + '\Shares\Maswer\maswerspainsl\QM\ISO 14001 Spain'
  $dest = 'D:\Shares\Maswer\maswerspainsl\QM\ISO 14001 Spain'
  Copy-Item -LiteralPath "$src\IntAudit_ES_20260514.xlsx" -Destination $dest
  Copy-Item -LiteralPath "$src\Copia de IntAudit_ES_20260514.xlsx" -Destination $dest
}
```

### 6. Verificación
Se confirmó que los archivos quedaron restaurados en su carpeta original y accesibles desde
`R:\QM\ISO 14001 Spain`, y se comunicó la resolución a la usuaria.

| Archivo restaurado | Tamaño | Última modificación original |
|---|---|---|
| `IntAudit_ES_20260514.xlsx` | 32.628 bytes | 16/05/2026 19:17 |
| `Copia de IntAudit_ES_20260514.xlsx` | 32.937 bytes | 04/06/2026 18:07 |

---

## Resultado

| Elemento | Estado final |
|---|---|
| `IntAudit_ES_20260514.xlsx` | Recuperado y restaurado en producción |
| `Copia de IntAudit_ES_20260514.xlsx` | Recuperada y restaurada en producción |
| `H_Necesidades_de_formación 2026.xlsx` | Localizado (no estaba borrado) |
| Pérdida de datos | Ninguna |
| Impacto en otros archivos | Ninguno |
| Incidente de seguridad | No |

---

## Valoración

- Documentación ISO **íntegra y disponible** tras la contingencia.
- Procedimiento de recuperación **efectivo y trazable**, apoyado en las copias de seguridad del servidor.
- Restauración realizada **sin impacto** para el resto de la documentación ni para los usuarios.

---

*Documento preparado por CoolNetworks · 2 de julio de 2026.*
