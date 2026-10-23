using System;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
public static class AppIconExport {
    public static void Write(string source,string destination) {
        int[] sizes={16,24,32,48,64,128,256};
        byte[][] images=new byte[sizes.Length][];
        using(var original=new Bitmap(source))for(int i=0;i<sizes.Length;i++) {
            int size=sizes[i];
            using(var bitmap=new Bitmap(size,size))using(var graphics=Graphics.FromImage(bitmap))using(var stream=new MemoryStream()) {
                graphics.InterpolationMode=InterpolationMode.NearestNeighbor;
                graphics.PixelOffsetMode=PixelOffsetMode.Half;
                graphics.DrawImage(original,new Rectangle(0,0,size,size));
                bitmap.Save(stream,ImageFormat.Png);images[i]=stream.ToArray();
            }
        }
        using(var output=new BinaryWriter(File.Create(destination))) {
            output.Write((ushort)0);output.Write((ushort)1);output.Write((ushort)sizes.Length);
            int offset=6+16*sizes.Length;
            for(int i=0;i<sizes.Length;i++) {
                output.Write((byte)(sizes[i]==256?0:sizes[i]));output.Write((byte)(sizes[i]==256?0:sizes[i]));
                output.Write((byte)0);output.Write((byte)0);output.Write((ushort)1);output.Write((ushort)32);
                output.Write(images[i].Length);output.Write(offset);offset+=images[i].Length;
            }
            foreach(var image in images)output.Write(image);
        }
    }
}
