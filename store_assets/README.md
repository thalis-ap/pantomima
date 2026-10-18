# Παντομίμα — Store Assets & Visual Branding

This directory contains the production-ready store assets, app icons, and screenshots for **Παντομίμα** (`com.symplyapps.pantomima`).

---

## 1. Directory Structure

```text
store_assets/
├── manifest.json
├── README.md
├── google_play/
│   ├── icons/
│   │   └── google_play_icon_512x512.png
│   ├── feature_graphic/
│   │   └── google_play_feature_graphic_1024x500.png
│   └── screenshots/
│       ├── 01_home_screen.png
│       ├── 02_team_setup_screen.png
│       ├── 03_gameplay_3min_timer.png
│       ├── 04_gameplay_streak.png
│       ├── 05_settings_screen.png
│       ├── 06_free_play_time_up.png
│       └── raw/
│           └── (original uncropped 1080x2400 captures)
└── app_store/
    ├── icons/
    │   └── app_store_icon_1024x1024.png
    └── screenshots/
        └── (ready for macOS/iOS simulator capture)
```

---

## 2. Store Upload Field Mapping

### Google Play Console

| Store Field | File Path | Dimensions | Format / Color Mode | Maximum Size |
|---|---|---|---|---|
| **App icon** | `store_assets/google_play/icons/google_play_icon_512x512.png` | 512 × 512 px | PNG (32-bit RGBA) | 1,024 KB |
| **Feature graphic** | `store_assets/google_play/feature_graphic/google_play_feature_graphic_1024x500.png` | 1024 × 500 px | PNG (24-bit RGB, **no alpha**) | 1,024 KB |
| **Phone screenshots** | `store_assets/google_play/screenshots/01_home_screen.png`<br>`store_assets/google_play/screenshots/02_team_setup_screen.png`<br>`store_assets/google_play/screenshots/03_gameplay_3min_timer.png`<br>`store_assets/google_play/screenshots/04_gameplay_streak.png`<br>`store_assets/google_play/screenshots/05_settings_screen.png`<br>`store_assets/google_play/screenshots/06_free_play_time_up.png` | 1080 × 2160 px (1:2 ratio) | PNG (24-bit RGB, **no alpha**) | 8 MB each |

> [!NOTE]
> All Google Play screenshots have been captured from a real running Android environment (`emulator-5554` running Android 13 API 33) and formatted to 1080 × 2160 (1:2 aspect ratio, conforming strictly with Google Play's max 1:2 ratio requirement) without stretching. The Android system bars (status bar clock/battery and navigation pill) were removed to avoid personal device notifications.

### Apple App Store Connect

| Store Field | File Path | Dimensions | Format / Color Mode | Maximum Size |
|---|---|---|---|---|
| **App Store Icon** | `store_assets/app_store/icons/app_store_icon_1024x1024.png` | 1024 × 1024 px | PNG (24-bit RGB, **no alpha**) | 5 MB |
| **iPhone Screenshots** | `store_assets/app_store/screenshots/` | Required device sizes (see below) | PNG / JPEG | Per device |

---

## 3. Assets Connected to the Flutter Project

The following assets have been generated and connected directly to the Flutter codebase:

1. **Android Launcher Icons**:
   - Adaptive foreground: `android/app/src/main/res/mipmap-*/ic_launcher_foreground.png`
   - Adaptive background: `android/app/src/main/res/values/colors.xml` (`ic_launcher_background`)
   - Legacy launcher icons: `android/app/src/main/res/mipmap-*/ic_launcher.png`
   - Legacy round icons: `android/app/src/main/res/mipmap-*/ic_launcher_round.png`
   - Master icon: `assets/icon/icon_master.png`

2. **iOS Launcher Asset Catalog**:
   - `ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json`
   - Complete set of idiom images from 20x20 up to 1024x1024 master icon (`Icon-App-*.png`).

3. **In-App Logos**:
   - `lib/shared/widgets/app_logo.dart` uses `assets/icon/mime.png` with the unified purple hero gradient (`AppColors.heroGradient`).
   - Home screen (`lib/features/home/home_screen.dart`) and Settings screen (`lib/features/settings/settings_screen.dart`) reference `AppLogo`.

---

## 4. Assets Requiring Manual Upload

When submitting the app for review:
1. **Google Play Console**:
   - Upload `store_assets/google_play/icons/google_play_icon_512x512.png` to the **App icon** field.
   - Upload `store_assets/google_play/feature_graphic/google_play_feature_graphic_1024x500.png` to the **Feature graphic** field.
   - Upload the 6 screenshots in `store_assets/google_play/screenshots/` to the **Phone screenshots** section.
2. **Apple App Store Connect**:
   - Upload `store_assets/app_store/icons/app_store_icon_1024x1024.png` to the **App Store Icon** field (or let Xcode archive submit it from `AppIcon.appiconset`).

---

## 5. Unverified Checks & Environment Notes

- **macOS / Xcode Environment**: This machine runs Linux (`x86_64 Linux 6.6.137+rpt-rpi-2712`). Xcode, macOS SDKs, and iOS Simulators are not available in this environment. As required by prompt instructions, Apple screenshots were **not fabricated** or converted from Android captures. Capturing native iOS screenshots will require running the app on a macOS machine with Xcode/iOS Simulator or a physical iPhone.
- **Required iPhone Screenshot Dimensions** (for macOS capture):
  - 6.9" Super Retina XDR (iPhone 16 Pro Max): 1320 × 2868 px
  - 6.7" Super Retina XDR (iPhone 15 Pro Max / 14 Pro Max): 1290 × 2796 px
  - 6.5" Super Retina XDR (iPhone 14 Plus / 11 Pro Max): 1242 × 2688 px
  - 5.5" Retina (iPhone 8 Plus): 1242 × 2208 px
- **Validation Script**: Run `python3 scripts/validate_store_assets.py` to programmatically verify all asset dimensions, formats, and alpha channels at any time.
