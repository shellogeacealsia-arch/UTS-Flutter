"""Generates local placeholder artwork (24 products + logo + banner) with Pillow.
Run:  python3 tool_generate_assets.py   (optional - the PNGs are already included)
"""
from PIL import Image, ImageDraw
import math, os

S = 3  # supersampling
W = 600
TINTS = {'Skincare': (251, 224, 228), 'Make Up': (247, 200, 208),
         'Body Care': (255, 232, 214), 'Hair Care': (235, 221, 240)}
ACC = {'Skincare': (183, 110, 121), 'Make Up': (201, 86, 106),
       'Body Care': (205, 140, 100), 'Hair Care': (140, 105, 165)}
WHITE = (253, 251, 249)
GOLD = (214, 178, 120)


def mix(a, b, t):
    return tuple(int(a[i] * (1 - t) + b[i] * t) for i in range(3))


class C:
    def __init__(self, img, scale=1.0, ox=0, oy=0):
        self.img, self.d = img, ImageDraw.Draw(img)
        self.k, self.ox, self.oy = scale * S, ox * S, oy * S

    def _b(self, box):
        x0, y0, x1, y1 = box
        return [x0 * self.k + self.ox, y0 * self.k + self.oy,
                x1 * self.k + self.ox, y1 * self.k + self.oy]

    def rr(self, box, r, fill):
        self.d.rounded_rectangle(self._b(box), radius=r * self.k, fill=fill)

    def ell(self, box, fill):
        self.d.ellipse(self._b(box), fill=fill)

    def poly(self, pts, fill):
        self.d.polygon([(x * self.k + self.ox, y * self.k + self.oy) for x, y in pts], fill=fill)


def pump(c, a, t):
    c.rr((300, 150, 372, 172), 8, a)
    c.rr((282, 160, 320, 210), 8, a)
    c.rr((274, 205, 326, 240), 6, mix(a, (0, 0, 0), .15))
    c.rr((215, 232, 385, 490), 30, WHITE)
    c.rr((237, 320, 363, 425), 14, a)
    c.rr((256, 345, 344, 356), 5, WHITE)
    c.rr((266, 372, 334, 382), 5, mix(a, WHITE, .5))


def bottle(c, a, t):
    c.rr((255, 135, 345, 205), 14, a)
    c.rr((270, 200, 330, 225), 6, mix(a, (0, 0, 0), .15))
    c.rr((222, 220, 378, 490), 34, WHITE)
    c.rr((240, 310, 360, 420), 14, a)
    c.rr((258, 340, 342, 352), 5, WHITE)
    c.rr((268, 368, 332, 378), 5, mix(a, WHITE, .5))


def tube(c, a, t):
    c.rr((222, 110, 378, 150), 8, mix(WHITE, a, .15))
    c.poly([(226, 148), (374, 148), (364, 432), (236, 432)], WHITE)
    c.rr((246, 420, 354, 490), 12, a)
    c.rr((252, 230, 348, 335), 12, a)
    c.rr((268, 262, 332, 274), 5, WHITE)
    c.rr((276, 290, 324, 300), 5, mix(a, WHITE, .5))


def jar(c, a, t):
    c.rr((178, 330, 422, 490), 34, WHITE)
    c.rr((168, 255, 432, 345), 26, a)
    c.rr((228, 392, 372, 452), 12, mix(a, WHITE, .55))
    c.rr((250, 414, 350, 424), 5, a)


def dropper(c, a, t):
    c.rr((282, 110, 318, 235), 18, mix(a, (0, 0, 0), .1))
    c.rr((262, 225, 338, 275), 8, GOLD)
    c.rr((222, 262, 378, 490), 34, mix(WHITE, t, .35))
    c.rr((244, 345, 356, 440), 12, WHITE)
    c.rr((262, 372, 338, 382), 5, a)
    c.rr((274, 396, 326, 405), 5, mix(a, WHITE, .5))


def lipstick(c, a, t):
    c.rr((240, 385, 360, 490), 14, mix(a, (0, 0, 0), .35))
    c.rr((248, 300, 352, 392), 8, GOLD)
    c.poly([(258, 300), (342, 300), (342, 215), (322, 168), (258, 205)], mix(a, (200, 40, 80), .4))


def tint(c, a, t):
    c.rr((262, 150, 338, 315), 18, mix(a, (0, 0, 0), .35))
    c.rr((252, 305, 348, 490), 26, mix(a, WHITE, .1))
    c.rr((274, 370, 326, 420), 10, WHITE)


def compact(c, a, t):
    c.rr((148, 250, 452, 480), 70, GOLD)
    c.rr((165, 265, 435, 465), 60, mix(GOLD, WHITE, .5))
    c.ell((195, 290, 405, 440), (240, 205, 180))
    c.ell((235, 310, 300, 350), (250, 226, 208))


def pencil(c, a, t):
    c.rr((283, 105, 317, 150), 10, GOLD)
    c.rr((283, 140, 317, 420), 4, a)
    c.rr((296, 160, 304, 410), 3, mix(a, WHITE, .35))
    c.poly([(283, 420), (317, 420), (300, 478)], (226, 192, 152))
    c.poly([(292, 452), (308, 452), (300, 478)], (88, 62, 58))


