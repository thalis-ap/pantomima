import 'package:flutter_test/flutter_test.dart';
import 'package:pantomima/data/models/game_configuration.dart';
import 'package:pantomima/data/models/game_enums.dart';
import 'package:pantomima/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('StorageService & Timer Default Duration Tests', () {
    test('Fresh installation defaults to 60 seconds', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.create();
      expect(storage.defaultRoundDuration, 60);
    });

    test(
      'Old legacy null or invalid duration defaults to 60 seconds (migration)',
      () async {
        SharedPreferences.setMockInitialValues({
          'default_round_duration': 0, // invalid
        });
        final storage = await StorageService.create();
        expect(storage.defaultRoundDuration, 60);

        // Negative value
        SharedPreferences.setMockInitialValues({'default_round_duration': -1});
        final storage2 = await StorageService.create();
        expect(storage2.defaultRoundDuration, 60);

        // Random non-preset value
        SharedPreferences.setMockInitialValues({'default_round_duration': 999});
        final storage3 = await StorageService.create();
        expect(storage3.defaultRoundDuration, 60);
      },
    );

    test('Previously saved fixed duration is preserved', () async {
      SharedPreferences.setMockInitialValues({'default_round_duration': 90});
      final storage = await StorageService.create();
      expect(storage.defaultRoundDuration, 90);

      storage.defaultRoundDuration = 45;
      expect(storage.defaultRoundDuration, 45);

      storage.defaultRoundDuration = 120;
      expect(storage.defaultRoundDuration, 120);

      storage.defaultRoundDuration = 180;
      expect(storage.defaultRoundDuration, 180);

      storage.defaultRoundDuration = 30;
      expect(storage.defaultRoundDuration, 30);
    });

    test(
      '3 minutes (180 seconds) is supported in presets and formatted properly',
      () async {
        expect(StorageService.availableDurations.contains(180), isTrue);
        expect(StorageService.formatDuration(180), '180 δευτ.');
        expect(StorageService.formatDuration(60), '60 δευτ.');

        SharedPreferences.setMockInitialValues({'default_round_duration': 180});
        final storage = await StorageService.create();
        expect(storage.defaultRoundDuration, 180);
      },
    );

    test('Reset to defaults restores 60 seconds', () async {
      SharedPreferences.setMockInitialValues({'default_round_duration': 45});
      final storage = await StorageService.create();
      expect(storage.defaultRoundDuration, 45);

      await storage.resetToDefaults();
      expect(storage.defaultRoundDuration, 60);
    });

    test(
      'GameConfiguration defaults to 60 seconds for team mode and free play',
      () {
        final teamConfig = GameConfiguration(
          mode: GameMode.team,
          teams: const [],
        );
        expect(teamConfig.roundDurationSeconds, 60);

        final freePlayConfig = GameConfiguration(mode: GameMode.freePlay);
        expect(freePlayConfig.roundDurationSeconds, 60);
      },
    );

    test('Difficulty changes do not alter configured duration', () {
      final config = GameConfiguration(
        mode: GameMode.team,
        roundDurationSeconds: 45,
        allowedDifficulties: {DifficultyCategory.easy},
      );
      expect(config.getDurationForCategory(DifficultyCategory.easy), 45);
      expect(config.getDurationForCategory(DifficultyCategory.impossible), 45);

      final updatedConfig = config.copyWith(
        allowedDifficulties: {DifficultyCategory.impossible},
      );
      expect(updatedConfig.roundDurationSeconds, 45);
      expect(
        updatedConfig.getDurationForCategory(DifficultyCategory.impossible),
        45,
      );
    });

    test(
      'Streak bonus setting defaults to true and persists changes',
      () async {
        SharedPreferences.setMockInitialValues({});
        final storage = await StorageService.create();
        expect(storage.streakBonusEnabled, isTrue);

        storage.streakBonusEnabled = false;
        expect(storage.streakBonusEnabled, isFalse);

        storage.streakBonusEnabled = true;
        expect(storage.streakBonusEnabled, isTrue);

        storage.streakBonusEnabled = false;
        await storage.resetToDefaults();
        expect(storage.streakBonusEnabled, isTrue);
      },
    );
  });
}
