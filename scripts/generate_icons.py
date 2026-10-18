#!/usr/bin/env python3
"""
Generates complete production-quality launcher icons for Android and iOS
using assets/icon/mime.png with the purple circular background style.
"""
import os
import json
import math
from PIL import Image, ImageDraw, ImageFilter

HERO_START = (109, 40, 217)   # #6D28D9 (Violet)
HERO_MID   = (79, 70, 229)    # #4F46E5 (Indigo)
HERO_CYAN  = (6, 182, 212)    # #06B6D4 (Cyan accent)
DARK_BG    = (15, 11, 30, 255)# #0F0B1E (Dark foundation)

def create_gradient_circle(size):
    """
    Creates high-res anti-aliased gradient circle.
    """
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    radius = size / 2.0
    for y in range(size):
        for x in range(size):
            dx = x - radius + 0.5
            dy = y - radius + 0.5
            dist = math.sqrt(dx * dx + dy * dy)
            if dist <= radius:
                alpha = 255
                if dist > radius - 1.5:
                    alpha = int(255 * (radius - dist) / 1.5)
                    alpha = max(0, min(255, alpha))
                
                t = (x + y) / (2.0 * size)
                if t < 0.6:
                    lt = t / 0.6
                    r = int(HERO_START[0] + (HERO_MID[0] - HERO_START[0]) * lt)
                    g = int(HERO_START[1] + (HERO_MID[1] - HERO_START[1]) * lt)
                    b = int(HERO_START[2] + (HERO_MID[2] - HERO_START[2]) * lt)
                else:
                    lt = (t - 0.6) / 0.4
                    r = int(HERO_MID[0] + (HERO_CYAN[0] - HERO_MID[0]) * lt)
                    g = int(HERO_MID[1] + (HERO_CYAN[1] - HERO_MID[1]) * lt)
                    b = int(HERO_MID[2] + (HERO_CYAN[2] - HERO_MID[2]) * lt)
                img.putpixel((x, y), (r, g, b, alpha))
    return img

def create_full_bleed_gradient(width, height):
    """
    Creates full-bleed adaptive background gradient.
    """
    img = Image.new('RGBA', (width, height), (0, 0, 0, 255))
    total = float(width + height)
    for y in range(height):
        for x in range(width):
            t = (x + y) / total
            if t < 0.6:
                lt = t / 0.6
                r = int(HERO_START[0] + (HERO_MID[0] - HERO_START[0]) * lt)
                g = int(HERO_START[1] + (HERO_MID[1] - HERO_START[1]) * lt)
                b = int(HERO_START[2] + (HERO_MID[2] - HERO_START[2]) * lt)
            else:
                lt = (t - 0.6) / 0.4
                r = int(HERO_MID[0] + (HERO_CYAN[0] - HERO_MID[0]) * lt)
                g = int(HERO_MID[1] + (HERO_CYAN[1] - HERO_MID[1]) * lt)
                b = int(HERO_MID[2] + (HERO_CYAN[2] - HERO_MID[2]) * lt)
            img.putpixel((x, y), (r, g, b, 255))
    return img

def generate_master_images():
    mime = Image.open('assets/icon/mime.png').convert('RGBA')
    
    # 1. iOS Master: 1024x1024 opaque with darkBg, glowing purple circle, centered mime
    ios_master = Image.new('RGBA', (1024, 1024), DARK_BG)
    circle_size = 840
    circle = create_gradient_circle(circle_size)
    
    # Subtle ambient glow around circle
    shadow = Image.new('RGBA', (1024, 1024), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow)
    cx, cy = 512, 512
    r = circle_size // 2
    sdraw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(124, 58, 237, 100))
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=20))
    ios_master.paste(shadow, (0, 6), shadow)
    
    # Paste circle
    c_pos = (1024 - circle_size) // 2
    ios_master.paste(circle, (c_pos, c_pos), circle)
    
    # Scale mime drawing
    mw = int(circle_size * 0.64)
    mh = int(mw * (mime.height / mime.width))
    mime_resized = mime.resize((mw, mh), Image.Resampling.LANCZOS)
    mx = (1024 - mw) // 2
    my = (1024 - mh) // 2
    ios_master.paste(mime_resized, (mx, my), mime_resized)
    # Ensure fully opaque RGB for iOS App Store
    ios_master_opaque = Image.new('RGB', (1024, 1024), (15, 11, 30))
    ios_master_opaque.paste(ios_master, (0, 0), ios_master)
    
    # 2. Android Round / Legacy Master: 512x512 transparent background, purple circle, centered mime
    android_legacy_master = Image.new('RGBA', (512, 512), (0, 0, 0, 0))
    a_circle_size = 480
    a_circle = create_gradient_circle(a_circle_size)
    ac_pos = (512 - a_circle_size) // 2
    android_legacy_master.paste(a_circle, (ac_pos, ac_pos), a_circle)
    amw = int(a_circle_size * 0.64)
    amh = int(amw * (mime.height / mime.width))
    a_mime = mime.resize((amw, amh), Image.Resampling.LANCZOS)
    amx = (512 - amw) // 2
    amy = (512 - amh) // 2
    android_legacy_master.paste(a_mime, (amx, amy), a_mime)
    
    # 3. Android Adaptive Foreground: 432x432 (108dp @ 4x xxxhdpi)
    # Central 288x288 is safe zone (66.7%). Mime sits safely inside safe zone.
    adaptive_fg_master = Image.new('RGBA', (432, 432), (0, 0, 0, 0))
    safe_zone = 288
    fg_mw = int(safe_zone * 0.78)
    fg_mh = int(fg_mw * (mime.height / mime.width))
    fg_mime = mime.resize((fg_mw, fg_mh), Image.Resampling.LANCZOS)
    fmx = (432 - fg_mw) // 2
    fmy = (432 - fg_mh) // 2
    adaptive_fg_master.paste(fg_mime, (fmx, fmy), fg_mime)
    
    # 4. Android Adaptive Background: 432x432 full bleed gradient
    adaptive_bg_master = create_full_bleed_gradient(432, 432)
    
    return ios_master_opaque, android_legacy_master, adaptive_fg_master, adaptive_bg_master

