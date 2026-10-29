<# Stop only city prototype processes recorded by this checkout's launcher. #>
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
foreach ($run in Get-ChildItem -LiteralPath (Join-Path $repoRoot 'tmp') -Directory -Filter 'sanfrancisco-port-*' -ErrorAction SilentlyContinue) {
    $statePath = Join-Path $run.FullName 'server.json'
    if (-not (Test-Path -LiteralPath $statePath -PathType Leaf)) { continue }
    $state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
    $server = Get-Process -Id ([int]$state.pid) -ErrorAction SilentlyContinue
    if (-not $server) { continue }
    if ($server.StartTime.ToUniversalTime().Ticks -ne [long]$state.start_ticks -or $server.Path -ne $state.daemon) {
        throw "Saved PID no longer belongs to this city server: $statePath"
    }
    Stop-Process -Id $server.Id
    Write-Output "Stopped city prototype PID $($server.Id). Logs remain in $($run.FullName)"
}
