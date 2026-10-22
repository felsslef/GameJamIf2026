using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
using System.Runtime.InteropServices;
using System.Collections.Generic;
public static class ModularAtlas {
    public static void Split(string file, string destination) {
        using(var bitmap = new Bitmap(file)) {
            int w=bitmap.Width,h=bitmap.Height;
            var data=bitmap.LockBits(new Rectangle(0,0,w,h),ImageLockMode.ReadOnly,PixelFormat.Format32bppArgb);
            var pixels=new byte[data.Stride*h]; Marshal.Copy(data.Scan0,pixels,0,pixels.Length); int stride=data.Stride; bitmap.UnlockBits(data);
            var seen=new bool[w*h]; var queue=new int[w*h];
            var bounds=new Rectangle[12]; var areas=new int[12];
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
                int column=Math.Min(3,(int)(sumx*4/tail/w)),row=Math.Min(2,(int)(sumy*3/tail/h)),cell=row*4+column;
                var rect=Rectangle.FromLTRB(minx,miny,maxx+1,maxy+1);
                if(tail>areas[cell]){bounds[cell]=rect;areas[cell]=tail;}
            }
            for(int cell=0;cell<12;cell++) {
                if(areas[cell]==0)throw new Exception("Missing atlas cell "+cell);
                using(var crop=bitmap.Clone(bounds[cell],PixelFormat.Format32bppArgb))crop.Save(System.IO.Path.Combine(destination,cell+".png"),ImageFormat.Png);
            }
        }
    }
    public static void FitTrimmed(string source,string destination,int width,int height) {
        using(var input=new Bitmap(source)) {
            int left=input.Width,top=input.Height,right=-1,bottom=-1;
            for(int y=0;y<input.Height;y++)for(int x=0;x<input.Width;x++)if(input.GetPixel(x,y).A>32){
                left=Math.Min(left,x);top=Math.Min(top,y);right=Math.Max(right,x);bottom=Math.Max(bottom,y);
            }
            if(right<left)throw new Exception("Sprite has no visible pixels: "+source);
            using(var crop=input.Clone(Rectangle.FromLTRB(left,top,right+1,bottom+1),PixelFormat.Format32bppArgb))
            using(var output=new Bitmap(width,height))using(var g=Graphics.FromImage(output)) {
                g.Clear(Color.Transparent);g.CompositingMode=CompositingMode.SourceCopy;
                g.InterpolationMode=InterpolationMode.NearestNeighbor;g.PixelOffsetMode=PixelOffsetMode.Half;
                float scale=Math.Min((width-4f)/crop.Width,(height-4f)/crop.Height);
                int dw=Math.Max(1,(int)(crop.Width*scale)),dh=Math.Max(1,(int)(crop.Height*scale));
                g.DrawImage(crop,new Rectangle((width-dw)/2,(height-dh)/2,dw,dh),0,0,crop.Width,crop.Height,GraphicsUnit.Pixel);
                output.Save(destination,ImageFormat.Png);
            }
        }
    }
    public static void Fit(string source,string destination,int width,int height) {
        using(var input=new Bitmap(source))using(var output=new Bitmap(width,height))using(var g=Graphics.FromImage(output)) {
            g.Clear(Color.Transparent); g.CompositingMode=CompositingMode.SourceCopy;
            g.InterpolationMode=InterpolationMode.NearestNeighbor; g.PixelOffsetMode=PixelOffsetMode.Half;
            float scale=Math.Min((width-0f)/input.Width,(height-0f)/input.Height);
            int dw=(int)(input.Width*scale),dh=(int)(input.Height*scale);
            g.DrawImage(input,new Rectangle((width-dw)/2,(height-dh)/2,dw,dh),0,0,input.Width,input.Height,GraphicsUnit.Pixel);
            output.Save(destination,ImageFormat.Png);
        }
    }
}
