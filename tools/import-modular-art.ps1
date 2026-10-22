param([Parameter(Mandatory=$true)][string]$Atlas)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition ([System.IO.File]::ReadAllText((Join-Path $PWD 'tools/modular-atlas.cs')))
$sourceDirectory=Join-Path $PWD 'assets/source'
$atlasPath=Join-Path $sourceDirectory 'modular-workstations-atlas.png'
if([System.IO.Path]::GetFullPath($Atlas) -ne $atlasPath){Copy-Item -LiteralPath $Atlas -Destination $atlasPath}
$cells=Join-Path $sourceDirectory 'modular-cells'
New-Item -ItemType Directory -Force -Path $cells | Out-Null
[ModularAtlas]::Split($atlasPath,$cells)
$mapping=@{spr_bin_paper=0;spr_bin_plastic=1;spr_bin_glass=2;spr_bin_metal=3;spr_counter=4;spr_dispenser=5;spr_machine_intake=5;spr_machine_sorting=6;spr_machine_washer=7;spr_machine_biodigester=8;spr_machine_dismantler=9;spr_machine_trash=10;spr_machine_extinguisher_rack=11}
$mapping['spr_machine_dispatch']=-1
$mapping['spr_truck']=-1
foreach($name in $mapping.Keys){
 $folder=Join-Path $PWD ('sprites/'+$name)
 $sprite=([System.IO.File]::ReadAllText((Join-Path $folder ($name+'.yy'))) -replace ',\s*([}\]])','$1') | ConvertFrom-Json
 $frame=$sprite.frames[0].name
 $target=Join-Path $folder ($frame+'.png')
 $inputImage=if($mapping[$name] -eq -1){Join-Path $sourceDirectory 'equipment-cells/10.png'}else{Join-Path $cells ($mapping[$name].ToString()+'.png')}
 [ModularAtlas]::Fit($inputImage,$target,$sprite.width,$sprite.height)
 foreach($layer in $sprite.layers){Copy-Item -LiteralPath $target -Destination (Join-Path $folder ('layers/'+$frame+'/'+$layer.name+'.png'))}
}
Write-Output 'Imported 13 square station sprites and two matching truck sprites.'
