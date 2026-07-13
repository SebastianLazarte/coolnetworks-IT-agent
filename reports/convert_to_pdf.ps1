<#
Exports an existing .docx to .pdf via Word COM automation.

Usage: .\convert_to_pdf.ps1 -DocxPath <in.docx> -PdfPath <out.pdf>
#>
param(
    [Parameter(Mandatory = $true)][string]$DocxPath,
    [Parameter(Mandatory = $true)][string]$PdfPath
)

$resolvedDocxPath = [System.IO.Path]::GetFullPath($DocxPath)
$resolvedPdfPath = [System.IO.Path]::GetFullPath($PdfPath)

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$doc = $word.Documents.Open($resolvedDocxPath)
$doc.SaveAs([ref]$resolvedPdfPath, [ref]17)
$doc.Close()
$word.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
Write-Output "Saved: $resolvedPdfPath"
