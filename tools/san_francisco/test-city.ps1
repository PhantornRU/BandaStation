<# Compile focused city integration tests and run the actual primary map in an isolated deployment. #>
[CmdletBinding()]
param(
    [string]$ByondBin = (Join-Path ${env:ProgramFiles(x86)} 'BYOND\bin'),
    [ValidateRange(30, 3600)][int]$CompileTimeoutSeconds = 600,
    [ValidateRange(30, 3600)][int]$TimeoutSeconds = 900
)
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$mapConfig = Join-Path $repoRoot '_maps\map_jsons\sanfrancisco.json'
$mapFile = Join-Path $repoRoot '_maps\map_files\SanFrancisco\sanfrancisco.dmm'
$testSource = Join-Path $repoRoot 'modular_bandastation\san_francisco\code\tests.dm'
$compiler = Join-Path $ByondBin 'dm.exe'
$daemon = Join-Path $ByondBin 'dd.exe'
foreach ($requiredFile in @($compiler, $daemon, $mapConfig, $mapFile, $testSource)) {
    if (-not (Test-Path -LiteralPath $requiredFile -PathType Leaf)) { throw "Missing city test input: $requiredFile" }
}
$cityConfig = Get-Content -LiteralPath $mapConfig -Raw | ConvertFrom-Json
if ($cityConfig.map_name -ne 'San Francisco') { throw 'The supplied JSON is not the primary San Francisco map.' }
$tests = @(Select-String -LiteralPath $testSource -Pattern '^(/datum/unit_test/san_francisco/[^\s(]+)/Run\(' |
    ForEach-Object { $_.Matches[0].Groups[1].Value })
if (-not $tests.Count) { throw 'No city integration tests were found.' }
$tests += '/datum/unit_test/maptest_job_roundstart_spawnpoints',
    '/datum/unit_test/maptest_mapload_space_verification',
    '/datum/unit_test/san_francisco_tgm_attribute_alignment'
$tests = @($tests | Sort-Object -Unique)
$requiredTests = @($tests | Where-Object { $_ -notlike '/datum/unit_test/focus_only/*' })
$ignoredRequired = @($requiredTests | Where-Object { $_ -in @($cityConfig.ignored_unit_tests) })
if ($ignoredRequired.Count) { throw "The city JSON disables required checks: $($ignoredRequired -join ', ')" }

function Wait-CityProcess {
    param([Diagnostics.Process]$Process, [int]$LimitSeconds, [string]$Phase)
    $timer = [Diagnostics.Stopwatch]::StartNew()
    $nextProgress = 30
    while (-not $Process.WaitForExit(1000)) {
        if ($timer.Elapsed.TotalSeconds -ge $LimitSeconds) {
            # Only terminate the exact child process started by this test invocation.
            $Process.Kill()
            $Process.WaitForExit()
            throw "$Phase timed out after $LimitSeconds seconds (PID $($Process.Id))."
        }
        if ($timer.Elapsed.TotalSeconds -ge $nextProgress) {
            Write-Output "$Phase running: $([int]$timer.Elapsed.TotalSeconds)s (PID $($Process.Id))."
            $nextProgress += 30
        }
    }
    $Process.WaitForExit()
}

