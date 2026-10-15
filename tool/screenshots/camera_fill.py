# Paints a fake camera picture behind the barcode scanner screenshots: the
# test has no camera, so the preview is black. Pixels that are pure black
# (scan window) get the picture; pixels with the scanner's dim overlay get
# the picture under that overlay.
#   python3 tool/screenshots/camera_fill.py tool/screenshots/raw/24_barcode_scan.png ...
import sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

L = ['0001101', '0011001', '0010011', '0111101', '0100011',
     '0110001', '0101111', '0111011', '0110111', '0001011']
G = [''.join('1' if c == '0' else '0' for c in code[::-1]) for code in L]
R = [''.join('1' if c == '0' else '0' for c in code) for code in L]
PARITY = ['LLLLLL', 'LLGLGG', 'LLGGLG', 'LLGGGL', 'LGLLGG',
          'LGGLLG', 'LGGGLL', 'LGLGLG', 'LGLGGL', 'LGGLGL']


def ean13_bits(code):
    d = [int(c) for c in code]
    bits = '101'
    for i, p in enumerate(PARITY[d[0]]):
        bits += (L if p == 'L' else G)[d[i + 1]]
    bits += '01010'
    for i in range(6):
        bits += R[d[i + 7]]
    return bits + '101'


def camera(size, code):
    w, h = size
    bg = Image.open('assets/foods/ayran.jpg').convert('RGB')
    side = max(w, h)
    bg = bg.resize((side, side), Image.LANCZOS).crop(((side - w) // 2, 0, (side - w) // 2 + w, h))
    bg = bg.filter(ImageFilter.GaussianBlur(40))
    d = ImageDraw.Draw(bg)
    # A product label holding the barcode, centred in the scan window.
    cx, cy = w // 2, 1373
    d.rounded_rectangle((cx - 400, cy - 260, cx + 400, cy + 260), 36, fill=(246, 246, 242))
    bits = ean13_bits(code)
    module = 6
    x0 = cx - len(bits) * module // 2
    for i, b in enumerate(bits):
        if b == '1':
            guard = i < 3 or 45 <= i < 50 or i >= 92
            d.rectangle((x0 + i * module, cy - 170, x0 + (i + 1) * module - 1,
                         cy + (120 if guard else 95)), fill=(18, 18, 18))
    font = ImageFont.truetype('assets/fonts/Nunito-SemiBold.ttf', 46)
    d.text((cx, cy + 150), f'{code[0]}  {code[1:7]}  {code[7:]}', font=font,
           fill=(18, 18, 18), anchor='mm')
    return bg.filter(ImageFilter.GaussianBlur(1.2))


for path in sys.argv[1:]:
    shot = Image.open(path).convert('RGB')
    a = np.asarray(shot).astype(np.float32)
    cam = np.asarray(camera(shot.size, '8690504041218')).astype(np.float32)
    overlay = np.array([10, 16, 12], np.float32)
    dimmed = np.round(overlay * 0.7)
    black = np.all(a == 0, axis=-1)
    dim = np.all(np.abs(a - dimmed) <= 1, axis=-1)
    out = a.copy()
    out[black] = cam[black]
    out[dim] = cam[dim] * 0.3 + overlay * 0.7
    Image.fromarray(out.clip(0, 255).astype(np.uint8)).save(path)
    print('filled', path)
