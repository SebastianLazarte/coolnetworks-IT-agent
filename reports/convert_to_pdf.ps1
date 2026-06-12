param(
    [string]$DocxPath,
    [string]$PdfPath
)

$word = New-Object -ComObject Word.Application
$word.Visible = $false
try {
    $doc = $word.Documents.Open($DocxPath)
    # wdFormatPDF = 17
    $doc.SaveAs([ref]$PdfPath, [ref]17)
    $doc.Close()
    Write-Output "PDF_OK"
} finally {
    $word.Quit()
}
