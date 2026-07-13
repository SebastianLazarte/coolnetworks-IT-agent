<#
Converts a CoolNetworks Markdown report into a .docx via Word COM automation
(no Python/pandoc available in this environment — see reports/CONTEXT.md).

Usage: .\build_word_report.ps1 -MdPath <in.md> -DocxPath <out.docx>
#>
param(
    [Parameter(Mandatory = $true)][string]$MdPath,
    [Parameter(Mandatory = $true)][string]$DocxPath
)

# Built-in style indices (locale-independent — Word here is Spanish, so
# Styles.Item("Heading 1") fails; these WdBuiltinStyle constants do not).
$wdStyleNormal = -1
$wdStyleHeading1 = -2
$wdStyleHeading2 = -3
$wdStyleTitle = -63

function Strip-Bold([string]$text) {
    return ($text -replace '\*\*(.*?)\*\*', '$1')
}

function Add-InlineText($sel, [string]$text) {
    $parts = [regex]::Split($text, '(\*\*.*?\*\*)')
    foreach ($part in $parts) {
        if ($part -match '^\*\*(.*)\*\*$') {
            $sel.Font.Bold = $true
            $sel.TypeText($Matches[1])
            $sel.Font.Bold = $false
        } elseif ($part -ne '') {
            $sel.TypeText($part)
        }
    }
}

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$doc = $word.Documents.Add()
$sel = $word.Selection

$lines = Get-Content -Path $MdPath -Encoding UTF8

$i = 0
while ($i -lt $lines.Count) {
    $line = $lines[$i]

    if ($line -match '^# (.*)') {
        $sel.Style = $wdStyleTitle
        $sel.TypeText($Matches[1])
        $sel.TypeParagraph()
        $sel.Style = $wdStyleNormal
    }
    elseif ($line -match '^## (.*)') {
        $sel.Style = $wdStyleHeading1
        $sel.TypeText($Matches[1])
        $sel.TypeParagraph()
        $sel.Style = $wdStyleNormal
    }
    elseif ($line -match '^### (.*)') {
        $sel.Style = $wdStyleHeading2
        $sel.TypeText($Matches[1])
        $sel.TypeParagraph()
        $sel.Style = $wdStyleNormal
    }
    elseif ($line -match '^---\s*$') {
        # horizontal rule in source — just a paragraph break in the output
    }
    elseif ($line -match '^\|') {
        $tableLines = New-Object System.Collections.Generic.List[string]
        while ($i -lt $lines.Count -and $lines[$i] -match '^\|') {
            $tableLines.Add($lines[$i])
            $i++
        }
        $i--
        $rows = @()
        foreach ($tl in $tableLines) {
            if ($tl -match '^\|[\s\-\|:]+\|$') { continue }
            $cells = $tl.Trim().Trim('|') -split '\|' | ForEach-Object { Strip-Bold($_.Trim()) }
            $rows += ,$cells
        }
        if ($rows.Count -gt 0) {
            $nRows = $rows.Count
            $nCols = $rows[0].Count
            $range = $sel.Range
            $table = $doc.Tables.Add($range, $nRows, $nCols)
            $table.Borders.Enable = $true
            for ($r = 0; $r -lt $nRows; $r++) {
                for ($c = 0; $c -lt $nCols; $c++) {
                    if ($c -lt $rows[$r].Count) {
                        $cellRange = $table.Cell($r + 1, $c + 1).Range
                        $cellRange.Text = $rows[$r][$c]
                        if ($r -eq 0) { $cellRange.Font.Bold = $true }
                    }
                }
            }
            $sel.EndKey(6) | Out-Null
            $sel.TypeParagraph()
        }
    }
    elseif ($line -match '^- (.*)') {
        $sel.TypeText([char]0x2022 + " ")
        Add-InlineText $sel $Matches[1]
        $sel.TypeParagraph()
    }
    elseif ($line -match '^\*([^\*].*[^\*])\*$') {
        $sel.Font.Italic = $true
        $sel.TypeText($Matches[1])
        $sel.Font.Italic = $false
        $sel.TypeParagraph()
    }
    elseif ($line.Trim() -eq '') {
        $sel.TypeParagraph()
    }
    else {
        Add-InlineText $sel $line
        $sel.TypeParagraph()
    }
    $i++
}

$resolvedDocxPath = [System.IO.Path]::GetFullPath($DocxPath)
$doc.SaveAs([ref]$resolvedDocxPath, [ref]16)
$doc.Close()
$word.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
Write-Output "Saved: $resolvedDocxPath"
