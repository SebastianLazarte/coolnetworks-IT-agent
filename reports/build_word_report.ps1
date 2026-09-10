<#
.SYNOPSIS
  Genera un .docx a partir de un reporte en Markdown usando Word COM.

.DESCRIPTION
  Pipeline documentado en reports/CONTEXT.md. No hay Python ni pandoc en este entorno.
  Soporta: encabezados # / ## / ###, **negrita**, *cursiva*, listas con "- ",
  tablas | ... | y separadores ---.

  Usa indices de estilo integrados (wdStyleHeading1 = -2, etc.) en lugar de nombres,
  para que funcione con Word en cualquier idioma de interfaz.

.EXAMPLE
  .\build_word_report.ps1 -MdPath .\drafts\informe.md -DocxPath ..\final\informe.docx
#>
param(
    [Parameter(Mandatory = $true)][string]$MdPath,
    [Parameter(Mandatory = $true)][string]$DocxPath
)

$ErrorActionPreference = 'Stop'

# Indices de estilo integrados de Word (WdBuiltinStyle)
$STYLE_NORMAL = -1
$STYLE_H1     = -2
$STYLE_H2     = -3
$STYLE_H3     = -4
$STYLE_BULLET = -49
$STYLE_TITLE  = -63

$WD_STORY     = 6   # wdStory
$WD_LINE_SNGL = 1   # wdLineStyleSingle

if (-not (Test-Path -LiteralPath $MdPath)) {
    throw "No existe el Markdown de entrada: $MdPath"
}

$MdPath   = (Resolve-Path -LiteralPath $MdPath).Path
$outDir   = Split-Path -Parent $DocxPath
if ($outDir -and -not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
}
$DocxPath = [System.IO.Path]::GetFullPath(
    [System.IO.Path]::Combine((Get-Location).Path, $DocxPath)
)

$lines = Get-Content -LiteralPath $MdPath -Encoding UTF8

# --- helpers -------------------------------------------------------------

function Remove-InlineMarks {
    param([string]$Text)
    $t = $Text -replace '\*\*(.+?)\*\*', '$1'
    $t = $t -replace '(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)', '$1'
    $t = $t -replace '`(.+?)`', '$1'
    return $t
}

# Escribe texto en la seleccion respetando **negrita** y *cursiva*.
function Write-Inline {
    param($Selection, [string]$Text)

    $pattern = '(\*\*.+?\*\*|(?<!\*)\*(?!\*).+?(?<!\*)\*(?!\*)|`.+?`)'
    $parts = [regex]::Split($Text, $pattern) | Where-Object { $_ -ne '' }

    foreach ($part in $parts) {
        $bold = $false
        $ital = $false
        $chunk = $part

        if ($part -like '**?*' -and $part.StartsWith('**') -and $part.EndsWith('**')) {
            $bold = $true
            $chunk = $part.Substring(2, $part.Length - 4)
        }
        elseif ($part.StartsWith('*') -and $part.EndsWith('*') -and $part.Length -gt 2) {
            $ital = $true
            $chunk = $part.Substring(1, $part.Length - 2)
        }
        elseif ($part.StartsWith('`') -and $part.EndsWith('`') -and $part.Length -gt 2) {
            $chunk = $part.Substring(1, $part.Length - 2)
        }

        if ($bold) { $Selection.Font.Bold = $true }
        if ($ital) { $Selection.Font.Italic = $true }
        $Selection.TypeText($chunk)
        if ($bold) { $Selection.Font.Bold = $false }
        if ($ital) { $Selection.Font.Italic = $false }
    }
}

function Split-Row {
    param([string]$Line)
    $trimmed = $Line.Trim()
    $trimmed = $trimmed -replace '^\|', ''
    $trimmed = $trimmed -replace '\|$', ''
    return ($trimmed -split '\|') | ForEach-Object { $_.Trim() }
}

function Test-SeparatorRow {
    param([string]$Line)
    return ($Line -match '^\s*\|[\s:\-\|]+\|\s*$')
}