$runName = 'san-francisco-' + [Guid]::NewGuid().ToString('N').Substring(0, 12)
$runDirectory = Join-Path $repoRoot ('tmp\' + $runName)
$wrapper = Join-Path $repoRoot ($runName + '.test.dme')
New-Item -ItemType Directory -Path $runDirectory | Out-Null
$manifestPath = Join-Path $runDirectory 'run-manifest.json'
$manifest = [ordered]@{
    status = 'preparing'
    started = (Get-Date).ToString('o')
    map_name = $cityConfig.map_name
    map_file = $mapFile
    map_sha256 = (Get-FileHash -LiteralPath $mapFile -Algorithm SHA256).Hash.ToLowerInvariant()
    map_config_sha256 = (Get-FileHash -LiteralPath $mapConfig -Algorithm SHA256).Hash.ToLowerInvariant()
    compiler = $compiler
    daemon = $daemon
    compiler_defines = @('CBT', 'UNIT_TESTS', 'CITY_PORT_BUILD')
    focused_tests = $tests
}
Write-Output "City test artifacts: $runDirectory"
Push-Location -LiteralPath $repoRoot
try {
    [IO.File]::WriteAllLines($wrapper, [string[]](@('#include "tgstation.dme"') + @($tests | ForEach-Object { 'TEST_FOCUS(' + $_ + ')' })), $utf8NoBom)
    [IO.File]::WriteAllLines((Join-Path $runDirectory 'focused-tests.txt'), [string[]]$tests, $utf8NoBom)
    $manifest.status = 'compiling'
    [IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 6), $utf8NoBom)
    # Keep the normal compiled world footprint: MINIMAL_CENTCOM would center the larger city at negative coordinates and crop it.
    $compile = Start-Process -FilePath $compiler -WorkingDirectory $repoRoot -WindowStyle Hidden -PassThru `
        -ArgumentList "-DCBT -DUNIT_TESTS -DCITY_PORT_BUILD $runName.test.dme" `
        -RedirectStandardOutput (Join-Path $runDirectory 'compile.log') `
        -RedirectStandardError (Join-Path $runDirectory 'compile.stderr.log')
    $manifest.compile_pid = $compile.Id
    try {
        Wait-CityProcess -Process $compile -LimitSeconds $CompileTimeoutSeconds -Phase 'City compilation'
        $manifest.compile_exit_code = $compile.ExitCode
    } finally {
        if (-not $compile.HasExited) { $compile.Kill(); $compile.WaitForExit() }
        $compile.Dispose()
    }
    if ($manifest.compile_exit_code -ne 0) { throw "City compilation failed: $runDirectory\compile.log" }
    foreach ($extension in @('.dmb', '.rsc')) {
        $compiledFile = [IO.Path]::ChangeExtension($wrapper, $extension)
        if (-not (Test-Path -LiteralPath $compiledFile)) { throw "Compiler did not produce $compiledFile" }
        Move-Item -LiteralPath $compiledFile -Destination (Join-Path $runDirectory ('city.test' + $extension))
    }

    # Assets are read from the checkout; configs, saves, generated assets and every log belong to this run.
    foreach ($relative in @('_maps', 'build\behavior_trees', 'code\datums\greyscale\json_configs', 'icons', 'sound\runtime', 'strings', 'tgui\public', 'modular_bandastation')) {
        $destination = Join-Path $runDirectory $relative
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
        New-Item -ItemType Junction -Path $destination -Target (Join-Path $repoRoot $relative) | Out-Null
    }
    Get-ChildItem -LiteralPath $repoRoot -Filter '*.dll' -File | Copy-Item -Destination $runDirectory
    New-Item -ItemType Directory -Force -Path (Join-Path $runDirectory 'data\spritesheets'), (Join-Path $runDirectory 'config') | Out-Null
    Copy-Item -LiteralPath $mapConfig -Destination (Join-Path $runDirectory 'data\next_map.json')
    [IO.File]::WriteAllLines((Join-Path $runDirectory 'config\maps.txt'), [string[]]@('map sanfrancisco', 'default', 'endmap'), $utf8NoBom)
    $manifest.status = 'running'
    [IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 6), $utf8NoBom)
    $server = Start-Process -FilePath $daemon -WorkingDirectory $runDirectory -WindowStyle Hidden -PassThru `
        -ArgumentList 'city.test.dmb -trusted -invisible -log console.log -params log-directory=san-francisco' `
        -RedirectStandardOutput (Join-Path $runDirectory 'daemon.stdout.log') `
        -RedirectStandardError (Join-Path $runDirectory 'daemon.stderr.log')
    $manifest.daemon_pid = $server.Id
    try {
        Wait-CityProcess -Process $server -LimitSeconds $TimeoutSeconds -Phase 'City integration tests'
        $manifest.daemon_exit_code = $server.ExitCode
    } finally {
        if (-not $server.HasExited) { $server.Kill(); $server.WaitForExit() }
        $server.Dispose()
    }
    $resultsPath = Join-Path $runDirectory 'data\unit_tests.json'
    if (-not (Test-Path -LiteralPath $resultsPath)) { throw "No unit test results were produced: $runDirectory\console.log" }
    $results = Get-Content -LiteralPath $resultsPath -Raw | ConvertFrom-Json
    $missing = @($requiredTests | Where-Object { $_ -notin $results.PSObject.Properties.Name })
    $failed = @($results.PSObject.Properties.Value | Where-Object { $_.status -ne 0 })
    $logs = Join-Path $runDirectory 'data\logs\san-francisco'
    $runtimePaths = @((Join-Path $logs 'dd.log'), (Join-Path $logs 'runtime.log.json'), (Join-Path $runDirectory 'console.log'))
    $missingLogs = @($runtimePaths | Where-Object { -not (Test-Path -LiteralPath $_) })
    $runtimeErrors = @(Select-String -LiteralPath @($runtimePaths | Where-Object { Test-Path -LiteralPath $_ }) `
        -Pattern 'Runtime in\b|runtime error\b|uncaught exception\b|Total runtimes:\s*[1-9]|Maximum recursion level reached|Infinite loop suspected|BYOND out of memory')
    $cleanMarker = Join-Path $logs 'clean_run.lk'
    $clean = (Test-Path -LiteralPath $cleanMarker) -and ((Get-Content -LiteralPath $cleanMarker -Raw).Trim() -eq 'Success!')
    $mapUnchanged = (Get-FileHash -LiteralPath $mapFile -Algorithm SHA256).Hash.ToLowerInvariant() -eq $manifest.map_sha256
    foreach ($failure in $failed) { Write-Output ($failure.name + ': ' + $failure.message) }
    foreach ($runtimeError in $runtimeErrors) { Write-Output $runtimeError.ToString() }
    $manifest.results = [ordered]@{ missing = $missing; failed = $failed.Count; runtimes = $runtimeErrors.Count; missing_logs = $missingLogs; clean_shutdown = $clean; map_unchanged = $mapUnchanged }
    if ($manifest.daemon_exit_code -ne 0 -or $missing.Count -or $failed.Count -or $missingLogs.Count -or $runtimeErrors.Count -or -not $clean -or -not $mapUnchanged) {
        throw "City validation failed: exit=$($manifest.daemon_exit_code), missing=$($missing.Count), failed=$($failed.Count), runtimes=$($runtimeErrors.Count), missing logs=$($missingLogs.Count), clean=$clean, map unchanged=$mapUnchanged. Full logs: $runDirectory"
    }
    $manifest.status = 'passed'
    Write-Output "$(@($results.PSObject.Properties).Count) city integration test groups passed. Results: $resultsPath"
} catch {
    $manifest.status = 'failed'
    $manifest.failure = $_.Exception.Message
    Write-Output "City validation artifacts retained: $runDirectory"
    throw
} finally {
    $manifest.finished = (Get-Date).ToString('o')
    [IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 8), $utf8NoBom)
    if (Test-Path -LiteralPath $wrapper) { Move-Item -LiteralPath $wrapper -Destination $runDirectory }
    foreach ($extension in @('.dmb', '.rsc')) {
        $compiledFile = [IO.Path]::ChangeExtension($wrapper, $extension)
        if (Test-Path -LiteralPath $compiledFile) { Move-Item -LiteralPath $compiledFile -Destination $runDirectory }
    }
    Pop-Location
}
