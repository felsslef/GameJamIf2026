param([ValidateSet('processing','tutorial','production')][string]$Suite = 'processing')
$ErrorActionPreference = 'Stop'
$runtimePath = 'C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2024.14.4.268'
$licenseFolder = Get-ChildItem -LiteralPath (Join-Path $env:APPDATA 'GameMakerStudio2') -Directory | Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'licence.plist') } | Select-Object -First 1
if (!$licenseFolder) { throw 'GameMaker licence not found.' }
if ($Suite -eq 'production') { $projectPath = Join-Path $PWD 'GameJamIf2026.yyp' }
else {
    node tools/prepare-processing-tests.mjs $Suite
    if ($LASTEXITCODE -ne 0) { throw 'Test preparation failed.' }
    $projectPath = Join-Path $env:TEMP "GameJamIf2026-$Suite-tests\GameJamIf2026.yyp"
}
$buildPath = Join-Path $env:TEMP "GameJamIf2026-round-flow-$Suite-build"
New-Item -ItemType Directory -Force -Path $buildPath | Out-Null
& "$runtimePath\bin\igor\windows\x64\Igor.exe" "--project=$projectPath" "--rp=$runtimePath" "--uf=$($licenseFolder.FullName)" "--cache=$buildPath\cache" "--temp=$buildPath\temp" "--of=$buildPath\package\frontend.zip" "--tf=$buildPath\frontend.zip" --runtime=VM -- Windows PackageZip *> "$buildPath\build.log"
if ($LASTEXITCODE -ne 0) { Get-Content "$buildPath\build.log" -Tail 60; throw 'GameMaker compilation failed.' }
if ($Suite -eq 'production') { Write-Output "PRODUCTION_BUILD_PASSED: $buildPath"; return }
$runner = Get-ChildItem -LiteralPath $buildPath -Filter new_blank.exe -Recurse | Select-Object -First 1
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
