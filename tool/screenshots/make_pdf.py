# Collects docs/mockups/*.png into one A4 landscape PDF: docs/Denge_Mockuplar.pdf
#   python3 tool/screenshots/make_pdf.py
from PIL import Image, ImageDraw, ImageFont
M='docs/mockups/'
F='assets/fonts/Nunito-'
def font(w,s): return ImageFont.truetype(F+w+'.ttf',s)
groups=[
("Başlangıç ve kurulum",[("01_onboarding","Karşılama"),("02_sign_up","Hesap oluştur"),("03_health_consent","Alerjiler ve KVKK onayı"),("04_setup_activity","Aktivite düzeyi"),("05_setup_goal","Hedef seçimi"),("06_setup_result","Kişisel plan")]),
("Ana sayfa ve günlük",[("07_home","Ana sayfa"),("22_home_water","Ana sayfa · su takibi"),("08_diary","Günlük")]),
("Öğüne yemek ekleme",[("09_search","Yiyecek ara (Kahvaltıya ekle)"),("10_food_detail","Yiyecek detayı ve öğün seçimi"),("11_custom_food","Yiyeceği kendin ekle")]),
("Barkod tarama",[("24_barcode_scan","Barkod tara"),("25_barcode_found","Ürün bulundu")]),
("İlerleme ve tarifler",[("12_progress","İlerleme"),("13_recipes","Tarifler"),("14_recipe_detail","Tarif detayı")]),
("Profil ve ayarlar",[("15_profile","Profil"),("16_goals","Hedefler ve makrolar"),("17_notifications","Bildirimler"),("18_settings","Ayarlar"),("19_cloud_consent","Bulut yedekleme rızası")]),
("Koyu tema",[("20_home_dark","Ana sayfa · koyu"),("23_home_water_dark","Su takibi · koyu"),("21_diary_dark","Günlük · koyu")]),
]
W,H=2339,1654; BG=(245,248,244); INK=(20,32,26); MUTED=(91,107,97); GREEN=(31,122,74)
PH=1300; GAP=40; TOP=210
pages=[]
cover=Image.new('RGB',(W,H),BG); d=ImageDraw.Draw(cover)
d.text((160,420),"DENGE",font=font('Black',60),fill=GREEN)
d.text((160,500),"Uygulama ekranları",font=font('Black',130),fill=INK)
d.text((160,680),"Son sürümden mockup'lar · Flutter · Android ve iOS",font=font('SemiBold',48),fill=MUTED)
y=820
for i,(g,items) in enumerate(groups):
    d.text((160,y),f"{g}",font=font('Bold',40),fill=INK); d.text((900,y),f"{len(items)} ekran",font=font('SemiBold',40),fill=MUTED); y+=62
pages.append(cover)
def newpage(title,cont=False):
    p=Image.new('RGB',(W,H),BG); dd=ImageDraw.Draw(p)
    dd.text((110,90),title+(" (devam)" if cont else ""),font=font('Black',70),fill=INK)
    return p,dd
for g,items in groups:
    imgs=[]
    for f,c in items:
        im=Image.open(M+f+'.png').convert('RGBA'); s=PH/im.height
        imgs.append((im.resize((int(im.width*s),PH),Image.LANCZOS),c))
    rows=[];row=[];wsum=0
    for im,c in imgs:
        if row and wsum+im.width+GAP>W-220: rows.append(row);row=[];wsum=0
        row.append((im,c)); wsum+=im.width+GAP
    rows.append(row)
    for k,row in enumerate(rows):
        p,dd=newpage(g,k>0)
        total=sum(im.width for im,_ in row)+GAP*(len(row)-1)
        x=(W-total)//2
        for im,c in row:
            p.paste(im,(x,TOP),im)
            f=font('Bold',30)
            tw=dd.textlength(c,font=f)
            if tw>im.width+GAP-10:
                f=font('Bold',24); tw=dd.textlength(c,font=f)
            dd.text((x+im.width/2-tw/2,TOP+PH+30),c,font=f,fill=INK)
            x+=im.width+GAP
        pages.append(p)
for i,p in enumerate(pages[1:],2):
    ImageDraw.Draw(p).text((W-110,H-70),str(i),font=font('SemiBold',30),fill=MUTED,anchor='rs')
pages[0].save('docs/Denge_Mockuplar.pdf',save_all=True,append_images=pages[1:],resolution=200)
print(len(pages))
