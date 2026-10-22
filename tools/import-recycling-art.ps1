param(
    [Parameter(Mandatory=$true)][string]$EquipmentAtlas,
    [Parameter(Mandatory=$true)][string]$MaterialAtlas
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
using System.Runtime.InteropServices;
using System.Collections.Generic;
public static class RecyclingAtlas {
    public static void Split(string file, string destination) {
        using(var bitmap = new Bitmap(file)) {
            int w=bitmap.Width,h=bitmap.Height;
            var data=bitmap.LockBits(new Rectangle(0,0,w,h),ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb);
            var pixels=new byte[data.Stride*h]; Marshal.Copy(data.Scan0,pixels,0,pixels.Length); int stride=data.Stride; bitmap.UnlockBits(data);
            var seen=new bool[w*h]; var queue=new int[w*h];
            var bounds=new Rectangle[16]; var areas=new int[16];
            // Connected alpha regions keep complete silhouettes even when generated art
            // extends slightly across its nominal grid cell. No artwork is drawn here.
            for(int y=0;y<h;y++) for(int x=0;x<w;x++) {
                int start=y*w+x; if(seen[start]||pixels[y*stride+x*4+3]<64)continue;
                int head=0,tail=1,minx=x,maxx=x,miny=y,maxy=y; long sumx=0,sumy=0;
                queue[0]=start; seen[start]=true;
                while(head<tail) {
                    int p=queue[head++],px=p%w,py=p/w;
                    sumx+=px;sumy+=py;minx=Math.Min(minx,px);maxx=Math.Max(maxx,px);miny=Math.Min(miny,py);maxy=Math.Max(maxy,py);
                    for(int direction=0;direction<4;direction++) {
                        int nx=px+(direction==0?-1:direction==1?1:0),ny=py+(direction==2?-1:direction==3?1:0);
                        if(nx<0||ny<0||nx>=w||ny>=h)continue;
                        int n=ny*w+nx; if(seen[n]||pixels[ny*stride+nx*4+3]<64)continue;
                        seen[n]=true;queue[tail++]=n;
                    }
                }
                if(tail<64)continue;
                int column=Math.Min(3,(int)(sumx*4/tail/w)),row=Math.Min(3,(int)(sumy*4/tail/h)),cell=row*4+column;
                var rect=Rectangle.FromLTRB(minx,miny,maxx+1,maxy+1);
                if(tail>areas[cell]){bounds[cell]=rect;areas[cell]=tail;}
            }
            for(int cell=0;cell<16;cell++) {
                if(areas[cell]==0)throw new Exception("Missing atlas cell "+cell);
                using(var crop=bitmap.Clone(bounds[cell],PixelFormat.Format32bppArgb))crop.Save(System.IO.Path.Combine(destination,cell+".png"),ImageFormat.Png);
            }
        }
    }
    public static void Fit(string source,string destination,int width,int height) {
        using(var input=new Bitmap(source))using(var output=new Bitmap(width,height))using(var g=Graphics.FromImage(output)) {
            g.Clear(Color.Transparent); g.CompositingMode=CompositingMode.SourceCopy;
            g.InterpolationMode=InterpolationMode.NearestNeighbor; g.PixelOffsetMode=PixelOffsetMode.Half;
            float scale=Math.Min((width-4f)/input.Width,(height-4f)/input.Height);
            int dw=(int)(input.Width*scale),dh=(int)(input.Height*scale);
            g.DrawImage(input,new Rectangle((width-dw)/2,(height-dh)/2,dw,dh),0,0,input.Width,input.Height,GraphicsUnit.Pixel);
            output.Save(destination,ImageFormat.Png);
        }
    }
}
'@
$sourceDirectory = Join-Path $PWD 'assets/source'
New-Item -ItemType Directory -Force -Path $sourceDirectory | Out-Null
Copy-Item -LiteralPath $EquipmentAtlas -Destination (Join-Path $sourceDirectory 'recycling-equipment-atlas.png')
Copy-Item -LiteralPath $MaterialAtlas -Destination (Join-Path $sourceDirectory 'recycling-material-atlas.png')
$equipmentCells = Join-Path $sourceDirectory 'equipment-cells'
$materialCells = Join-Path $sourceDirectory 'material-cells'
New-Item -ItemType Directory -Force -Path $equipmentCells,$materialCells | Out-Null
[RecyclingAtlas]::Split((Join-Path $sourceDirectory 'recycling-equipment-atlas.png'),$equipmentCells)
[RecyclingAtlas]::Split((Join-Path $sourceDirectory 'recycling-material-atlas.png'),$materialCells)
$equipment = @{
    spr_bin_paper=0; spr_bin_plastic=1; spr_bin_glass=2; spr_bin_metal=3;
    spr_machine_intake=4; spr_dispenser=4; spr_machine_sorting=5; spr_machine_washer=6;
    spr_machine_biodigester=7; spr_machine_dismantler=8; spr_machine_press=9;
    spr_machine_dispatch=10; spr_truck=10; spr_machine_trash=11;
    spr_machine_extinguisher_rack=12; spr_material_extinguisher=12; spr_robot=14; spr_material_metal_bale=15
}
$materials = @{
    spr_waste_paper=0; spr_waste_plastic=1; spr_waste_glass=2; spr_waste_metal=3;
    spr_bag_paper=4; spr_bag_plastic=5; spr_bag_glass=6; spr_bag_metal=7;
    spr_material_raw_waste=8; spr_material_dirty_plastic=9; spr_material_organic=10;
    spr_material_electronic=11; spr_material_clean_plastic=12; spr_material_fertilizer=13;
    spr_material_metal_plate=14; spr_material_plastic_bale=15
}
foreach ($entry in @(@{Map=$equipment;Cells=$equipmentCells},@{Map=$materials;Cells=$materialCells})) {
    foreach ($name in $entry.Map.Keys) {
        $folder=Join-Path $PWD ('sprites/'+$name)
        $json=[System.IO.File]::ReadAllText((Join-Path $folder ($name+'.yy'))) -replace ',\s*([}\]])','$1'
        $sprite=$json | ConvertFrom-Json
        $frame=$sprite.frames[0].name
        $target=Join-Path $folder ($frame+'.png')
        [RecyclingAtlas]::Fit((Join-Path $entry.Cells ($entry.Map[$name].ToString()+'.png')),$target,$sprite.width,$sprite.height)
        foreach ($layer in $sprite.layers) {
            Copy-Item -LiteralPath $target -Destination (Join-Path $folder ('layers/'+$frame+'/'+$layer.name+'.png'))
        }
    }
}
Write-Output ('Imported '+($equipment.Count+$materials.Count)+' sprite images, preserving resource names, dimensions, origins and layers.')
