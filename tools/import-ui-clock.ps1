Add-Type -AssemblyName System.Drawing
$ids = Get-Content -LiteralPath 'tools/ui-sprite-paths.json' -Raw | ConvertFrom-Json
$bitmap = New-Object System.Drawing.Bitmap 96,96
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$dark = [System.Drawing.Color]::FromArgb(35,57,64)
$cream = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255,252,235))
$coral = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(218,80,67),7)
$hand = [System.Drawing.Pen]::new($dark,6)
$hand.StartCap=$hand.EndCap=[System.Drawing.Drawing2D.LineCap]::Round
$graphics.FillEllipse($cream,10,10,76,76)
$graphics.DrawEllipse($coral,10,10,76,76)
$graphics.DrawLine($hand,48,48,48,27)
$graphics.DrawLine($hand,48,48,65,53)
foreach($angle in @(0,90,180,270)){
 $radians=$angle*[Math]::PI/180
 $graphics.DrawLine($hand,[single](48+29*[Math]::Cos($radians)),[single](48+29*[Math]::Sin($radians)),[single](48+31*[Math]::Cos($radians)),[single](48+31*[Math]::Sin($radians)))
}
$root = Join-Path $PWD 'sprites/spr_ui_timeout'
$layerDir=Join-Path $root "layers/$($ids.frame)"
New-Item -ItemType Directory -Force -Path $layerDir | Out-Null
$bitmap.Save((Join-Path $root "$($ids.frame).png"),[System.Drawing.Imaging.ImageFormat]::Png)
$bitmap.Save((Join-Path $layerDir "$($ids.layer).png"),[System.Drawing.Imaging.ImageFormat]::Png)
$graphics.Dispose();$bitmap.Dispose();$cream.Dispose();$coral.Dispose();$hand.Dispose()
