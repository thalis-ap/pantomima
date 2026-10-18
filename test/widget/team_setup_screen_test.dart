import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantomima/core/localization/greek_strings.dart';
import 'package:pantomima/data/models/game_configuration.dart';
import 'package:pantomima/features/setup/team_setup_screen.dart';

void main() {
  group('TeamSetupScreen Widget Tests', () {
    testWidgets('Renders setup fields and validates minimum 2 teams', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      GameConfiguration? startedConfig;

      await tester.pumpWidget(
        MaterialApp(
          home: TeamSetupScreen(
            onStartGame: (config) => startedConfig = config,
          ),
        ),
      );

      // Verify title & initial 2 teams
      expect(find.text(GreekStrings.setupTitle), findsOneWidget);
      expect(find.text(GreekStrings.teamsSection), findsOneWidget);
      expect(find.text('Ομάδες'), findsOneWidget);
      expect(find.textContaining('Τουλάχιστον 2'), findsNothing);
      expect(find.textContaining('τουλάχιστον 2'), findsNothing);
      expect(find.text('${GreekStrings.defaultTeamPrefix} 1'), findsOneWidget);
      expect(find.text('${GreekStrings.defaultTeamPrefix} 2'), findsOneWidget);

      // Add a third team
      await tester.tap(find.text(GreekStrings.addTeam));
      await tester.pumpAndSettle();

      expect(find.text('${GreekStrings.defaultTeamPrefix} 3'), findsOneWidget);

      // Start game
      await tester.tap(find.text(GreekStrings.startGame));
      await tester.pumpAndSettle();

      expect(startedConfig, isNotNull);
      expect(startedConfig!.teams.length, 3);
      expect(
        startedConfig!.teams[0].name,
        '${GreekStrings.defaultTeamPrefix} 1',
      );
    });

    testWidgets('Validates empty and duplicate team names', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(home: TeamSetupScreen(onStartGame: (_) {})),
      );

      // Clear first team name
      final firstInput = find.byType(TextField).first;
      await tester.enterText(firstInput, '');
      await tester.pumpAndSettle();

      // Tap start
      await tester.tap(find.text(GreekStrings.startGame));
      await tester.pumpAndSettle();

      expect(find.text(GreekStrings.emptyTeamNameError), findsOneWidget);

      // Enter duplicate name
      await tester.enterText(firstInput, '${GreekStrings.defaultTeamPrefix} 2');
      await tester.pumpAndSettle();

      await tester.tap(find.text(GreekStrings.startGame));
      await tester.pumpAndSettle();

      expect(find.text(GreekStrings.duplicateTeamNameError), findsOneWidget);
    });

    testWidgets('Does not overflow horizontally on narrow screen (320px)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(home: TeamSetupScreen(onStartGame: (_) {})),
      );
      await tester.pumpAndSettle();

      // Verify "Προσθήκη Ομάδας" button is visible and does not throw RenderFlex overflow
      expect(find.text(GreekStrings.addTeam), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Configures rounds and duration correctly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      GameConfiguration? startedConfig;

      await tester.pumpWidget(
        MaterialApp(
          home: TeamSetupScreen(
            onStartGame: (config) => startedConfig = config,
          ),
        ),
      );

      // Select 10 rounds
      await tester.tap(find.text(GreekStrings.roundsOption10));
      await tester.pumpAndSettle();

      // Select 180s duration
      await tester.tap(find.text('180 ${GreekStrings.seconds}'));
      await tester.pumpAndSettle();

      // Start game
      await tester.tap(find.text(GreekStrings.startGame));
      await tester.pumpAndSettle();

      expect(startedConfig, isNotNull);
      expect(startedConfig!.totalRounds, 10);
      expect(startedConfig!.roundDurationSeconds, 180);
    });
    testWidgets('Defaults to 60 seconds when unmodified', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      GameConfiguration? startedConfig;

      await tester.pumpWidget(
        MaterialApp(
          home: TeamSetupScreen(
            onStartGame: (config) => startedConfig = config,
          ),
        ),
      );

      // Verify no automatic timer UI exists
      expect(find.textContaining('Αυτόματ'), findsNothing);
      expect(find.textContaining('Auto'), findsNothing);
      expect(find.textContaining('δυσκολίας'), findsNothing);

      // Start game immediately without modifying duration
      await tester.tap(find.text(GreekStrings.startGame));
      await tester.pumpAndSettle();

      expect(startedConfig, isNotNull);
      expect(startedConfig!.roundDurationSeconds, 60);
    });

    testWidgets('Difficulty change does not alter chosen duration', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      GameConfiguration? startedConfig;

      await tester.pumpWidget(
        MaterialApp(
          home: TeamSetupScreen(
            onStartGame: (config) => startedConfig = config,
          ),
        ),
      );

      // Select 90 seconds
      await tester.tap(find.text('90 ${GreekStrings.seconds}'));
      await tester.pumpAndSettle();

      // Tap difficulty chip if available
      final easyChip = find.text(GreekStrings.easy);
      if (easyChip.evaluate().isNotEmpty) {
        await tester.tap(easyChip);
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text(GreekStrings.startGame));
      await tester.pumpAndSettle();

      expect(startedConfig, isNotNull);
      expect(startedConfig!.roundDurationSeconds, 90);
    });
  });
}
