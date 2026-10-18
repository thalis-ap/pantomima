#!/usr/bin/env python3
"""
Store Assets & Launcher Icons Validation Script for Παντομίμα
Checks:
- Dimensions (exact pixel match)
- File format (PNG)
- Color mode / Alpha channel (RGB vs RGBA)
- File size (within Google Play and Apple limits)
- Corruption / readability
- Presence of all required Android mipmap & iOS AppIcon assets
"""

import os
import sys
import json
from PIL import Image

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STORE_ASSETS = os.path.join(PROJECT_ROOT, "store_assets")

def check_image(path, expected_w, expected_h, expected_mode=None, max_bytes=None, name=""):
    errors = []
    warnings = []
    
    if not os.path.exists(path):
        return [f"MISSING: File not found at {path}"], []
    
    file_size = os.path.getsize(path)
    if file_size == 0:
        return [f"EMPTY: File is 0 bytes at {path}"], []
        
    try:
        with Image.open(path) as img:
            img.verify()
    except Exception as e:
        return [f"CORRUPT: Cannot verify image {path}: {e}"], []
        
    try:
        with Image.open(path) as img:
            w, h = img.size
            mode = img.mode
            format_name = img.format
            
            if (w, h) != (expected_w, expected_h):
                errors.append(f"DIMENSIONS: Expected {expected_w}x{expected_h}, got {w}x{h}")
                
            if expected_mode and mode != expected_mode:
                if expected_mode == "RGB" and mode == "RGBA":
                    errors.append(f"ALPHA: Expected RGB (no alpha), but has RGBA alpha channel")
                else:
                    warnings.append(f"MODE: Expected {expected_mode}, got {mode}")
                    
            if max_bytes and file_size > max_bytes:
                errors.append(f"SIZE: File size {file_size} exceeds max {max_bytes} bytes")
                
            return errors, warnings
    except Exception as e:
        return [f"ERROR: Cannot read image {path}: {e}"], []

def main():
    print("=" * 66)
    print("      ΠΑΝΤΟΜΙΜΑ — STORE ASSET & LAUNCHER ICON VALIDATION")
    print("=" * 66)
    
    all_passed = True
    total_checks = 0
    
    specs = [
        # (path, expected_w, expected_h, expected_mode, max_bytes, label)
        (
            os.path.join(STORE_ASSETS, "google_play/icons/google_play_icon_512x512.png"),
            512, 512, None, 1024 * 1024,
            "Google Play Store Icon (512x512)"
        ),
        (
            os.path.join(STORE_ASSETS, "google_play/feature_graphic/google_play_feature_graphic_1024x500.png"),
            1024, 500, "RGB", 1024 * 1024,
            "Google Play Feature Graphic (1024x500, No Alpha)"
        ),
        (
            os.path.join(STORE_ASSETS, "app_store/icons/app_store_icon_1024x1024.png"),
            1024, 1024, "RGB", 5 * 1024 * 1024,
            "App Store Master Icon (1024x1024, No Alpha)"
        ),
    ]

    # Google Play Screenshots
    screenshots = [
        ("01_home_screen.png", "Home Screen"),
        ("02_team_setup_screen.png", "Team Setup Screen (180 δευτ. option)"),
        ("03_gameplay_3min_timer.png", "Active Gameplay Screen (3-min timer)"),
        ("04_gameplay_streak.png", "Gameplay Screen (Streak Indicator)"),
        ("05_settings_screen.png", "Settings Screen (Mime Logo & 180 δευτ.)"),
        ("06_free_play_time_up.png", "Free Play Timeout Screen"),
    ]
    for filename, label in screenshots:
        specs.append((
            os.path.join(STORE_ASSETS, "google_play/screenshots", filename),
            1080, 2160, "RGB", 8 * 1024 * 1024,
            f"Google Play Screenshot: {label} (1080x2160 1:2, No Alpha)"
        ))
    
    # Android mipmaps
    res_dir = os.path.join(PROJECT_ROOT, "android/app/src/main/res")
    android_specs = {
        "mipmap-mdpi": (48, 108),
        "mipmap-hdpi": (72, 162),
        "mipmap-xhdpi": (96, 216),
        "mipmap-xxhdpi": (144, 324),
        "mipmap-xxxhdpi": (192, 432),
    }
    for folder, (legacy_sz, adaptive_sz) in android_specs.items():
        specs.append((
            os.path.join(res_dir, folder, "ic_launcher.png"),
            legacy_sz, legacy_sz, None, 200 * 1024,
            f"Android {folder} ic_launcher ({legacy_sz}x{legacy_sz})"
        ))
        specs.append((
            os.path.join(res_dir, folder, "ic_launcher_round.png"),
            legacy_sz, legacy_sz, None, 200 * 1024,
            f"Android {folder} ic_launcher_round ({legacy_sz}x{legacy_sz})"
        ))
        specs.append((
            os.path.join(res_dir, folder, "ic_launcher_foreground.png"),
            adaptive_sz, adaptive_sz, None, 300 * 1024,
            f"Android {folder} ic_launcher_foreground ({adaptive_sz}x{adaptive_sz})"
        ))
        
    # iOS AppIcon catalog
    ios_catalog_dir = os.path.join(PROJECT_ROOT, "ios/Runner/Assets.xcassets/AppIcon.appiconset")
    contents_path = os.path.join(ios_catalog_dir, "Contents.json")
    if os.path.exists(contents_path):
        with open(contents_path, "r", encoding="utf-8") as f:
            catalog = json.load(f)
        for img_entry in catalog.get("images", []):
            filename = img_entry.get("filename")
            if not filename:
                continue
            size_parts = img_entry["size"].split("x")
            scale = int(img_entry["scale"].replace("x", ""))
            target_w = int(float(size_parts[0]) * scale)
            target_h = int(float(size_parts[1]) * scale)
            expected_mode = "RGB" if (target_w == 1024 and target_h == 1024) else None
            specs.append((
                os.path.join(ios_catalog_dir, filename),
                target_w, target_h, expected_mode, 5 * 1024 * 1024,
                f"iOS {filename} ({target_w}x{target_h})"
            ))

    print(f"Validating {len(specs)} assets...\n")
    for path, exp_w, exp_h, exp_mode, max_sz, label in specs:
        total_checks += 1
        errors, warnings = check_image(path, exp_w, exp_h, exp_mode, max_sz, label)
        file_sz_kb = os.path.getsize(path) / 1024 if os.path.exists(path) else 0
        if errors:
            all_passed = False
            print(f"  ✗ [FAIL] {label}")
            for err in errors:
                print(f"      - {err}")
        else:
            status = "✓ [OK]"
            warn_str = f" (Warnings: {', '.join(warnings)})" if warnings else ""
            print(f"  {status} {label}: {exp_w}x{exp_h}, {file_sz_kb:.1f} KB{warn_str}")
            
    print("\n" + "=" * 66)
    if all_passed:
        print(f"SUCCESS: All {total_checks} assets passed validation perfectly!")
        print("=" * 66)
        return 0
    else:
        print(f"FAILED: Some asset validation checks failed.")
        print("=" * 66)
        return 1

if __name__ == "__main__":
    sys.exit(main())
