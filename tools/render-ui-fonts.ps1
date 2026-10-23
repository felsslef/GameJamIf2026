param([string[]]$Fonts = @('fnt_ui_small','fnt_ui_body','fnt_ui_title','fnt_dialogue_name'))
Add-Type -AssemblyName System.Drawing
foreach ($fontName in $Fonts) {
    $metadataPath = Join-Path $PWD "fonts/$fontName/$fontName.yy"
    $data = [System.IO.File]::ReadAllText($metadataPath) | ConvertFrom-Json
    $style = if ($data.bold) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }
    $font = [System.Drawing.Font]::new($data.fontName,[single]$data.size,$style,[System.Drawing.GraphicsUnit]::Point)
    $canvas = [System.Drawing.Bitmap]::new(1024,1024)
    $graphics = [System.Drawing.Graphics]::FromImage($canvas)
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $format = [System.Drawing.StringFormat]::GenericTypographic.Clone()
    $format.FormatFlags = $format.FormatFlags -bor [System.Drawing.StringFormatFlags]::MeasureTrailingSpaces
    $lineHeight = [int][Math]::Ceiling($font.GetHeight($graphics))+4
    $glyphX=2; $glyphY=2
    foreach ($property in $data.glyphs.PSObject.Properties) {
        $glyph=$property.Value
        $letter=[string][char]$glyph.character
        $advance=[int][Math]::Ceiling($graphics.MeasureString($letter,$font,1000,$format).Width)
        $width=[Math]::Max(2,$advance+4)
        if ($glyphX+$width+2 -gt 1024) { $glyphX=2; $glyphY+=$lineHeight+2 }
        if ($glyphY+$lineHeight -gt 1024) { throw 'Font atlas overflow' }
        $graphics.DrawString($letter,$font,[System.Drawing.Brushes]::White,[single]($glyphX+2),[single]$glyphY,$format)
        $glyph.x=$glyphX; $glyph.y=$glyphY; $glyph.w=$width; $glyph.h=$lineHeight; $glyph.shift=$advance; $glyph.offset=-2
        $glyphX+=$width+2
    }
    $data.ascender=[int][Math]::Ceiling($font.GetHeight($graphics)*0.8)
    $canvas.Save((Join-Path $PWD "fonts/$fontName/$fontName.png"),[System.Drawing.Imaging.ImageFormat]::Png)
    [System.IO.File]::WriteAllText($metadataPath,($data | ConvertTo-Json -Depth 100))
    $format.Dispose();$graphics.Dispose();$canvas.Dispose();$font.Dispose()
}
