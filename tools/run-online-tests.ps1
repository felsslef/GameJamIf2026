$ErrorActionPreference='Stop'
$buildScript=[IO.File]::ReadAllText((Join-Path $PWD 'tools/run-game-tests.ps1'))
$buildScript=$buildScript.Replace('node tools/prepare-processing-tests.mjs $Suite','node tools/prepare-online-tests.mjs')
$buildScript=$buildScript.Substring(0,$buildScript.IndexOf('$probe = Start-Process'))
. ([scriptblock]::Create($buildScript)) -Suite processing
$onlineExe=Join-Path $env:TEMP 'GameJamIf2026-round-flow-processing-build/package/ColetaMaluca.exe'
$onlineFolder=Split-Path $onlineExe
$hostProbe=Start-Process -FilePath $onlineExe -WorkingDirectory $onlineFolder -WindowStyle Hidden -PassThru -RedirectStandardOutput "$onlineFolder/host.log" -RedirectStandardError "$onlineFolder/host-error.log"
Start-Sleep -Milliseconds 800
$clientProbe=Start-Process -FilePath $onlineExe -ArgumentList '--online-client' -WorkingDirectory $onlineFolder -WindowStyle Hidden -PassThru -RedirectStandardOutput "$onlineFolder/client.log" -RedirectStandardError "$onlineFolder/client-error.log"
foreach($onlineProbe in @($hostProbe,$clientProbe)){if(!$onlineProbe.WaitForExit(15000)){Stop-Process -Id $onlineProbe.Id;throw 'Online test timed out'}}
$hostLog=[IO.File]::ReadAllText("$onlineFolder/host.log")
$clientLog=[IO.File]::ReadAllText("$onlineFolder/client.log")
if(!$hostLog.Contains('ONLINE_HOST_INPUT_PASSED') -or !$clientLog.Contains('ONLINE_CLIENT_STATE_PASSED')) {
 Get-Content "$onlineFolder/host.log" -Tail 16
 Get-Content "$onlineFolder/client.log" -Tail 16
 throw 'Online integration failed'
}
Write-Output 'ONLINE_LOOPBACK_PASSED: remote input and authoritative machine/score state'
