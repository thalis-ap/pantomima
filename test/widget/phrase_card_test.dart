import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantomima/data/models/game_enums.dart';
import 'package:pantomima/data/models/phrase.dart';
import 'package:pantomima/features/game/widgets/phrase_card.dart';

void main() {
  group('PhraseCard Widget Tests', () {
    const testPhrase = Phrase(
      id: 'p1',
      text: 'Ο παππούς χορεύει συρτάκι στην παραλία',
      difficulty: DifficultyCategory.easy,
      wordCount: 6,
      isNonsense: false,
    );

    testWidgets('Hidden streak indicator when streak is 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PhraseCard(
              phrase: testPhrase,
              streak: 0,
              isStreakBonusEnabled: true,
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('streak_indicator')), findsNothing);
      expect(
        find.text('Ο παππούς χορεύει συρτάκι στην παραλία'),
        findsOneWidget,
      );
    });

    testWidgets('Hidden streak indicator when streak bonus is disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PhraseCard(
              phrase: testPhrase,
              streak: 4,
              isStreakBonusEnabled: false,
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('streak_indicator')), findsNothing);
    });

    testWidgets('Hidden streak indicator when paused', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PhraseCard(
              phrase: testPhrase,
              streak: 3,
              isStreakBonusEnabled: true,
              isPaused: true,
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('streak_indicator')), findsNothing);
    });

    testWidgets('Renders correct streak format on phrase card', (tester) async {
      Future<void> pumpWithStreak(int streak) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PhraseCard(
                phrase: testPhrase,
                streak: streak,
                isStreakBonusEnabled: true,
              ),
            ),
          ),
        );
      }

      await pumpWithStreak(1);
      expect(find.byKey(const ValueKey('streak_indicator')), findsOneWidget);
      expect(find.text('🔥 1'), findsOneWidget);

      await pumpWithStreak(2);
      expect(find.text('🔥 2'), findsOneWidget);

      await pumpWithStreak(3);
      expect(find.text('🔥 3  +1'), findsOneWidget);

      await pumpWithStreak(4);
      expect(find.text('🔥 4  +2'), findsOneWidget);

      await pumpWithStreak(5);
      expect(find.text('🔥 5  +3'), findsOneWidget);

      await pumpWithStreak(8);
      expect(find.text('🔥 8  +3'), findsOneWidget);
    });

    testWidgets(
      'Does not overflow on narrow screens with long Greek phrases and streak pill',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        const longPhrase = Phrase(
          id: 'long_1',
          text:
              'Ένας αστροναύτης προσπαθεί να φάει καρπούζι χωρίς βαρύτητα μέσα στο διαστημόπλοιο',
          difficulty: DifficultyCategory.impossible,
          wordCount: 11,
          isNonsense: false,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PhraseCard(
                phrase: longPhrase,
                streak: 4,
                isStreakBonusEnabled: true,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('streak_indicator')), findsOneWidget);
        expect(find.text('🔥 4  +2'), findsOneWidget);
        expect(find.text(longPhrase.text), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Difficulty and word-count indicators remain strictly stationary when streak is hidden vs visible',
      (tester) async {
        // Pump with streak = 0 (hidden)
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PhraseCard(
                phrase: testPhrase,
                streak: 0,
                isStreakBonusEnabled: true,
              ),
            ),
          ),
        );

        final initialDiffPos = tester.getCenter(
          find.text(
            '${testPhrase.difficulty.nameEl} • +${testPhrase.difficulty.points} π.',
          ),
        );
        final initialWordCountPos = tester.getCenter(
          find.text('${testPhrase.wordCount} λέξεις'),
        );

        // Pump with streak = 3 (visible)
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PhraseCard(
                phrase: testPhrase,
                streak: 3,
                isStreakBonusEnabled: true,
              ),
            ),
          ),
        );

        final activeDiffPos = tester.getCenter(
          find.text(
            '${testPhrase.difficulty.nameEl} • +${testPhrase.difficulty.points} π.',
          ),
        );
        final activeWordCountPos = tester.getCenter(
          find.text('${testPhrase.wordCount} λέξεις'),
        );

        // Verify indicators did not shift by even a fraction of a pixel
        expect(activeDiffPos, equals(initialDiffPos));
        expect(activeWordCountPos, equals(initialWordCountPos));
      },
    );

    testWidgets('Streak badge background has translucent opacity (30-45%)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PhraseCard(
              phrase: testPhrase,
              streak: 3,
              isStreakBonusEnabled: true,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byKey(const ValueKey('streak_indicator')),
      );
      final decoration = container.decoration as BoxDecoration;
      final color = decoration.color!;
      expect(color.a, greaterThanOrEqualTo(0.30));
      expect(color.a, lessThanOrEqualTo(0.45));
    });
  });
}
