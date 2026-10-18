#!/usr/bin/env python3
"""
Production Asset & Icon Generation Engine for «Παντομίμα»

Generates:
1. Google Play Store Assets:
   - 512x512 App Icon (store_assets/google_play/icons/google_play_icon_512x512.png)
   - 1024x500 Feature Graphic (store_assets/google_play/feature_graphic/google_play_feature_graphic_1024x500.png)
2. Apple App Store Assets:
   - 1024x1024 App Icon (store_assets/app_store/icons/app_store_icon_1024x1024.png, 24-bit RGB, opaque)
3. Android Launcher Mipmap Assets:
   - mipmap-{mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi}:
     - ic_launcher.png (full-bleed square gradient + mime)
     - ic_launcher_round.png (circle-clipped full-bleed gradient + mime)
     - ic_launcher_background.png (full-bleed gradient)
     - ic_launcher_foreground.png (transparent canvas with mime in safe zone)
   - mipmap-anydpi-v26 XML files
4. iOS AppIcon Asset Catalog:
   - ios/Runner/Assets.xcassets/AppIcon.appiconset/ full set
"""

import json
import math
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
MIME_PATH = os.path.join(REPO_ROOT, "assets", "icon", "mime.png")

# Canonical Gradient: Deep Violet -> Indigo -> Electric Cyan
HERO_START = (109, 40, 217)   # #6D28D9 (Deep Violet)
HERO_MID   = (79, 70, 229)    # #4F46E5 (Indigo)
HERO_CYAN  = (6, 182, 212)    # #06B6D4 (Cyan accent)


def create_full_bleed_gradient(width: int, height: int) -> Image.Image:
    """Generates a smooth diagonal gradient filling the entire canvas corner-to-corner."""
    img = Image.new("RGBA", (width, height), (0, 0, 0, 255))
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


def create_full_bleed_icon(size: int, mime: Image.Image, mime_scale: float = 0.72) -> Image.Image:
    """Creates a full-bleed square launcher icon with gradient background and centered mime."""
    canvas = create_full_bleed_gradient(size, size)

    # Scale mime drawing
    target_w = int(size * mime_scale)
    target_h = int(target_w * (mime.height / mime.width))
    mime_resized = mime.resize((target_w, target_h), Image.Resampling.LANCZOS)

    # Center mime
    pos_x = (size - target_w) // 2
    pos_y = (size - target_h) // 2
    canvas.paste(mime_resized, (pos_x, pos_y), mime_resized)
    return canvas


def create_round_icon(size: int, square_icon: Image.Image) -> Image.Image:
    """Clips the full-bleed square icon into a high-res anti-aliased circle."""
    round_img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    draw.ellipse([(0, 0), (size - 1, size - 1)], fill=255)
    round_img.paste(square_icon, (0, 0), mask)
    return round_img


def create_adaptive_foreground(size: int, mime: Image.Image) -> Image.Image:
    """
    Creates an adaptive icon foreground layer (108dp x 108dp).
    Safe zone is the inner 66% (72dp diameter).
    """
    fg = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    safe_zone = int(size * 0.66)
    target_w = int(safe_zone * 0.85)
    target_h = int(target_w * (mime.height / mime.width))
    mime_resized = mime.resize((target_w, target_h), Image.Resampling.LANCZOS)

    pos_x = (size - target_w) // 2
    pos_y = (size - target_h) // 2
    fg.paste(mime_resized, (pos_x, pos_y), mime_resized)
    return fg


