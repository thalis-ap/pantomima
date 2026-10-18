import 'package:flutter/services.dart';
import 'storage_service.dart';

/// Haptic feedback service with graceful fallbacks
class HapticsService {
  final StorageService? _storage;

  HapticsService([this._storage]);

  bool get isEnabled => _storage?.vibrationEnabled ?? true;

  Future<void> success() async {
    if (!isEnabled) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  Future<void> pass() async {
    if (!isEnabled) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  Future<void> timeWarning() async {
    if (!isEnabled) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  Future<void> timeUp() async {
    if (!isEnabled) return;
    try {
      await HapticFeedback.vibrate();
    } catch (_) {}
  }
}
