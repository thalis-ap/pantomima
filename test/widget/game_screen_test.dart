import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantomima/core/localization/greek_strings.dart';
import 'package:pantomima/data/models/game_configuration.dart';
import 'package:pantomima/data/models/game_enums.dart';
import 'package:pantomima/data/models/phrase.dart';
import 'package:pantomima/data/models/team.dart';
import 'package:pantomima/data/repositories/phrase_repository.dart';
import 'package:pantomima/features/game/game_controller.dart';
import 'package:pantomima/features/game/game_screen.dart';
import 'package:pantomima/features/game/widgets/phrase_card.dart';
import 'package:pantomima/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GameScreen Widget Tests', () {
    late PhraseRepository repository;
    late GameController controller;

    setUp(() {
      repository = PhraseRepository(random: Random(42));
      repository.loadFromPhrases([
        const Phrase(
          id: 'p1',
          text: 'Ο παππούς χορεύει',
          difficulty: DifficultyCategory.easy,
          wordCount: 3,
          isNonsense: false,
        ),
        const Phrase(
          id: 'p2',
          text: 'Η γιαγιά γελάει',
          difficulty: DifficultyCategory.easy,
          wordCount: 3,
          isNonsense: false,
        ),
      ]);

      controller = GameController(phraseRepository: repository);
      controller.setupGame(
        const GameConfiguration(
          mode: GameMode.team,
          teams: [
            Team(id: 't1', name: 'Ομάδα 1', score: 0, color: Colors.purple),
            Team(id: 't2', name: 'Ομάδα 2', score: 0, color: Colors.cyan),
          ],
          customDurationSeconds: 60,
        ),
      );
    });

    testWidgets(
      'Renders instruction message, active team, and start button in ready state with phrase hidden',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: GameScreen(controller: controller, onExit: () {}),
          ),
        );

        // Verify active team header
        expect(
          find.text('${GreekStrings.activeTeamPrefix} Ομάδα 1'),
          findsOneWidget,
        );

        // Verify initial round status button
        expect(find.text('Έναρξη Γύρου'), findsOneWidget);

        // Verify pre-game instruction message is shown
        expect(
          find.text('«${GreekStrings.preGameInstruction}»'),
          findsOneWidget,
        );

        // Verify phrase is hidden before starting round
        expect(find.text('Ο παππούς χορεύει'), findsNothing);
      },
    );

    testWidgets('Starting round reveals correct and pass buttons', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(controller: controller, onExit: () {}),
        ),
      );

      // Tap start round
      await tester.tap(find.text('Έναρξη Γύρου'));
      await tester.pump();

      // Verify controls
      expect(find.text(GreekStrings.correct), findsOneWidget);
      expect(find.text(GreekStrings.pass), findsOneWidget);
      expect(find.text(GreekStrings.pause), findsOneWidget);

      // Tap correct
      await tester.tap(find.text(GreekStrings.correct));
      await tester.pump();

      // Score should now be 1
      expect(find.text('${GreekStrings.scoreLabel} 1'), findsOneWidget);

      controller.pauseRound();
    });

    testWidgets('Shows exit confirmation dialog when back button is pressed', (
      tester,
    ) async {
      bool exitConfirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            controller: controller,
            onExit: () => exitConfirmed = true,
          ),
        ),
      );

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      // Dialog appears
      expect(find.text(GreekStrings.exitConfirmationTitle), findsOneWidget);
      expect(find.text(GreekStrings.exitConfirmationContent), findsOneWidget);

      // Tap exit button
      await tester.tap(find.text(GreekStrings.exitGame));
      await tester.pumpAndSettle();

      expect(exitConfirmed, isTrue);
    });

    testWidgets(
      'Shows early finish confirmation dialog when flag button is pressed and preserves scores',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: GameScreen(controller: controller, onExit: () {}),
          ),
        );

        // Tap early finish button in AppBar
        await tester.tap(find.byIcon(Icons.flag_circle_outlined));
        await tester.pumpAndSettle();

        // Early finish confirmation dialog appears
        expect(
          find.text(GreekStrings.earlyEndConfirmationTitle),
          findsOneWidget,
        );
        expect(
          find.text(GreekStrings.earlyEndConfirmationContent),
          findsOneWidget,
        );

        // Tap confirm early end
        await tester.tap(find.text(GreekStrings.earlyEndAction));
        await tester.pumpAndSettle();

        // Final results screen is displayed
        expect(find.text(GreekStrings.finalResults), findsOneWidget);
      },
    );

    testWidgets(
      'Free play timeout shows dedicated end-of-time screen with next phrase and end actions',
      (tester) async {
        int exitCallCount = 0;
        final freePlayController = GameController(phraseRepository: repository);
        freePlayController.setupGame(
          const GameConfiguration(
            mode: GameMode.freePlay,
            roundDurationSeconds: 60,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: GameScreen(
              controller: freePlayController,
              onExit: () => exitCallCount++,
            ),
          ),
        );

        // Pre-game: No next phrase button
        expect(find.text(GreekStrings.nextPhrase), findsNothing);
        expect(find.text('Έναρξη Γύρου'), findsOneWidget);

        // Start round
        await tester.tap(find.text('Έναρξη Γύρου'));
        await tester.pump();

        // Trigger timeout directly via handleExpirationForTesting
        freePlayController.handleExpirationForTesting();
        await tester.pumpAndSettle();

        // Verify it did NOT abruptly auto-exit
        expect(exitCallCount, 0);

        // Verify dedicated Greek end-of-time screen
        expect(find.text(GreekStrings.freePlayTimeUpTitle), findsOneWidget);
        expect(find.text(GreekStrings.freePlayTimeUpSubtitle), findsOneWidget);
        expect(find.text(GreekStrings.nextPhrase), findsOneWidget);
        expect(find.text(GreekStrings.endFreePlayAction), findsOneWidget);

        // Verify NO winner announcement, NO winner screen, NO team standings
        expect(find.text(GreekStrings.finalResults), findsNothing);
        expect(find.text(GreekStrings.winnerIs), findsNothing);
        expect(find.text(GreekStrings.tie), findsNothing);
        expect(find.text(GreekStrings.standingsTitle), findsNothing);

        // Choosing next phrase starts a fresh attempt with a new phrase and reset timer
        await tester.tap(find.text(GreekStrings.nextPhrase));
        await tester.pumpAndSettle();
        expect(freePlayController.phase, GamePhase.running);
        expect(exitCallCount, 0);

        // Expire again
        freePlayController.handleExpirationForTesting();
        await tester.pumpAndSettle();

        // Choosing end game action returns to home screen
        await tester.tap(find.text(GreekStrings.endFreePlayAction));
        await tester.pumpAndSettle();
        expect(exitCallCount, 1);

        // Verify duplicate events do not call onExit again
        freePlayController.endFreePlay();
        await tester.pumpAndSettle();
        expect(exitCallCount, 1);
      },
    );

    testWidgets(
      'Free play early end confirms exit and returns without winner',
      (tester) async {
        int exitCallCount = 0;
        final freePlayController = GameController(phraseRepository: repository);
        freePlayController.setupGame(
          const GameConfiguration(
            mode: GameMode.freePlay,
            roundDurationSeconds: 60,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: GameScreen(
              controller: freePlayController,
              onExit: () => exitCallCount++,
            ),
          ),
        );

        // Tap early finish button in AppBar
        await tester.tap(find.byIcon(Icons.flag_circle_outlined));
        await tester.pumpAndSettle();

        // In free play, shows exit confirmation
        expect(find.text(GreekStrings.exitConfirmationTitle), findsOneWidget);

        // Confirm exit
        await tester.tap(find.text(GreekStrings.exitGame));
        await tester.pumpAndSettle();

        expect(exitCallCount, 1);
        // Verify no winner screen
        expect(find.text(GreekStrings.finalResults), findsNothing);
        expect(find.text(GreekStrings.winnerIs), findsNothing);
      },
    );

    testWidgets('Active game screen shows streak indicator on phrase card', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'streak_bonus_enabled': true});
      final storage = await StorageService.create();

      final streakController = GameController(
        phraseRepository: repository,
        storageService: storage,
      );
      addTearDown(streakController.dispose);

      streakController.setupGame(
        const GameConfiguration(
          mode: GameMode.team,
          teams: [
            Team(id: 't1', name: 'Ομάδα Α', score: 0, color: Colors.purple),
          ],
          roundDurationSeconds: 60,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(controller: streakController, onExit: () {}),
        ),
      );

      // Pre-game: streak indicator is hidden
      expect(find.byKey(const ValueKey('streak_indicator')), findsNothing);

      // Start round
      await tester.tap(find.text('Έναρξη Γύρου'));
      await tester.pump();

      // Streak 0: indicator is hidden
      expect(find.byKey(const ValueKey('streak_indicator')), findsNothing);

      // 1st correct -> streak 1 (no bonus)
      await tester.tap(find.text(GreekStrings.correct));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey('streak_indicator')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(PhraseCard),
          matching: find.byKey(const ValueKey('streak_indicator')),
        ),
        findsOneWidget,
      );
      expect(find.text('🔥 1'), findsOneWidget);

      // 2nd correct -> streak 2 (no bonus)
      await tester.tap(find.text(GreekStrings.correct));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('🔥 2'), findsOneWidget);

      // 3rd correct -> streak 3 (+1 bonus)
      await tester.tap(find.text(GreekStrings.correct));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('🔥 3  +1'), findsOneWidget);

      // 4th correct -> streak 4 (+2 bonus)
      await tester.tap(find.text(GreekStrings.correct));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('🔥 4  +2'), findsOneWidget);

      // 5th correct -> streak 5 (+3 bonus)
      await tester.tap(find.text(GreekStrings.correct));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('🔥 5  +3'), findsOneWidget);

      // 6th correct -> streak 6 (+3 capped)
      await tester.tap(find.text(GreekStrings.correct));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('🔥 6  +3'), findsOneWidget);

      // Skip (Pass) resets streak to 0, hiding indicator
      await tester.tap(find.text(GreekStrings.pass));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey('streak_indicator')), findsNothing);

      // Clean up timer before test completes
      streakController.finishGame();
      await tester.pumpAndSettle();
    });
  });
}
