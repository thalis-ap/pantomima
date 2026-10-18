import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantomima/core/localization/greek_strings.dart';
import 'package:pantomima/features/settings/settings_screen.dart';
import 'package:pantomima/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SettingsScreen Widget Tests', () {
    late StorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'sound_enabled': true,
        'vibration_enabled': true,
        'theme_mode': 'dark',
      });
      storage = await StorageService.create();
    });

    testWidgets('Toggling sound and vibration updates storage', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(storage: storage, onThemeChanged: (_) {}),
        ),
      );

      // Verify titles
      expect(find.text(GreekStrings.settingsTitle), findsOneWidget);
      expect(find.text(GreekStrings.soundEffects), findsOneWidget);
      expect(find.text(GreekStrings.streakBonus), findsNWidgets(2));
      expect(find.text(GreekStrings.streakBonusDescription), findsOneWidget);

      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(3));

      // Tap sound toggle (switch 0)
      await tester.tap(switches.at(0));
      await tester.pumpAndSettle();
      expect(storage.soundEnabled, isFalse);

      // Tap vibration toggle (switch 1)
      await tester.tap(switches.at(1));
      await tester.pumpAndSettle();
      expect(storage.vibrationEnabled, isFalse);

      // Tap streak bonus toggle (switch 2)
      await tester.tap(switches.at(2));
      await tester.pumpAndSettle();
      expect(storage.streakBonusEnabled, isFalse);

      // Tap streak bonus toggle again to re-enable
      await tester.tap(switches.at(2));
      await tester.pumpAndSettle();
      expect(storage.streakBonusEnabled, isTrue);
    });

    testWidgets('Theme selection triggers onThemeChanged callback', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      ThemeMode? changedMode;

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(
            storage: storage,
            onThemeChanged: (mode) => changedMode = mode,
          ),
        ),
      );

      // Tap light theme
      await tester.tap(find.text(GreekStrings.themeLight));
      await tester.pumpAndSettle();

      expect(changedMode, ThemeMode.light);
      expect(storage.themeMode, ThemeMode.light);
    });

    testWidgets('Reset button shows confirmation dialog', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(storage: storage, onThemeChanged: (_) {}),
        ),
      );

      // Tap reset button
      await tester.tap(find.text(GreekStrings.resetSettings));
      await tester.pumpAndSettle();

      // Dialog opens
      expect(find.text(GreekStrings.resetSettingsConfirm), findsOneWidget);

      // Confirm reset
      await tester.tap(find.text(GreekStrings.confirm));
      await tester.pumpAndSettle();
    });

    testWidgets('Duration presets exist and no automatic timer is exposed', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: SettingsScreen(storage: storage, onThemeChanged: (_) {}),
        ),
      );

      // Verify NO auto / difficulty-based timer options exist
      expect(find.textContaining('Αυτόματ'), findsNothing);
      expect(find.textContaining('δυσκολίας'), findsNothing);
      expect(find.textContaining('Auto'), findsNothing);

      // Verify presets 30, 45, 60, 90, 120, 180 δευτ. are present
      expect(find.text('30 ${GreekStrings.seconds}'), findsOneWidget);
      expect(find.text('45 ${GreekStrings.seconds}'), findsOneWidget);
      expect(find.text('60 ${GreekStrings.seconds}'), findsOneWidget);
      expect(find.text('90 ${GreekStrings.seconds}'), findsOneWidget);
      expect(find.text('120 ${GreekStrings.seconds}'), findsOneWidget);
      expect(find.text('180 ${GreekStrings.seconds}'), findsOneWidget);

      // Select 180 seconds (180 δευτ.)
      await tester.tap(find.text('180 ${GreekStrings.seconds}'));
      await tester.pumpAndSettle();

      expect(storage.defaultRoundDuration, 180);

      // Select 90 seconds
      await tester.tap(find.text('90 ${GreekStrings.seconds}'));
      await tester.pumpAndSettle();

      expect(storage.defaultRoundDuration, 90);
    });
  });
}
