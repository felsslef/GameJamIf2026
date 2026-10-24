param([ValidateSet('processing','tutorial','ui','incidents','progression','production')][string]$Suite = 'processing')
$ErrorActionPreference = 'Stop'
$runtimePath = Get-ChildItem -LiteralPath $env:ProgramData -Directory -Filter 'GameMakerStudio2*' |
    ForEach-Object {
        $runtimesFolder = Join-Path $_.FullName 'Cache\runtimes'
        if (Test-Path -LiteralPath $runtimesFolder) { Get-ChildItem -LiteralPath $runtimesFolder -Directory -Filter 'runtime-*' }
    } | Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'bin\igor\windows\x64\Igor.exe') } |
    Sort-Object { [version]($_.Name -replace '^runtime-', '') } -Descending | Select-Object -First 1 -ExpandProperty FullName
if (!$runtimePath) { throw 'GameMaker runtime not found.' }
$userFolder = Get-ChildItem -LiteralPath $env:APPDATA -Directory -Filter 'GameMakerStudio2*' |
    ForEach-Object { Get-ChildItem -LiteralPath $_.FullName -Directory } |
    Where-Object { (Test-Path -LiteralPath (Join-Path $_.FullName 'licence.plist')) -or (Test-Path -LiteralPath (Join-Path $_.FullName 'local_settings.json')) } | Select-Object -First 1
if (!$userFolder) { throw 'GameMaker user profile not found.' }
if ($Suite -eq 'production') { $projectPath = Join-Path $PWD 'GameJamIf2026.yyp' }
else {
    node tools/prepare-processing-tests.mjs $Suite
    if ($LASTEXITCODE -ne 0) { throw 'Test preparation failed.' }
    $projectPath = Join-Path $env:TEMP "GameJamIf2026-$Suite-tests\GameJamIf2026.yyp"
}
$buildPath = Join-Path $env:TEMP "GameJamIf2026-round-flow-$Suite-build"
New-Item -ItemType Directory -Force -Path $buildPath | Out-Null
& "$runtimePath\bin\igor\windows\x64\Igor.exe" "--project=$projectPath" "--rp=$runtimePath" "--uf=$($userFolder.FullName)" "--cache=$buildPath\cache" "--temp=$buildPath\temp" "--of=$buildPath\package\frontend.zip" "--tf=$buildPath\frontend.zip" --runtime=VM -- Windows Compile *> "$buildPath\build.log"
if ($LASTEXITCODE -ne 0) { Get-Content "$buildPath\build.log" -Tail 60; throw 'GameMaker compilation failed.' }
# Use the installed runner to test VM builds; creating a distributable is a separate IDE action.
$packagePath = Join-Path $buildPath 'package'
$gameData = Get-ChildItem -LiteralPath $packagePath -Filter '*.win' | Where-Object { $_.Name -ne 'data.win' } | Select-Object -First 1
if (!$gameData) { throw 'Compiled game data not found.' }
Copy-Item -LiteralPath $gameData.FullName -Destination (Join-Path $packagePath 'data.win') -Force
Copy-Item -LiteralPath (Join-Path $runtimePath 'windows\x64\Runner.exe') -Destination (Join-Path $packagePath 'ColetaMaluca.exe') -Force
if ($Suite -eq 'production') { Write-Output "PRODUCTION_BUILD_PASSED: $buildPath"; return }
$runner = Get-ChildItem -LiteralPath (Join-Path $buildPath 'package') -Filter ColetaMaluca.exe | Select-Object -First 1
if (!$runner) { throw 'Compiled runner not found.' }
$probe = Start-Process -FilePath $runner.FullName -WorkingDirectory $runner.DirectoryName -WindowStyle Hidden -PassThru -RedirectStandardOutput "$buildPath\probe.log" -RedirectStandardError "$buildPath\probe-errors.log"
if (!$probe.WaitForExit(45000)) { Stop-Process -Id $probe.Id; throw 'Test timed out. See probe.log.' }
$log = [System.IO.File]::ReadAllText("$buildPath\probe.log")
$marker = $Suite.ToUpper() + '_PROBE_PASSED'
if (!$log.Contains($marker) -or $log.Contains('FAIL:')) { Get-Content "$buildPath\probe.log" -Tail 60; throw 'Runtime regression failed.' }
if ($Suite -eq 'processing') {
    node tools/check-processing-layouts.mjs "$buildPath\probe.log"
    if ($LASTEXITCODE -ne 0) { throw 'Layout checks failed.' }
}
Write-Output "$marker`: $buildPath"
