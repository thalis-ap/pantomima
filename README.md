# Παντομίμα (Pantomima) — Premium Offline Greek Party Game

A production-quality Flutter party game for Greek-speaking friends and families, operating 100% offline with zero runtime network dependency and exactly 100,000 unique, validated Greek game phrases.

# WARNING - THIS APP IS FULLY VIBE CODED WITHOUT A SINGLE LINE WRITTEN BY A HUMAN

---

## Features

- **100,000 Real Greek Phrases**: Curated dataset processed into `assets/data/phrases_el.json` from `frases100000.txt`, spanning authentic everyday Greek expressions, situations, actions, and idioms.
- **Strict Category Sizing & Scoring**:
  - **Εύκολο (Easy)**: exactly 3 words (25,000 phrases, +1 point)
  - **Μεσαίο (Medium)**: exactly 4 words (25,000 phrases, +2 points)
  - **Δύσκολο (Hard)**: exactly 5 words (25,000 phrases, +3 points)
  - **Ακατόρθωτο (Impossible)**: 6, 7, or 8 words (25,000 phrases, +5 points)
- **Configurable Round Timers**: Duration options for 30s, 45s, 60s (default), 90s, 120s, and 180s (`180 δευτ.`).
- **In-Card Streak System**: Real-time streak tracking with a fire badge (`🔥 3  +1`, `🔥 4  +2`, `🔥 5  +3`) and progressive point bonuses.
- **100% Greek UI**: All user-facing screens, buttons, labels, dialogs, and errors are in natural, authentic Greek (`el-GR`).
- **Game Modes**:
  - **Ομαδικό Παιχνίδι (Team Play)**: 2–8 teams, editable Greek team names, configurable rounds and durations, turn rotation, atomic score tracking («Σωστό» / «Πάσο»), standings dialog, and winner celebration.
  - **Ελεύθερο Παιχνίδι (Free Play)**: Casual untracked play with timer controls, timeout screen with last phrase review, and instant next phrase.
- **Audio & Haptic Feedback**: Dynamic countdown clock tick, buzzer on round expiration, sound on correct answer, soft pass tone, and responsive vibration.
- **Dynamic Monotonic Timer**: Animated circular progress bar that transitions from electric blue to warning amber and alert red, with pulsing during the final seconds. Preserves elapsed time accurately across background/pause states.
- **Persistent Local Settings**: SharedPreferences for sound effects, vibration, appearance (Dark / Light / System), default round duration, and streak bonus toggle.

---

## Project Structure

```text
pantomime_ai/
├── android/                    # Android platform configuration (app ID: com.symplyapps.pantomima)
├── assets/
│   ├── audio/                  # Synthesized WAV audio effects (buzzer, correct, pass, tick)
│   ├── data/
│   │   └── phrases_el.json     # Bundled 100,000 validated Greek phrases (25k per category)
│   └── icon/
│       ├── icon_master.png     # Master 512x512 app icon
│       └── mime.png            # Authentic mime illustration
├── ios/                        # iOS platform configuration and xcassets
├── lib/
│   ├── main.dart               # App entrypoint and device orientation lock
│   ├── app.dart                # PantomimaApp root widget & theme coordination
│   ├── core/
│   │   ├── localization/       # Complete Greek UI strings (GreekStrings)
│   │   └── theme/              # Deep violet / electric Material 3 design system (AppTheme, AppColors)
│   ├── data/
│   │   ├── models/             # Phrase, Team, GameState, GameConfiguration, Enums, StreakCalculator
│   │   └── repositories/       # PhraseRepository (in-memory indexing, session history reset)
│   ├── features/
│   │   ├── game/               # GameScreen, CircularTimer, PhraseCard, GameController
│   │   ├── home/               # HomeScreen main menu & hero banner
│   │   ├── scoreboard/         # ScoreboardDialog & FinalResultsScreen
│   │   ├── settings/           # SettingsScreen for audio, haptics, theme, and durations
│   │   └── setup/              # TeamSetupScreen & FreePlaySetupScreen
│   ├── services/               # AudioService, HapticsService, StorageService
│   └── shared/
│       └── widgets/            # AppLogo, GlassCard, GreekButton
├── scripts/
│   ├── process_phrases.py      # Phrase-processing engine for text dataset
│   ├── validate_phrases.py     # Strict dataset validation tool (100,000 phrases)
│   ├── phrase_scorer.py        # Semantic difficulty scoring model
│   ├── test_phrase_processor.py# Unit tests for phrase processing engine
│   ├── generate_audio.py       # Synthesized WAV sound effect generator
│   ├── generate_icons.py       # Android & iOS launcher icon generator
│   ├── generate_store_assets.py# Google Play & App Store graphics generator
│   └── validate_store_assets.py# Store assets and launcher icons validator
├── store_assets/
│   ├── google_play/            # Google Play store icons, feature graphic, and phone screenshots
│   ├── app_store/              # Apple App Store master icon (1024x1024)
│   ├── manifest.json           # Store asset deliverables metadata
│   └── README.md               # Store submission guide and field mapping
└── test/
    ├── unit/                   # Unit tests (phrase model, repository, controller, storage, streak)
    ├── widget/                 # Widget tests (home, team setup, free play setup, game, settings)
    └── integration/            # End-to-end integration tests (team game & free play flows)
```

