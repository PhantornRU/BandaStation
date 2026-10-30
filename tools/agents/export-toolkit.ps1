param([Parameter(Mandatory=$true)][string]$Destination)
# Export shared sources without installing runtime or repository hooks
$ErrorActionPreference = 'Stop'
& py -3 -B (Join-Path $PSScriptRoot 'toolkit.py') export --destination $Destination
if ($LASTEXITCODE -ne 0) { throw 'Toolkit export failed.' }
