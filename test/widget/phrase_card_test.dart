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

    testWidgets(
      'Difficulty row is inside card top row and stationary between short and long phrases',
      (tester) async {
        const shortPhrase = Phrase(
          id: 'short_1',
          text: 'Γάτα',
          difficulty: DifficultyCategory.easy,
          wordCount: 1,
          isNonsense: false,
        );

        const longPhrase = Phrase(
          id: 'long_1',
          text:
              'Ένας αστροναύτης προσπαθεί να φάει καρπούζι χωρίς βαρύτητα μέσα στο διαστημόπλοιο',
          difficulty: DifficultyCategory.easy,
          wordCount: 11,
          isNonsense: false,
        );

        // 1. Pump short phrase
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PhraseCard(
                phrase: shortPhrase,
                streak: 0,
                isStreakBonusEnabled: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final cardFinder = find.byType(PhraseCard);
        final cardTop = tester.getTopLeft(cardFinder).dy;

        final diffTextFinderShort = find.text(
          '${shortPhrase.difficulty.nameEl} • +${shortPhrase.difficulty.points} π.',
        );
        final wordCountFinderShort = find.text('1 λέξεις');

        final diffPosShort = tester.getCenter(diffTextFinderShort);
        final diffSizeShort = tester.getSize(diffTextFinderShort);
        final wordCountSizeShort = tester.getSize(wordCountFinderShort);

        // Verify difficulty is at the top inside the card
        expect(
          diffPosShort.dy - cardTop,
          lessThanOrEqualTo(PhraseCard.kDifficultyRowHeight),
        );
        // Verify subtle divider exists
        expect(find.byType(Divider), findsOneWidget);

        // Verify word count is right above phrase with small padding
        final wordCountBottomShort = tester
            .getBottomLeft(wordCountFinderShort)
            .dy;
        final phraseTopShort = tester
            .getTopLeft(find.text(shortPhrase.text))
            .dy;
        final distanceToPhraseShort = phraseTopShort - wordCountBottomShort;
        expect(distanceToPhraseShort, lessThanOrEqualTo(20));
        expect(distanceToPhraseShort, greaterThan(0));

        // Verify word count is closer to the phrase than to the divider/difficulty
        final dividerBottom = tester.getBottomLeft(find.byType(Divider)).dy;
        final distanceToDividerShort =
            tester.getTopLeft(wordCountFinderShort).dy - dividerBottom;
        expect(distanceToPhraseShort, lessThan(distanceToDividerShort));

        // 2. Pump long phrase
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PhraseCard(
                phrase: longPhrase,
                streak: 0,
                isStreakBonusEnabled: false,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final diffTextFinderLong = find.text(
          '${longPhrase.difficulty.nameEl} • +${longPhrase.difficulty.points} π.',
        );
        final wordCountFinderLong = find.text('11 λέξεις');

        final diffPosLong = tester.getCenter(diffTextFinderLong);
        final diffSizeLong = tester.getSize(diffTextFinderLong);
        final wordCountSizeLong = tester.getSize(wordCountFinderLong);

        // Difficulty position & size are strictly unchanged
        expect(diffPosLong, equals(diffPosShort));
        expect(diffSizeLong, equals(diffSizeShort));

        // Word count height is strictly preserved
        expect(wordCountSizeLong.height, equals(wordCountSizeShort.height));

        // Word count remains right above long phrase with small padding
        final wordCountBottomLong = tester
            .getBottomLeft(wordCountFinderLong)
            .dy;
        final phraseTopLong = tester.getTopLeft(find.text(longPhrase.text)).dy;
        final distanceToPhraseLong = phraseTopLong - wordCountBottomLong;
        expect(distanceToPhraseLong, lessThanOrEqualTo(20));
        expect(distanceToPhraseLong, greaterThan(0));

        // Phrase text is displayed without overflow
        expect(find.text(longPhrase.text), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Difficulty badge is at top-left and streak is at top-right without overlap in top row',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PhraseCard(
                phrase: testPhrase,
                streak: 4,
                isStreakBonusEnabled: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final cardFinder = find.byType(PhraseCard);
        final cardRect = tester.getRect(cardFinder);

        final diffFinder = find.text(
          '${testPhrase.difficulty.nameEl} • +${testPhrase.difficulty.points} π.',
        );
        final streakFinder = find.byKey(const ValueKey('streak_indicator'));

        final diffRect = tester.getRect(diffFinder);
        final streakRect = tester.getRect(streakFinder);

        // Both inside top row
        expect(
          diffRect.top - cardRect.top,
          lessThanOrEqualTo(PhraseCard.kDifficultyRowHeight),
        );
        expect(
          streakRect.top - cardRect.top,
          lessThanOrEqualTo(PhraseCard.kDifficultyRowHeight),
        );

        // Difficulty is on the left side of the card
        expect(diffRect.center.dx, lessThan(cardRect.center.dx));

        // Streak is on the right side of the card
        expect(streakRect.center.dx, greaterThan(cardRect.center.dx));

        // Verify no overlap: difficulty right edge is to the left of streak left edge
        expect(diffRect.right, lessThan(streakRect.left));

        // Verify vertical alignment in same row
        expect(diffRect.center.dy, closeTo(streakRect.center.dy, 4.0));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Difficulty card is visibly larger and wider than streak card and never clips points on narrow screens',
      (tester) async {
        // Test on narrow phone screen (320px width)
        tester.view.physicalSize = const Size(320, 600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        const impossiblePhrase = Phrase(
          id: 'p_impossible',
          text: 'Μια πάρα πολύ δύσκολη φράση για παντομίμα',
          difficulty: DifficultyCategory.impossible,
          wordCount: 7,
          isNonsense: false,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: PhraseCard(
                phrase: impossiblePhrase,
                streak: 5,
                isStreakBonusEnabled: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final diffCardFinder = find.byKey(const ValueKey('difficulty_card'));
        final streakFinder = find.byKey(const ValueKey('streak_indicator'));

        expect(diffCardFinder, findsOneWidget);
        expect(streakFinder, findsOneWidget);

        final diffCardSize = tester.getSize(diffCardFinder);
        final streakSize = tester.getSize(streakFinder);

        // Difficulty card must be visibly wider and larger than streak card
        expect(
          diffCardSize.width,
          greaterThan(streakSize.width * 1.3),
          reason:
              'Difficulty card should be visibly wider than the compact streak card',
        );
        expect(
          diffCardSize.height,
          greaterThanOrEqualTo(streakSize.height),
          reason: 'Difficulty card should not be shorter than streak card',
        );

        // Verify points label and number are rendered
        expect(find.text('Ακατόρθωτο • +5 π.'), findsOneWidget);

        final diffCardRect = tester.getRect(diffCardFinder);
        final streakRect = tester.getRect(streakFinder);

        // Verify top-left vs top-right alignment
        expect(diffCardRect.left, lessThan(streakRect.left));
        expect(diffCardRect.right, lessThan(streakRect.left));

        // Zero exceptions / zero render overflows
        expect(tester.takeException(), isNull);
      },
    );
  });
}
