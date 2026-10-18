import 'game_enums.dart';
import 'team.dart';

/// Configuration for a pantomime game session
class GameConfiguration {
  final GameMode mode;
  final List<Team> teams;
  final int roundDurationSeconds;
  final int totalRounds;
  final Set<DifficultyCategory> allowedDifficulties;

  const GameConfiguration({
    required this.mode,
    this.teams = const [],
    int roundDurationSeconds = 60,
    this.totalRounds = 5,
    this.allowedDifficulties = const {
      DifficultyCategory.easy,
      DifficultyCategory.medium,
      DifficultyCategory.hard,
      DifficultyCategory.impossible,
    },
    int? customDurationSeconds,
  }) : roundDurationSeconds = customDurationSeconds ?? roundDurationSeconds;

  int? get customDurationSeconds => roundDurationSeconds;

  /// Duration for each round turn (independent of difficulty)
  int getDurationForCategory([DifficultyCategory? category]) {
    return roundDurationSeconds;
  }

  GameConfiguration copyWith({
    GameMode? mode,
    List<Team>? teams,
    int? roundDurationSeconds,
    int? totalRounds,
    int? customDurationSeconds,
    Set<DifficultyCategory>? allowedDifficulties,
  }) {
    return GameConfiguration(
      mode: mode ?? this.mode,
      teams: teams ?? this.teams,
      roundDurationSeconds:
          roundDurationSeconds ??
          customDurationSeconds ??
          this.roundDurationSeconds,
      totalRounds: totalRounds ?? this.totalRounds,
      allowedDifficulties: allowedDifficulties ?? this.allowedDifficulties,
    );
  }
}
