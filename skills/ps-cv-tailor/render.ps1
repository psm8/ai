param([Parameter(Mandatory)][string]$Company)
# Render CV-<Company>.md to docx (styled from the base CV docx) and pdf; fail unless it fits on 1 page.
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path "$PSScriptRoot/../../..").Path
$md = Join-Path $root "CV-$Company.md"
$docx = Join-Path $root "output/CV-PiotrSeemann-$Company.docx"
$pdf = [IO.Path]::ChangeExtension($docx, '.pdf')

python "$PSScriptRoot/md2docx.py" (Join-Path $root 'output/CV-PiotrSeemann.docx') $md $docx
if ($LASTEXITCODE) { throw 'md2docx failed' }

$word = New-Object -ComObject Word.Application
try {
    $doc = $word.Documents.Open($docx)
    $pages = $doc.ComputeStatistics(2)
    $doc.SaveAs2($pdf, 17)
    $doc.Close($false)
} finally { $word.Quit() }

"pages: $pages"
"written: $docx, $pdf"
if ($pages -ne 1) { throw "CV is $pages pages, must be 1" }