---

## Prerequisites

- **Flutter SDK**: 3.38.x or newer
- **Dart SDK**: 3.10.x or newer
- **Python**: 3.10+ (standard library and Pillow for asset tooling)
- **Android SDK & JDK**: Android SDK Platform 34+, JDK 17+

---

## Setup & Dependency Installation

Install Flutter dependencies:

```bash
flutter pub get
```

---

## Phrase Dataset Processing & Validation

The phrase dataset is processed and validated using Python:

```bash
# Process raw phrases into assets/data/phrases_el.json
python3 scripts/process_phrases.py --input phraseis_creator/frases100000.txt --output assets/data/phrases_el.json

# Validate dataset schema, word counts, and uniqueness (100,000 records)
python3 scripts/validate_phrases.py

# Run unit tests for the phrase processing engine
python3 -m unittest scripts/test_phrase_processor.py

# Re-generate synthesized audio effects if needed
python3 scripts/generate_audio.py
```

Validation output verifies:
- Exactly 100,000 records
- Exactly 25,000 in each category (Εύκολο, Μεσαίο, Δύσκολο, Ακατόρθωτο)
- Strict word counts (3, 4, 5, and 6–8 words)
- 100,000 unique IDs and normalized phrases
- Greek Unicode text and tonos preservation

---

## Store Assets & Launcher Icons

Launcher icons and store marketing assets are managed through automated scripts:

```bash
# Generate Android mipmap icons and iOS AppIcon catalog
python3 scripts/generate_icons.py

# Generate Google Play store graphics and master icons
python3 scripts/generate_store_assets.py

# Validate all 43 store assets, screenshots, and launcher icons
python3 scripts/validate_store_assets.py
```

All store deliverables and upload field mappings are documented in [`store_assets/README.md`](store_assets/README.md).

---

## How to Test

Run the full automated test suite and static analysis:

```bash
# Static analysis (zero issues)
flutter analyze

# Automated unit, widget, and integration tests (88 tests)
flutter test

# Store assets validation
python3 scripts/validate_store_assets.py
```

---

## Running the Application

```bash
# List available devices/emulators
flutter devices

# Run the app on the connected device or emulator
flutter run
```

---

## Building Android Release Artifacts

### 1. Release Signing Setup

Release signing is configured in `android/app/build.gradle.kts` and reads credentials from `android/keystore.properties`:

```properties
storeFile=/path/to/your/upload-keystore.jks
storePassword=your-keystore-password
keyAlias=your-key-alias
keyPassword=your-key-password
```

> [!NOTE]
> `android/keystore.properties` is excluded from version control via `.gitignore`. Never commit signing credentials or keystores to Git.

### 2. Build Commands

```bash
# Build Android App Bundle (for Google Play Console submission)
flutter build appbundle --release

# Build standalone Release APK
flutter build apk --release

# Build Debug APK (for local testing)
flutter build apk --debug
```

Build outputs are located at:
- **App Bundle**: `build/app/outputs/bundle/release/app-release.aab`
- **Release APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **Debug APK**: `build/app/outputs/flutter-apk/app-debug.apk`