def mascara(c, a, t):
    c.rr((284, 105, 316, 270), 12, (70, 52, 56))
    c.rr((262, 255, 338, 285), 6, GOLD)
    c.rr((266, 280, 334, 490), 16, mix(a, (0, 0, 0), .3))
    c.rr((280, 360, 320, 372), 5, WHITE)
    c.rr((286, 392, 314, 402), 5, mix(a, WHITE, .5))


def spray(c, a, t):
    c.rr((232, 188, 276, 204), 6, mix(a, (0, 0, 0), .2))
    c.rr((264, 176, 340, 214), 10, mix(a, (0, 0, 0), .2))
    c.rr((282, 208, 322, 270), 6, a)
    c.rr((224, 262, 376, 490), 28, WHITE)
    c.rr((242, 335, 358, 430), 14, a)
    c.rr((262, 362, 338, 374), 5, WHITE)
    c.rr((272, 392, 328, 402), 5, mix(a, WHITE, .5))


SHAPES = dict(pump=pump, bottle=bottle, tube=tube, jar=jar, dropper=dropper, lipstick=lipstick,
              tint=tint, compact=compact, pencil=pencil, mascara=mascara, spray=spray)

PRODUCTS = [
    ('hydrating_cleanser', 'Skincare', 'pump'), ('gentle_foaming_wash', 'Skincare', 'tube'),
    ('vitamin_c_serum', 'Skincare', 'dropper'), ('hyaluronic_serum', 'Skincare', 'dropper'),
    ('daily_moisturizer', 'Skincare', 'jar'), ('sunscreen_spf50', 'Skincare', 'tube'),
    ('velvet_lip_tint', 'Make Up', 'tint'), ('matte_lipstick', 'Make Up', 'lipstick'),
    ('cushion_foundation', 'Make Up', 'compact'), ('liquid_blush', 'Make Up', 'dropper'),
    ('brow_pencil', 'Make Up', 'pencil'), ('mascara_volume', 'Make Up', 'mascara'),
    ('shea_body_lotion', 'Body Care', 'pump'), ('body_scrub', 'Body Care', 'jar'),
    ('body_wash', 'Body Care', 'pump'), ('hand_cream', 'Body Care', 'tube'),
    ('body_butter', 'Body Care', 'jar'), ('body_mist', 'Body Care', 'spray'),
    ('nourishing_shampoo', 'Hair Care', 'bottle'), ('repair_conditioner', 'Hair Care', 'bottle'),
    ('hair_serum', 'Hair Care', 'dropper'), ('hair_mask', 'Hair Care', 'jar'),
    ('hair_tonic', 'Hair Care', 'spray'), ('heat_protection_spray', 'Hair Care', 'spray'),
]


def flower(c, cx, cy, r, petal, center, n=6):
    for i in range(n):
        ang = 2 * math.pi * i / n
        pts = []
        for j in range(40):
            th = 2 * math.pi * j / 40
            ex, ey = r * 0.52 * math.cos(th), r * 0.27 * math.sin(th)
            px, py = ex + r * 0.5, ey
            pts.append((cx + px * math.cos(ang) - py * math.sin(ang),
                        cy + px * math.sin(ang) + py * math.cos(ang)))
        c.poly(pts, petal if i % 2 == 0 else mix(petal, (255, 255, 255), .25))
    c.ell((cx - r * .2, cy - r * .2, cx + r * .2, cy + r * .2), center)


def make_product(name, cat, shape):
    t, a = TINTS[cat], ACC[cat]
    img = Image.new('RGB', (W * S, W * S), t)
    c = C(img)
    c.ell((90, 80, 510, 500), mix(t, WHITE, .45))
    c.ell((160, 478, 440, 512), mix(t, (0, 0, 0), .08))
    flower(c, 110, 120, 34, mix(a, WHITE, .4), GOLD, 5)
    flower(c, 490, 430, 26, mix(a, WHITE, .5), GOLD, 5)
    SHAPES[shape](c, a, t)
    img.resize((W, W), Image.LANCZOS).save(f'assets/images/products/{name}.png', optimize=True)


def make_logo():
    N = 512
    img = Image.new('RGBA', (N * S, N * S), (0, 0, 0, 0))
    c = C(img)
    flower(c, 256, 256, 200, (233, 163, 176), (214, 178, 120), 6)
    flower(c, 256, 256, 120, (183, 110, 121), (255, 248, 240), 6)
    img.resize((N, N), Image.LANCZOS).save('assets/images/logo.png', optimize=True)


def make_banner():
    w, h = 420, 320
    img = Image.new('RGBA', (w * S, h * S), (0, 0, 0, 0))
    flower(C(img), 250, 170, 150, (255, 255, 255, 120), (255, 248, 240), 8)
    pump(C(img, 0.5, 40, 80), ACC['Skincare'], TINTS['Skincare'])
    jar(C(img, 0.42, 185, 130), ACC['Skincare'], TINTS['Skincare'])
    dropper(C(img, 0.4, 270, 105), ACC['Make Up'], TINTS['Make Up'])
    img.resize((w, h), Image.LANCZOS).save('assets/images/banner.png', optimize=True)


if __name__ == '__main__':
    os.makedirs('assets/images/products', exist_ok=True)
    for p in PRODUCTS:
        make_product(*p)
    make_logo()
    make_banner()
    print('done', len(PRODUCTS), 'product images')
