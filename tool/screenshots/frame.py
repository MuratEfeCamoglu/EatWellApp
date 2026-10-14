# Puts the raw screenshots into a phone frame for docs/mockups/:
#   python3 tool/screenshots/frame.py tool/screenshots/raw docs/mockups
import glob, os, sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter
src, out = sys.argv[1], sys.argv[2]
ROB=os.environ.get('ROBOTO_DIR', '/usr/share/fonts/truetype/roboto/')
S=0.5  # output scale
def frame(path, dark):
    shot=Image.open(path).convert('RGB')
    W,H=shot.size
    d=ImageDraw.Draw(shot)
    fg=(240,240,240) if dark else (20,24,22)
    f=ImageFont.truetype(ROB+'Roboto-Bold.ttf',48)
    d.text((150,62),'09:41',font=f,fill=fg)
    # signal bars, wifi, battery
    x=W-300
    for i in range(4):
        h=14+i*9; d.rounded_rectangle((x+i*20,100-h,x+i*20+12,100),3,fill=fg)
    d.pieslice((W-215,58,W-155,118),225,315,fill=fg)
    d.rounded_rectangle((W-140,68,W-62,102),10,outline=fg,width=4)
    d.rounded_rectangle((W-133,75,W-80,95),5,fill=fg)
    d.rounded_rectangle((W-58,78,W-52,92),2,fill=fg)
    # home indicator
    d.rounded_rectangle((W/2-200,H-40,W/2+200,H-25),8,fill=fg)
    # screen mask with rounded corners
    R=150
    mask=Image.new('L',(W,H),0); ImageDraw.Draw(mask).rounded_rectangle((0,0,W-1,H-1),R,fill=255)
    B=40
    dev=Image.new('RGBA',(W+2*B,H+2*B),(0,0,0,0))
    dd=ImageDraw.Draw(dev)
    dd.rounded_rectangle((0,0,W+2*B-1,H+2*B-1),R+B,fill=(28,30,32,255))
    dd.rounded_rectangle((3,3,W+2*B-4,H+2*B-4),R+B-3,outline=(70,74,78,255),width=4)
    dev.paste(shot,(B,B),mask)
    # dynamic island
    dd.rounded_rectangle((B+W/2-190,B+35,B+W/2+190,B+140),55,fill=(0,0,0,255))
    pad=80
    canvas=Image.new('RGBA',(dev.width+2*pad,dev.height+2*pad),(0,0,0,0))
    sh=Image.new('RGBA',canvas.size,(0,0,0,0))
    ImageDraw.Draw(sh).rounded_rectangle((pad,pad+30,pad+dev.width,pad+dev.height+30),R+B,fill=(0,0,0,90))
    sh=sh.filter(ImageFilter.GaussianBlur(35))
    canvas=Image.alpha_composite(canvas,sh); canvas.alpha_composite(dev,(pad,pad))
    return canvas.resize((int(canvas.width*S),int(canvas.height*S)),Image.LANCZOS)
for p in sorted(glob.glob(src+'/*.png')):
    n=os.path.basename(p)
    frame(p,'dark' in n).save(os.path.join(out,n),optimize=True)
print('ok')
