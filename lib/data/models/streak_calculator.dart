import 'dart:math';
import 'game_enums.dart';

/// Single source of truth for pantomime streak bonus calculations
class StreakCalculator {
  StreakCalculator._();

  /// Calculates bonus points awarded for reaching [streak] consecutive correct answers.
  /// 1st correct: 0 bonus
  /// 2nd correct: 0 bonus
  /// 3rd correct: +1 bonus
  /// 4th correct: +2 bonus
  /// 5th correct: +3 bonus
  /// 6th+ correct: +3 bonus (capped at 3)
  ///
  /// Formula: min(max(streak - 2, 0), 3)
  static int calculateBonus(int streak) {
    if (streak <= 2) return 0;
    return min(streak - 2, 3);
  }

  /// Calculates total points awarded for a correct guess.
  /// When [streakBonusEnabled] is true, adds the streak bonus to base difficulty points.
  static int calculateTotalPoints({
    required DifficultyCategory difficulty,
    required int streak,
    required bool streakBonusEnabled,
  }) {
    final base = difficulty.points;
    if (!streakBonusEnabled) return base;
    return base + calculateBonus(streak);
  }

  /// Returns the bonus that will be awarded on the NEXT correct answer,
  /// given the current consecutive streak.
  static int nextAvailableBonus(int currentStreak) {
    return calculateBonus(currentStreak + 1);
  }
}
