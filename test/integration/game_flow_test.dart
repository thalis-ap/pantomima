import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantomima/app.dart';
import 'package:pantomima/core/localization/greek_strings.dart';
import 'package:pantomima/data/models/game_enums.dart';
import 'package:pantomima/data/models/phrase.dart';
import 'package:pantomima/data/repositories/phrase_repository.dart';
import 'package:pantomima/services/audio_service.dart';
import 'package:pantomima/services/haptics_service.dart';
import 'package:pantomima/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('End-to-End Game Flow Integration Tests', () {
    late PhraseRepository phraseRepository;
    late StorageService storageService;
    late AudioService audioService;
    late HapticsService hapticsService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = await StorageService.create();
      audioService = AudioService(storageService);
      hapticsService = HapticsService(storageService);

      phraseRepository = PhraseRepository(random: Random(42));
      phraseRepository.loadFromPhrases([
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
        const Phrase(
          id: 'p3',
          text: 'Ο μάγειρας καίει τηγανίτες',
          difficulty: DifficultyCategory.medium,
          wordCount: 4,
          isNonsense: false,
        ),
      ]);
    });

    testWidgets(
      'Full Team Game Flow: Home -> Setup -> Round -> Correct -> Next Turn -> Standings',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        // 1. Launch the app
        await tester.pumpWidget(
          PantomimaApp(
            phraseRepository: phraseRepository,
            storageService: storageService,
            audioService: audioService,
            hapticsService: hapticsService,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text(GreekStrings.appTitle), findsOneWidget);

        // 2. Start a team game
        await tester.tap(find.text(GreekStrings.teamGame));
        await tester.pumpAndSettle();

        expect(find.text(GreekStrings.setupTitle), findsOneWidget);

        // 3. Configure teams and start
        await tester.tap(find.text(GreekStrings.startGame));
        await tester.pumpAndSettle();

        // In game screen, ready phase
        expect(
          find.text(
            '${GreekStrings.activeTeamPrefix} ${GreekStrings.defaultTeamPrefix} 1',
          ),
          findsOneWidget,
        );

        // 4. Start a round
        await tester.tap(find.text('Έναρξη Γύρου'));
        await tester.pump();

        // 5. Mark a phrase correct
        await tester.tap(find.text(GreekStrings.correct));
        await tester.pump();

        // 6. Verify score is 1
        expect(find.text('${GreekStrings.scoreLabel} 1'), findsOneWidget);

        // 7. Pause round & open standings
        await tester.tap(find.text(GreekStrings.pause));
        await tester.pumpAndSettle();
      },
    );

    testWidgets('Full Free Play Flow: Home -> Free Play -> Next Phrase', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Launch app
      await tester.pumpWidget(
        PantomimaApp(
          phraseRepository: phraseRepository,
          storageService: storageService,
          audioService: audioService,
          hapticsService: hapticsService,
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to free play setup
      await tester.tap(find.text(GreekStrings.freePlay));
      await tester.pumpAndSettle();

      expect(find.text(GreekStrings.freePlayModeTitle), findsOneWidget);

      // Start free play from setup
      await tester.tap(find.text(GreekStrings.startGame));
      await tester.pumpAndSettle();

      // In GameScreen ready phase
      expect(find.text('Έναρξη Γύρου'), findsOneWidget);

      // Tap start round
      await tester.tap(find.text('Έναρξη Γύρου'));
      await tester.pumpAndSettle();

      // Controls visible
      expect(find.text(GreekStrings.correct), findsOneWidget);
      expect(find.text(GreekStrings.pass), findsOneWidget);
    });
  });
}
