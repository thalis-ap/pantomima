import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/localization/greek_strings.dart';

/// Service managing persistent local settings using SharedPreferences
class StorageService {
  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keyVibrationEnabled = 'vibration_enabled';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyDefaultRoundDuration = 'default_round_duration';
  static const String _keyPreferredDifficulties = 'preferred_difficulties';
  static const String _keyStreakBonusEnabled = 'streak_bonus_enabled';

  final SharedPreferences? _prefs;

  StorageService([this._prefs]);

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  bool get streakBonusEnabled =>
      _prefs?.getBool(_keyStreakBonusEnabled) ?? true;
  set streakBonusEnabled(bool value) =>
      _prefs?.setBool(_keyStreakBonusEnabled, value);

  bool get soundEnabled => _prefs?.getBool(_keySoundEnabled) ?? true;
  set soundEnabled(bool value) => _prefs?.setBool(_keySoundEnabled, value);

  bool get vibrationEnabled => _prefs?.getBool(_keyVibrationEnabled) ?? true;
  set vibrationEnabled(bool value) =>
      _prefs?.setBool(_keyVibrationEnabled, value);

  ThemeMode get themeMode {
    final str = _prefs?.getString(_keyThemeMode);
    switch (str) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode
            .dark; // Default to rich dark mode for pantomime party experience
    }
  }

  set themeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        _prefs?.setString(_keyThemeMode, 'light');
        break;
      case ThemeMode.dark:
        _prefs?.setString(_keyThemeMode, 'dark');
        break;
      case ThemeMode.system:
        _prefs?.setString(_keyThemeMode, 'system');
        break;
    }
  }

  static const int kDefaultRoundDurationSeconds = 60;
  static const List<int> availableDurations = [30, 45, 60, 90, 120, 180];

  /// Returns localized duration label (e.g. '180 δευτ.' for 180, '60 δευτ.' for 60)
  static String formatDuration(int seconds) {
    return '$seconds ${GreekStrings.seconds}';
  }

  int get defaultRoundDuration {
    final val = _prefs?.getInt(_keyDefaultRoundDuration);
    if (val != null && availableDurations.contains(val)) {
      return val;
    }
    // Migration fallback for legacy null/auto/invalid values:
    return kDefaultRoundDurationSeconds;
  }

  set defaultRoundDuration(int value) {
    _prefs?.setInt(_keyDefaultRoundDuration, value);
  }

  List<String> get preferredDifficulties =>
      _prefs?.getStringList(_keyPreferredDifficulties) ?? [];

  set preferredDifficulties(List<String> list) =>
      _prefs?.setStringList(_keyPreferredDifficulties, list);

  /// Resets all settings to default values
  Future<void> resetToDefaults() async {
    await _prefs?.remove(_keySoundEnabled);
    await _prefs?.remove(_keyVibrationEnabled);
    await _prefs?.remove(_keyThemeMode);
    await _prefs?.remove(_keyDefaultRoundDuration);
    await _prefs?.remove(_keyPreferredDifficulties);
    await _prefs?.remove(_keyStreakBonusEnabled);
  }
}