def create_feature_graphic(mime: Image.Image) -> Image.Image:
    """
    Creates Google Play 1024x500 Feature Graphic.
    Must be fully opaque 24-bit RGB (no alpha channel).
    Composed naturally with purple gradient, mime illustration, and «Παντομίμα» title.
    """
    width, height = 1024, 500
    bg = create_full_bleed_gradient(width, height)

    # Convert to RGB early or draw on RGBA then flatten
    canvas = bg.copy()

    # Place mime illustration on the left-center
    mime_h = int(height * 0.72)  # 360px
    mime_w = int(mime_h * (mime.width / mime.height))
    mime_resized = mime.resize((mime_w, mime_h), Image.Resampling.LANCZOS)

    mime_x = 90
    mime_y = (height - mime_h) // 2

    # Subtle ambient glow behind the mime
    glow = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    gcx = mime_x + mime_w // 2
    gcy = mime_y + mime_h // 2
    gr = int(mime_h * 0.48)
    glow_draw.ellipse([gcx - gr, gcy - gr, gcx + gr, gcy + gr], fill=(255, 255, 255, 35))
    glow = glow.filter(ImageFilter.GaussianBlur(radius=35))
    canvas.paste(glow, (0, 0), glow)

    # Paste mime
    canvas.paste(mime_resized, (mime_x, mime_y), mime_resized)

    # Typography for Title & Subtitle
    font_title_path = "/usr/share/fonts/truetype/noto/NotoSans-Bold.ttf"
    if not os.path.exists(font_title_path):
        font_title_path = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"

    font_title = ImageFont.truetype(font_title_path, 86)
    font_sub = ImageFont.truetype(font_title_path, 28)
    font_tag = ImageFont.truetype(font_title_path, 22)

    draw = ImageDraw.Draw(canvas)

    text_x = mime_x + mime_w + 60
    title_text = "Παντομίμα"
    sub_text = "Το απόλυτο παιχνίδι παρέας!"
    tag_text = "100.000 φράσεις • 100% χωρίς ίντερνετ"

    # Draw soft drop shadow for title
    draw.text((text_x + 2, 142), title_text, font=font_title, fill=(20, 10, 45, 180))
    # Draw title in pure crisp white
    draw.text((text_x, 140), title_text, font=font_title, fill=(255, 255, 255, 255))

    # Draw subtitle with soft glow/pill
    draw.text((text_x, 260), sub_text, font=font_sub, fill=(230, 220, 255, 240))

    # Tag badge
    draw.rounded_rectangle([text_x, 320, text_x + 470, 368], radius=14, fill=(255, 255, 255, 30), outline=(255, 255, 255, 80), width=1)
    draw.text((text_x + 20, 332), tag_text, font=font_tag, fill=(255, 255, 255, 245))

    # Flatten to pure 24-bit RGB (no alpha channel allowed on Google Play feature graphic)
    opaque_feature = Image.new("RGB", (width, height), HERO_START)
    opaque_feature.paste(canvas, (0, 0))
    return opaque_feature