# --- Word ----------------------------------------------------------------

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0

try {
    $doc = $word.Documents.Add()
    $sel = $word.Selection

    $i = 0
    $firstHeading = $true

    while ($i -lt $lines.Count) {
        $line = $lines[$i]
        $trim = $line.Trim()

        # --- tabla ---
        if ($trim -match '^\|') {
            $block = @()
            while ($i -lt $lines.Count -and $lines[$i].Trim() -match '^\|') {
                if (-not (Test-SeparatorRow $lines[$i])) { $block += $lines[$i] }
                $i++
            }

            if ($block.Count -gt 0) {
                $rows = @()
                foreach ($b in $block) { $rows += , (Split-Row $b) }

                $colCount = 0
                foreach ($r in $rows) { if ($r.Count -gt $colCount) { $colCount = $r.Count } }

                $sel.Style = $doc.Styles.Item($STYLE_NORMAL)
                $tbl = $doc.Tables.Add($sel.Range, $rows.Count, $colCount)
                $tbl.Borders.InsideLineStyle  = $WD_LINE_SNGL
                $tbl.Borders.OutsideLineStyle = $WD_LINE_SNGL
                $tbl.Range.Font.Size = 9
                $tbl.Rows.Item(1).HeadingFormat = $true

                for ($r = 0; $r -lt $rows.Count; $r++) {
                    for ($c = 0; $c -lt $colCount; $c++) {
                        $cellText = ''
                        if ($c -lt $rows[$r].Count) { $cellText = $rows[$r][$c] }

                        $cellBold = ($cellText -match '^\*\*.*\*\*$')
                        $cellText = Remove-InlineMarks $cellText

                        $cell = $tbl.Cell($r + 1, $c + 1)
                        $cell.Range.Text = $cellText
                        if ($r -eq 0 -or $cellBold) { $cell.Range.Font.Bold = $true }
                    }
                }

                $sel.EndKey($WD_STORY) | Out-Null
                $sel.TypeParagraph()
            }
            continue
        }

        # --- separador horizontal ---
        if ($trim -match '^-{3,}$') {
            $i++
            continue
        }

        # --- linea en blanco ---
        if ($trim -eq '') {
            $i++
            continue
        }

        # --- encabezados ---
        if ($trim -match '^(#{1,3})\s+(.*)$') {
            $level = $Matches[1].Length
            $text  = $Matches[2]

            if ($level -eq 1 -and $firstHeading) {
                $sel.Style = $doc.Styles.Item($STYLE_TITLE)
                $firstHeading = $false
            }
            elseif ($level -eq 1) { $sel.Style = $doc.Styles.Item($STYLE_H1) }
            elseif ($level -eq 2) { $sel.Style = $doc.Styles.Item($STYLE_H2) }
            else                  { $sel.Style = $doc.Styles.Item($STYLE_H3) }

            Write-Inline -Selection $sel -Text $text
            $sel.TypeParagraph()
            $sel.Style = $doc.Styles.Item($STYLE_NORMAL)
            $i++
            continue
        }

        # --- vinneta ---
        if ($trim -match '^[-\*]\s+(.*)$') {
            $sel.Style = $doc.Styles.Item($STYLE_BULLET)
            Write-Inline -Selection $sel -Text $Matches[1]
            $sel.TypeParagraph()
            $sel.Style = $doc.Styles.Item($STYLE_NORMAL)
            $i++
            continue
        }

        # --- parrafo normal ---
        $sel.Style = $doc.Styles.Item($STYLE_NORMAL)
        Write-Inline -Selection $sel -Text $trim
        $sel.TypeParagraph()
        $i++
    }

    $doc.SaveAs([ref]$DocxPath, [ref]16)   # 16 = wdFormatDocumentDefault (.docx)
    $doc.Close()
    Write-Output "OK -> $DocxPath"
}
finally {
    $word.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null
}
