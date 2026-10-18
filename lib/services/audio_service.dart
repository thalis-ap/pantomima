import 'package:audioplayers/audioplayers.dart';
import 'storage_service.dart';

/// Audio feedback service playing sound effects for pantomime game events
/// Lazily initializes AudioPlayer and gracefully handles platforms where audio plugins are unavailable.
class AudioService {
  final StorageService? _storage;
  AudioPlayer? _player;
  bool _audioUnavailable = false;

  AudioService([this._storage, AudioPlayer? player]) : _player = player;

  bool get isEnabled => _storage?.soundEnabled ?? true;

  AudioPlayer? get _effectivePlayer {
    if (_audioUnavailable) return null;
    if (_player == null) {
      try {
        _player = AudioPlayer();
      } catch (_) {
        _audioUnavailable = true;
        return null;
      }
    }
    return _player;
  }

  Future<void> playCorrect() async {
    if (!isEnabled) return;
    try {
      final player = _effectivePlayer;
      if (player == null) return;
      await player.stop();
      await player.play(
        AssetSource('audio/correct.wav'),
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {
      _audioUnavailable = true;
    }
  }

  Future<void> playPass() async {
    if (!isEnabled) return;
    try {
      final player = _effectivePlayer;
      if (player == null) return;
      await player.stop();
      await player.play(
        AssetSource('audio/pass.wav'),
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {
      _audioUnavailable = true;
    }
  }

  Future<void> playTick() async {
    if (!isEnabled) return;
    try {
      final player = _effectivePlayer;
      if (player == null) return;
      await player.stop();
      await player.play(
        AssetSource('audio/tick.wav'),
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {
      _audioUnavailable = true;
    }
  }

  Future<void> playBuzzer() async {
    if (!isEnabled) return;
    try {
      final player = _effectivePlayer;
      if (player == null) return;
      await player.stop();
      await player.play(
        AssetSource('audio/buzzer.wav'),
        mode: PlayerMode.lowLatency,
      );
    } catch (_) {
      _audioUnavailable = true;
    }
  }

  void dispose() {
    try {
      _player?.dispose();
    } catch (_) {}
    _player = null;
  }
}