def main():
    print("=" * 66)
    print("      ΕΛΛΗΝΙΚΗ ΠΑΝΤΟΜΙΜΑ — STORE ASSET & ICON GENERATOR")
    print("=" * 66)

    mime = Image.open(MIME_PATH).convert("RGBA")

    # Destination directories
    gp_icon_dir = os.path.join(REPO_ROOT, "store_assets", "google_play", "icons")
    gp_feature_dir = os.path.join(REPO_ROOT, "store_assets", "google_play", "feature_graphic")
    gp_screenshots_dir = os.path.join(REPO_ROOT, "store_assets", "google_play", "screenshots")

    as_icon_dir = os.path.join(REPO_ROOT, "store_assets", "app_store", "icons")
    as_screenshots_dir = os.path.join(REPO_ROOT, "store_assets", "app_store", "screenshots")

    for d in [gp_icon_dir, gp_feature_dir, gp_screenshots_dir, as_icon_dir, as_screenshots_dir]:
        os.makedirs(d, exist_ok=True)

    # 1. Google Play 512x512 Icon
    print("\n[1/5] Generating Google Play 512x512 Icon...")
    gp_icon_512 = create_full_bleed_icon(512, mime, mime_scale=0.74)
    gp_icon_path = os.path.join(gp_icon_dir, "google_play_icon_512x512.png")
    gp_icon_512.save(gp_icon_path, "PNG")
    print(f"  ✓ Saved: {gp_icon_path} ({os.path.getsize(gp_icon_path)/1024:.1f} KB)")

    # 2. Google Play 1024x500 Feature Graphic
    print("\n[2/5] Generating Google Play 1024x500 Feature Graphic...")
    feature_graphic = create_feature_graphic(mime)
    fg_path = os.path.join(gp_feature_dir, "google_play_feature_graphic_1024x500.png")
    feature_graphic.save(fg_path, "PNG")
    print(f"  ✓ Saved: {fg_path} ({os.path.getsize(fg_path)/1024:.1f} KB, RGB opaque)")

    # 3. Apple App Store 1024x1024 Icon
    print("\n[3/5] Generating App Store 1024x1024 Icon (RGB opaque)...")
    as_icon_1024 = create_full_bleed_icon(1024, mime, mime_scale=0.74)
    # Ensure fully opaque RGB without alpha channel
    as_icon_opaque = Image.new("RGB", (1024, 1024), HERO_START)
    as_icon_opaque.paste(as_icon_1024, (0, 0))
    as_icon_path = os.path.join(as_icon_dir, "app_store_icon_1024x1024.png")
    as_icon_opaque.save(as_icon_path, "PNG")
    print(f"  ✓ Saved: {as_icon_path} ({os.path.getsize(as_icon_path)/1024:.1f} KB)")

    # 4. Android Launcher Mipmaps
    print("\n[4/5] Generating Android Launcher Mipmaps (full-bleed adaptive + legacy)...")
    densities = {
        "mdpi":    (48, 108),
        "hdpi":    (72, 162),
        "xhdpi":   (96, 216),
        "xxhdpi":  (144, 324),
        "xxxhdpi": (192, 432),
    }

    base_res = os.path.join(REPO_ROOT, "android", "app", "src", "main", "res")

    # High-res masters
    android_square_master = create_full_bleed_icon(512, mime, mime_scale=0.74)
    android_round_master = create_round_icon(512, android_square_master)
    adaptive_bg_master = create_full_bleed_gradient(432, 432)
    adaptive_fg_master = create_adaptive_foreground(432, mime)

    for density, (legacy_size, adaptive_size) in densities.items():
        dir_path = os.path.join(base_res, f"mipmap-{density}")
        os.makedirs(dir_path, exist_ok=True)

        # Legacy square & round
        sq = android_square_master.resize((legacy_size, legacy_size), Image.Resampling.LANCZOS)
        sq.save(os.path.join(dir_path, "ic_launcher.png"))

        rnd = android_round_master.resize((legacy_size, legacy_size), Image.Resampling.LANCZOS)
        rnd.save(os.path.join(dir_path, "ic_launcher_round.png"))

        # Adaptive background & foreground
        bg_img = adaptive_bg_master.resize((adaptive_size, adaptive_size), Image.Resampling.LANCZOS)
        bg_img.save(os.path.join(dir_path, "ic_launcher_background.png"))

        fg_img = adaptive_fg_master.resize((adaptive_size, adaptive_size), Image.Resampling.LANCZOS)
        fg_img.save(os.path.join(dir_path, "ic_launcher_foreground.png"))
        print(f"  ✓ Android mipmap-{density}: legacy {legacy_size}x{legacy_size}, adaptive {adaptive_size}x{adaptive_size}")

    # Adaptive XMLs
    v26_dir = os.path.join(base_res, "mipmap-anydpi-v26")
    os.makedirs(v26_dir, exist_ok=True)
    xml_content = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
"""
    with open(os.path.join(v26_dir, "ic_launcher.xml"), "w") as f:
        f.write(xml_content)
    with open(os.path.join(v26_dir, "ic_launcher_round.xml"), "w") as f:
        f.write(xml_content)

    # 5. iOS AppIcon Catalog
    print("\n[5/5] Generating iOS AppIcon Catalog...")
    xcassets_dir = os.path.join(REPO_ROOT, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset")
    os.makedirs(xcassets_dir, exist_ok=True)
    contents_path = os.path.join(xcassets_dir, "Contents.json")

    with open(contents_path, "r") as f:
        catalog = json.load(f)

    for item in catalog.get("images", []):
        size_str = item["size"]
        scale_str = item["scale"]
        filename = item["filename"]

        scale = float(scale_str.replace("x", ""))
        base_w, base_h = [float(x) for x in size_str.split("x")]
        px_w = int(round(base_w * scale))
        px_h = int(round(base_h * scale))

        resized = as_icon_opaque.resize((px_w, px_h), Image.Resampling.LANCZOS)
        out_path = os.path.join(xcassets_dir, filename)
        resized.save(out_path)
        print(f"  ✓ iOS {filename} ({px_w}x{px_h})")

    # Also save master preview in assets/icon/icon_master.png
    master_preview_path = os.path.join(REPO_ROOT, "assets", "icon", "icon_master.png")
    gp_icon_512.save(master_preview_path)

    print("\n" + "=" * 66)
    print("ALL ICONS & STORE ASSETS SUCCESSFULLY GENERATED!")
    print("=" * 66)


if __name__ == "__main__":
    main()