def export_android_icons(legacy_master, fg_master, bg_master):
    densities = {
        'mdpi':    (48, 108),
        'hdpi':    (72, 162),
        'xhdpi':   (96, 216),
        'xxhdpi':  (144, 324),
        'xxxhdpi': (192, 432),
    }
    
    base_res = 'android/app/src/main/res'
    
    for density, (legacy_size, adaptive_size) in densities.items():
        dir_path = os.path.join(base_res, f'mipmap-{density}')
        os.makedirs(dir_path, exist_ok=True)
        
        # Legacy square / round icons
        legacy_img = legacy_master.resize((legacy_size, legacy_size), Image.Resampling.LANCZOS)
        legacy_img.save(os.path.join(dir_path, 'ic_launcher.png'))
        legacy_img.save(os.path.join(dir_path, 'ic_launcher_round.png'))
        
        # Adaptive foreground & background
        fg_img = fg_master.resize((adaptive_size, adaptive_size), Image.Resampling.LANCZOS)
        fg_img.save(os.path.join(dir_path, 'ic_launcher_foreground.png'))
        
        bg_img = bg_master.resize((adaptive_size, adaptive_size), Image.Resampling.LANCZOS)
        bg_img.save(os.path.join(dir_path, 'ic_launcher_background.png'))
        print(f'Exported Android mipmap-{density} (legacy: {legacy_size}x{legacy_size}, adaptive: {adaptive_size}x{adaptive_size})')
    
    # Create adaptive icon XML definitions for API 26+
    v26_dir = os.path.join(base_res, 'mipmap-anydpi-v26')
    os.makedirs(v26_dir, exist_ok=True)
    
    xml_content = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
'''
    with open(os.path.join(v26_dir, 'ic_launcher.xml'), 'w') as f:
        f.write(xml_content)
    with open(os.path.join(v26_dir, 'ic_launcher_round.xml'), 'w') as f:
        f.write(xml_content)
    print('Created mipmap-anydpi-v26/ic_launcher.xml and ic_launcher_round.xml')

def export_ios_icons(ios_master):
    xcassets_dir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
    os.makedirs(xcassets_dir, exist_ok=True)
    
    contents_path = os.path.join(xcassets_dir, 'Contents.json')
    with open(contents_path, 'r') as f:
        data = json.load(f)
        
    for item in data.get('images', []):
        size_str = item['size'] # e.g. "20x20", "83.5x83.5"
        scale_str = item['scale'] # e.g. "1x", "2x", "3x"
        filename = item['filename']
        
        scale = float(scale_str.replace('x', ''))
        base_w, base_h = [float(x) for x in size_str.split('x')]
        px_w = int(round(base_w * scale))
        px_h = int(round(base_h * scale))
        
        resized = ios_master.resize((px_w, px_h), Image.Resampling.LANCZOS)
        out_path = os.path.join(xcassets_dir, filename)
        resized.save(out_path)
        print(f'Exported iOS {filename} ({px_w}x{px_h})')

if __name__ == '__main__':
    print('Generating master assets from assets/icon/mime.png...')
    ios_master, android_legacy, adaptive_fg, adaptive_bg = generate_master_images()
    
    print('\nExporting Android icons...')
    export_android_icons(android_legacy, adaptive_fg, adaptive_bg)
    
    print('\nExporting iOS icons...')
    export_ios_icons(ios_master)
    
    print('\nAll launcher icon assets generated successfully!')
