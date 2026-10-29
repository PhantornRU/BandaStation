<# Build and run the isolated direct city map port. Each launch has private saves and logs. #>
[CmdletBinding()]
param(
    [switch]$NoClient,
    [ValidateRange(1024, 65535)][int]$Port = 1343,
    [ValidatePattern('^$|^[A-Za-z0-9_]+$')][string]$AdminKey = '',
    [string]$ByondBin = (Join-Path ${env:ProgramFiles(x86)} 'BYOND\bin')
)
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$compiler = Join-Path $ByondBin 'dm.exe'
$daemon = Join-Path $ByondBin 'dd.exe'
$client = Join-Path $ByondBin 'dreamseeker.exe'
foreach ($file in @($compiler, $daemon)) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { throw "Missing BYOND: $file" }
}
if (Get-NetTCPConnection -State Listen -LocalPort $Port -ErrorAction SilentlyContinue) { throw "Port $Port is already in use." }
$runName = 'sanfrancisco-port-' + [Guid]::NewGuid().ToString('N').Substring(0, 12)
$runtime = Join-Path $repoRoot ('tmp\' + $runName)
New-Item -ItemType Directory -Path $runtime | Out-Null
Push-Location -LiteralPath $repoRoot
try {
    # AI EDIT START - Finish assets before players connect to the isolated playtest
    & $compiler -DCBT -DCITY_PORT_BUILD -DDO_NOT_DEFER_ASSETS tgstation.dme 2>&1 | Tee-Object -FilePath (Join-Path $runtime 'compile.log')
    # AI EDIT END
    if ($LASTEXITCODE -ne 0) { throw "Compilation failed: $runtime\compile.log" }
    foreach ($extension in @('dmb', 'rsc')) {
        Copy-Item -LiteralPath ('tgstation.' + $extension) -Destination (Join-Path $runtime ('city.local.' + $extension))
    }
    foreach ($relative in @('_maps', 'code', 'build\behavior_trees', 'html', 'icons', 'interface', 'modular_bandastation', 'sound', 'strings', 'tgui\public', 'tgui\packages')) {
        $destination = Join-Path $runtime $relative
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
        New-Item -ItemType Junction -Path $destination -Target (Join-Path $repoRoot $relative) | Out-Null
    }
    Get-ChildItem -LiteralPath $repoRoot -Filter '*.dll' -File | Copy-Item -Destination $runtime
    $config = Join-Path $runtime 'config'
    $data = Join-Path $runtime 'data'
    New-Item -ItemType Directory -Path $config, (Join-Path $data 'spritesheets') -Force | Out-Null
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllLines((Join-Path $config 'config.txt'), [string[]]@(
        'SERVERNAME PrimeDream - San Francisco Direct Port', 'LOBBY_COUNTDOWN 30',
        'ADMIN_LEGACY_SYSTEM', 'ENABLE_LOCALHOST_RANK', 'RESUME_AFTER_INITIALIZATIONS',
        '$include resources.txt', '$include game_options.txt'
    ), $utf8)
    [IO.File]::WriteAllLines((Join-Path $config 'resources.txt'), [string[]]@('ASSET_TRANSPORT simple'), $utf8)
    [IO.File]::WriteAllLines((Join-Path $config 'maps.txt'), [string[]]@('map sanfrancisco', 'default', 'endmap'), $utf8)
    $admins = @()
    $adminRanks = @()
    if ($AdminKey) {
        $admins = @($AdminKey + ' = City Local Admin')
        $adminRanks = @('Name = City Local Admin', 'Include = EVERYTHING', 'Exclude =', 'Edit = EVERYTHING')
    }
    [IO.File]::WriteAllLines((Join-Path $config 'admins.txt'), [string[]]$admins, $utf8)
    [IO.File]::WriteAllLines((Join-Path $config 'admin_ranks.txt'), [string[]]$adminRanks, $utf8)
    # AI EDIT START - Keep native movement delays and gameplay configuration in local sessions
    $gameOptions = @(Get-Content -LiteralPath 'config\game_options.txt')
    [IO.File]::WriteAllLines((Join-Path $config 'game_options.txt'), [string[]]($gameOptions + 'FORBID_STATION_TRAITS'), $utf8)
    # AI EDIT END
    $inGreenshift = $false
    $dynamic = @(Get-Content -LiteralPath 'config\dynamic.toml' | ForEach-Object {
        if ($_ -match '^\["([^\"]+)"\]\s*$') { $inGreenshift = $Matches[1] -eq 'Greenshift' }
        if ($_ -match '^weight\s*=') { if ($inGreenshift) { 'weight = 100' } else { 'weight = 0' } } else { $_ }
    })
    [IO.File]::WriteAllLines((Join-Path $config 'dynamic.toml'), [string[]]$dynamic, $utf8)
    Copy-Item -LiteralPath '_maps\map_jsons\sanfrancisco.json' -Destination (Join-Path $data 'next_map.json')
    $server = Start-Process -FilePath $daemon -WorkingDirectory $runtime -WindowStyle Hidden -PassThru `
        -ArgumentList @('city.local.dmb', '-port', "$Port", '-trusted', '-invisible', '-log', 'console.log', '-params', ('log-directory=' + $runName))
    [IO.File]::WriteAllText((Join-Path $runtime 'server.json'), (@{pid=$server.Id;start_ticks=$server.StartTime.ToUniversalTime().Ticks;daemon=$daemon;port=$Port} | ConvertTo-Json), $utf8)
    Write-Output "City prototype started. PID $($server.Id), byond://127.0.0.1:$Port"
    Write-Output "Logs: $runtime"
    Write-Output 'The initial five-floor map load takes several minutes. Leave this server running while playing.'
    if (-not $NoClient) { Start-Process -FilePath $client -ArgumentList "byond://127.0.0.1:$Port" }
} finally {
    Pop-Location
}
