import 'package:flutter/material.dart';
import '../../core/localization/greek_strings.dart';
import '../../core/theme/app_colors.dart';

/// Available difficulty levels for pantomime phrases
enum DifficultyCategory {
  easy(
    nameEl: GreekStrings.easy,
    defaultDurationSeconds: 60,
    minWords: 3,
    maxWords: 3,
    color: AppColors.diffEasy,
    points: 1,
  ),
  medium(
    nameEl: GreekStrings.medium,
    defaultDurationSeconds: 90,
    minWords: 4,
    maxWords: 4,
    color: AppColors.diffMedium,
    points: 2,
  ),
  hard(
    nameEl: GreekStrings.hard,
    defaultDurationSeconds: 105,
    minWords: 5,
    maxWords: 5,
    color: AppColors.diffHard,
    points: 3,
  ),
  impossible(
    nameEl: GreekStrings.impossible,
    defaultDurationSeconds: 120,
    minWords: 6,
    maxWords: 8,
    color: AppColors.diffImpossible,
    points: 5,
  );

  final String nameEl;
  final int defaultDurationSeconds;
  final int minWords;
  final int maxWords;
  final Color color;
  final int points;

  const DifficultyCategory({
    required this.nameEl,
    required this.defaultDurationSeconds,
    required this.minWords,
    required this.maxWords,
    required this.color,
    required this.points,
  });

  static DifficultyCategory fromGreekName(String name) {
    switch (name.trim()) {
      case GreekStrings.easy:
        return DifficultyCategory.easy;
      case GreekStrings.medium:
        return DifficultyCategory.medium;
      case GreekStrings.hard:
        return DifficultyCategory.hard;
      case GreekStrings.impossible:
        return DifficultyCategory.impossible;
      default:
        return DifficultyCategory.medium;
    }
  }
}

/// Mode of play
enum GameMode { team, freePlay }

/// Explicit lifecycle states for the game
enum GamePhase {
  initializing,
  ready,
  running,
  paused,
  roundExpired,
  roundSummary,
  gameFinished,
  recoverableError,
}
