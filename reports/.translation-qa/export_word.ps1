$wordTranslate = New-Object -ComObject Word.Application
$wordTranslate.Visible = $false
$wordTranslate.DisplayAlerts = 0
try {
 foreach ($entry in @(@('reports/final/2026-09-09_maswer_it-executive-report-en.docx','executive-final3'),@('reports/especiales/2026-09-09_maswer_unused-accounts-and-devices-audit-en.docx','audit-final3'))) {
  $outTranslate = Join-Path (Get-Location) ('reports/.translation-qa/' + $entry[1])
  New-Item -ItemType Directory -Force -Path $outTranslate | Out-Null
  $docTranslate = $wordTranslate.Documents.Open((Join-Path (Get-Location) $entry[0]),$false,$true)
  $docTranslate.ExportAsFixedFormat((Join-Path $outTranslate 'render.pdf'),17)
  $docTranslate.Close(0)
  Write-Output $outTranslate
 }
} finally { $wordTranslate.Quit() }
