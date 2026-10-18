"""Renders PNG versions of the launcher icon (same geometry as
android/app/src/main/res/drawable/ic_launcher_foreground.xml).
Run: python tool/render_icons.py"""
import math
from PIL import Image, ImageDraw

BG = (0x17, 0x32, 0x3F, 255)
RING = (0x8E, 0xD1, 0xE6, 255)
DOT = (0xF2, 0xC4, 0x6D, 255)


def render(px, shape):
    """shape: 'square' (Play: full bleed, Play applies the mask) or 'circle'
    (legacy launcher icon). Geometry in 108-unit adaptive-icon space; legacy
    icons show the central 72 units."""
    ss = 4  # supersample
    size = px * ss
    view = 108 if shape == 'square' else 72
    k = size / view
    off = 0 if shape == 'square' else (108 - 72) / 2

    def u(v):
        return (v - off) * k

    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    if shape == 'square':
        d.rectangle([0, 0, size, size], fill=BG)
    else:
        d.ellipse([0, 0, size - 1, size - 1], fill=BG)
    r, w = 21, 7
    box = [u(54 - r - w / 2), u(54 - r - w / 2), u(54 + r + w / 2), u(54 + r + w / 2)]
    # 270 degrees clockwise from 12 o'clock to 9 o'clock.
    d.arc(box, start=270, end=180, fill=RING, width=round(w * k))
    for ang in (270, 180):  # round caps
        x = 54 + r * math.cos(math.radians(ang))
        y = 54 + r * math.sin(math.radians(ang))
        d.ellipse([u(x - w / 2), u(y - w / 2), u(x + w / 2), u(y + w / 2)], fill=RING)
    d.ellipse([u(49), u(49), u(59), u(59)], fill=DOT)
    return img.resize((px, px), Image.LANCZOS)


if __name__ == '__main__':
    res = 'android/app/src/main/res'
    for folder, px in [('mdpi', 48), ('hdpi', 72), ('xhdpi', 96), ('xxhdpi', 144), ('xxxhdpi', 192)]:
        render(px, 'circle').save(f'{res}/mipmap-{folder}/ic_launcher.png')
    render(512, 'square').save('store/play_icon_512.png')
    print('ok')
