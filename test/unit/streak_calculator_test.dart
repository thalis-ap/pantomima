import 'package:flutter_test/flutter_test.dart';
import 'package:pantomima/data/models/game_enums.dart';
import 'package:pantomima/data/models/streak_calculator.dart';

void main() {
  group('StreakCalculator Unit Tests', () {
    test('Streak bonus progression and cap', () {
      // 0 or negative
      expect(StreakCalculator.calculateBonus(-1), 0);
      expect(StreakCalculator.calculateBonus(0), 0);

      // 1st consecutive correct: no bonus
      expect(StreakCalculator.calculateBonus(1), 0);

      // 2nd consecutive correct: no bonus
      expect(StreakCalculator.calculateBonus(2), 0);

      // 3rd consecutive correct: +1 bonus
      expect(StreakCalculator.calculateBonus(3), 1);

      // 4th consecutive correct: +2 bonus
      expect(StreakCalculator.calculateBonus(4), 2);

      // 5th consecutive correct: +3 bonus
      expect(StreakCalculator.calculateBonus(5), 3);

      // 6th and subsequent: cap at +3
      expect(StreakCalculator.calculateBonus(6), 3);
      expect(StreakCalculator.calculateBonus(7), 3);
      expect(StreakCalculator.calculateBonus(10), 3);
      expect(StreakCalculator.calculateBonus(100), 3);
    });

    test('Total points calculation across difficulties', () {
      // Easy (1 base pt) with streak enabled
      expect(
        StreakCalculator.calculateTotalPoints(
          difficulty: DifficultyCategory.easy,
          streak: 1,
          streakBonusEnabled: true,
        ),
        1,
      );
      expect(
        StreakCalculator.calculateTotalPoints(
          difficulty: DifficultyCategory.easy,
          streak: 2,
          streakBonusEnabled: true,
        ),
        1,
      );
      expect(
        StreakCalculator.calculateTotalPoints(
          difficulty: DifficultyCategory.easy,
          streak: 3,
          streakBonusEnabled: true,
        ),
        2, // 1 + 1
      );
      expect(
        StreakCalculator.calculateTotalPoints(
          difficulty: DifficultyCategory.easy,
          streak: 4,
          streakBonusEnabled: true,
        ),
        3, // 1 + 2
      );
      expect(
        StreakCalculator.calculateTotalPoints(
          difficulty: DifficultyCategory.easy,
          streak: 5,
          streakBonusEnabled: true,
        ),
        4, // 1 + 3
      );
      expect(
        StreakCalculator.calculateTotalPoints(
          difficulty: DifficultyCategory.easy,
          streak: 6,
          streakBonusEnabled: true,
        ),
        4, // 1 + 3 (capped)
      );

      // Medium (2 base pts)
      expect(
        StreakCalculator.calculateTotalPoints(
          difficulty: DifficultyCategory.medium,
          streak: 1,
          streakBonusEnabled: true,
        ),
        2,
      );
      expect(
        StreakCalculator.calculateTotalPoints(
          difficulty: DifficultyCategory.medium,
          streak: 3,
          streakBonusEnabled: true,
        ),
        3, // 2 + 1
      );
      expect(
        StreakCalculator.calculateTotalPoints(
          difficulty: DifficultyCategory.medium,
          streak: 5,
          streakBonusEnabled: true,
        ),
        5, // 2 + 3
      );

      // Hard (3 base pts)
      expect(
        StreakCalculator.calculateTotalPoints(
          difficulty: DifficultyCategory.hard,
          streak: 3,
          streakBonusEnabled: true,
        ),
        4, // 3 + 1
      );
      expect(
        StreakCalculator.calculateTotalPoints(
          difficulty: DifficultyCategory.hard,
          streak: 5,
          streakBonusEnabled: true,
        ),
        6, // 3 + 3
      );

      // Impossible (5 base pts)
      expect(
        StreakCalculator.calculateTotalPoints(
          difficulty: DifficultyCategory.impossible,
          streak: 1,
          streakBonusEnabled: true,
        ),
        5,
      );
      expect(
        StreakCalculator.calculateTotalPoints(
          difficulty: DifficultyCategory.impossible,
          streak: 3,
          streakBonusEnabled: true,
        ),
        6, // 5 + 1
      );
      expect(
        StreakCalculator.calculateTotalPoints(
          difficulty: DifficultyCategory.impossible,
          streak: 5,
          streakBonusEnabled: true,
        ),
        8, // 5 + 3
      );

      // When streak bonus is disabled, awards ONLY base points regardless of streak
      expect(
        StreakCalculator.calculateTotalPoints(
          difficulty: DifficultyCategory.easy,
          streak: 5,
          streakBonusEnabled: false,
        ),
        1,
      );
      expect(
        StreakCalculator.calculateTotalPoints(
          difficulty: DifficultyCategory.impossible,
          streak: 5,
          streakBonusEnabled: false,
        ),
        5,
      );
    });

    test('Next available bonus progression', () {
      expect(StreakCalculator.nextAvailableBonus(0), 0); // 1st gives 0
      expect(StreakCalculator.nextAvailableBonus(1), 0); // 2nd gives 0
      expect(StreakCalculator.nextAvailableBonus(2), 1); // 3rd gives 1
      expect(StreakCalculator.nextAvailableBonus(3), 2); // 4th gives 2
      expect(StreakCalculator.nextAvailableBonus(4), 3); // 5th gives 3
      expect(StreakCalculator.nextAvailableBonus(5), 3); // 6th gives 3 (capped)
    });
  });
}
