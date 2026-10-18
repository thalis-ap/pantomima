# Παντομίμα (Pantomima) — Premium Offline Greek Party Game

A production-quality Flutter party game for Greek-speaking friends and families, operating 100% offline with zero runtime network dependency and exactly 100,000 unique, validated Greek game phrases.

# WARNING - THIS APP IS FULLY VIBE CODED WITHOUT A SINGLE LINE WRITTEN BY A HUMAN

---

## Features

- **100,000 Real Greek Phrases**: Curated dataset sourced directly from `frases100000.txt` spanning authentic everyday Greek expressions, situations, actions, and idioms.
- **Strict Category Sizing**:
  - **Εύκολο (Easy)**: exactly 3 words (default 60s)
  - **Μεσαίο (Medium)**: exactly 4 words (default 90s)
  - **Δύσκολο (Hard)**: exactly 5 words (default 105s)
  - **Ακατόρθωτο (Impossible)**: 6, 7, or 8 words (default 120s)
- **100% Greek UI**: All user-facing screens, buttons, labels, dialogs, and errors are in natural, authentic Greek (el-GR).
- **Game Modes**:
  - **Ομαδικό Παιχνίδι (Team Play)**: 2–8 teams, editable Greek team names, round durations, rotation, atomic score tracking («Σωστό» / «Πάσο»), standings, and winner celebration.
  - **Ελεύθερο Παιχνίδι (Free Play)**: Casual untracked play with timer controls and instant next phrase.
- **Audio & Haptic Feedback**: Dynamic countdown clock tick, buzzer on round expiration, cheerful sound on correct answer, soft pass tone, and responsive vibration.
- **Dynamic Monotonic Timer**: Animated circular progress bar that transitions from electric blue to warning amber and alert red, with pulsing during the final seconds. Preserves elapsed time accurately across background/pause states.
- **Persistent Local Settings**: SharedPreferences for sound, vibration, appearance (Dark/Light/System), and default durations.

---

## Project Structure

```
pantomime_ai/
├── android/                    # Android platform configuration (app label: «Παντομίμα»)
├── assets/
│   ├── audio/                  # Synthesized WAV audio effects (correct, pass, tick, buzzer)
│   └── data/
│       └── phrases_el.json     # Bundled 100,000 validated Greek phrases
├── ios/                        # iOS platform configuration
├── lib/
│   ├── main.dart               # App entrypoint and device orientation lock
│   ├── app.dart                # PantomimaApp root widget & theme coordination
│   ├── core/
│   │   ├── localization/       # Complete Greek UI strings (GreekStrings)
│   │   └── theme/              # Deep violet / electric Material 3 design system
│   ├── data/
│   │   ├── models/             # Phrase, Team, GameState, GameConfiguration, Enums
│   │   └── repositories/       # PhraseRepository (in-memory indexing, session history reset)
│   ├── features/
│   │   ├── game/               # GameScreen, CircularTimer, PhraseCard, GameController
│   │   ├── home/               # HomeScreen main menu & hero banner
│   │   ├── scoreboard/         # ScoreboardDialog & FinalResultsScreen
│   │   ├── settings/           # SettingsScreen for audio, haptics, theme, and durations
│   │   └── setup/              # TeamSetupScreen for configuring teams and difficulty
│   ├── services/               # AudioService, HapticsService, StorageService
│   └── shared/                 # GreekButton, GlassCard
├── scripts/
│   ├── process_phrases.py      # Phrase-processing engine for frases100000.txt
│   ├── validate_phrases.py     # Strict dataset validation tool (100,000 phrases)
│   ├── phrase_scorer.py        # Semantic difficulty scoring model
│   └── generate_audio.py      # Synthesized WAV sound effect generator
└── test/
    ├── unit/                   # Unit tests (phrase model, repository, controller, monotonic timer)
    ├── widget/                 # Widget tests (home, team setup, game, settings)
    └── integration/            # End-to-end integration tests (team game & free play flows)
```

---

## Prerequisites

- **Flutter SDK**: 3.38.x or newer
- **Dart SDK**: 3.10.x or newer
- **Python**: 3.10+ (standard library only)
- **Android SDK & JDK**: Android SDK Platform 34+, JDK 17+

---

## Dataset Generation & Validation

The dataset is generated deterministically using standard Python:

```bash
# Generate exactly 10,000 phrases into assets/data/phrases_el.json
python3 scripts/generate_phrases.py

# Validate all schema rules, exact word counts, and uniqueness
python3 scripts/validate_phrases.py

# Re-generate synthesized audio effects if needed
python3 scripts/generate_audio.py
```

Validation output verifies:
- Exactly 10,000 records
- Exactly 2,500 in each category (Εύκολο, Μεσαίο, Δύσκολο, Ακατόρθωτο)
- Strict word counts (3, 4, 5, and 6-8 words)
- 10,000 unique IDs and normalized phrases
- Greek Unicode text confirmation

---

## How to Test

Run the full automated test suite:

```bash
# Code formatting check
dart format --output=none --set-exit-if-changed lib/ test/

# Static analysis (zero issues)
flutter analyze

# Automated unit, widget, and integration tests
flutter test
```

---

## How to Build the Android APK

Build a debug or release Android APK:

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

The compiled APK will be located at:
`build/app/outputs/flutter-apk/app-debug.apk` (or `app-release.apk`).

---

## Running the Application

```bash
# List available devices/emulators
flutter devices
flutter emulators

# Launch the Android emulator
flutter emulators --launch Pixel_6

# Run the app
flutter run
```

---

## CI Workflow

A GitHub Actions CI configuration is provided in `.github/workflows/ci.yml` to automatically run:
1. Python phrase validation
2. `dart format --output=none --set-exit-if-changed .`
3. `flutter analyze`
4. `flutter test`
