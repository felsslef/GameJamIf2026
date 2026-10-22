param([Parameter(Mandatory=$true)][string]$Source,[string]$BenchSource='')
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition ([System.IO.File]::ReadAllText((Join-Path $PWD 'tools/modular-atlas.cs')))
$saved = Join-Path $PWD 'assets/source/recyclable-water-bottle.png'
if([System.IO.Path]::GetFullPath($Source) -ne $saved){Copy-Item -LiteralPath $Source -Destination $saved}
$benchArt=Join-Path $PWD 'assets/source/scientific-robot-workbench.png'
if($BenchSource -ne ''){Copy-Item -LiteralPath $BenchSource -Destination $benchArt}
if(!(Test-Path -LiteralPath $benchArt)){$benchArt=Join-Path $PWD 'assets/source/science-bench-original.png'}
foreach($entry in @(@{name='spr_waste_plastic';source=$saved},@{name='spr_science_bench';source=$benchArt})){
 $folder=Join-Path $PWD ('sprites/'+$entry.name)
 $sprite=([System.IO.File]::ReadAllText((Join-Path $folder ($entry.name+'.yy'))) -replace ',\s*([}\]])','$1') | ConvertFrom-Json
 $frame=$sprite.frames[0].name
 $outputPath=Join-Path $folder ($frame+'.png')
 [ModularAtlas]::FitTrimmed($entry.source,$outputPath,$sprite.width,$sprite.height)
 foreach($layer in $sprite.layers){Copy-Item -LiteralPath $outputPath -Destination (Join-Path $folder ('layers/'+$frame+'/'+$layer.name+'.png'))}
}
