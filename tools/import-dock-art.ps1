param([Parameter(Mandatory=$true)][string]$Source)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition ([System.IO.File]::ReadAllText((Join-Path $PWD 'tools/modular-atlas.cs')))
$saved=Join-Path $PWD 'assets/source/truck-dock.png'
if([System.IO.Path]::GetFullPath($Source) -ne $saved){Copy-Item -LiteralPath $Source -Destination $saved}
$folder=Join-Path $PWD 'sprites/spr_truck_dock'
$sprite=([System.IO.File]::ReadAllText((Join-Path $folder 'spr_truck_dock.yy')) -replace ',\s*([}\]])','$1') | ConvertFrom-Json
foreach($frame in $sprite.frames){
 $target=Join-Path $folder ($frame.name+'.png')
 [ModularAtlas]::FitTrimmed($saved,$target,128,64)
 foreach($layer in $sprite.layers){
  $layerFolder=Join-Path $folder ('layers/'+$frame.name)
  New-Item -ItemType Directory -Force -Path $layerFolder | Out-Null
  Copy-Item -LiteralPath $target -Destination (Join-Path $layerFolder ($layer.name+'.png'))
 }
}
