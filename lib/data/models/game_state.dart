import 'game_configuration.dart';
import 'game_enums.dart';
import 'phrase.dart';
import 'streak_calculator.dart';
import 'team.dart';

/// Immutable snapshot of the current game state
class GameState {
  final GamePhase phase;
  final GameConfiguration config;
  final Phrase? currentPhrase;
  final int currentTeamIndex;
  final int currentRound;
  final List<Team> teams;
  final int remainingSeconds;
  final int totalDurationSeconds;
  final int freePlayStreak;
  final int? lastBonusAwarded;
  final String? errorMessage;

  const GameState({
    required this.phase,
    required this.config,
    this.currentPhrase,
    this.currentTeamIndex = 0,
    this.currentRound = 1,
    this.teams = const [],
    this.remainingSeconds = 60,
    this.totalDurationSeconds = 60,
    this.freePlayStreak = 0,
    this.lastBonusAwarded,
    this.errorMessage,
  });

  /// The active streak count for whichever mode is running
  int get currentStreak => (config.mode == GameMode.team)
      ? (activeTeam?.streak ?? 0)
      : freePlayStreak;

  /// Bonus available on the NEXT correct answer given current streak
  int get nextStreakBonus => StreakCalculator.nextAvailableBonus(currentStreak);

  Team? get activeTeam {
    if (teams.isEmpty ||
        currentTeamIndex < 0 ||
        currentTeamIndex >= teams.length) {
      return null;
    }
    return teams[currentTeamIndex];
  }

  /// Calculates the leading team(s)
  List<Team> get leaders {
    if (teams.isEmpty) return [];
    int maxScore = teams.map((t) => t.score).reduce((a, b) => a > b ? a : b);
    return teams.where((t) => t.score == maxScore).toList();
  }

  bool get isTie {
    final l = leaders;
    return l.length > 1;
  }

  /// Sorted copy of teams from highest score to lowest
  List<Team> get rankedTeams {
    final sorted = List<Team>.from(teams);
    sorted.sort((a, b) => b.score.compareTo(a.score));
    return sorted;
  }

  /// Monotonic progress ratio (1.0 = full time remaining, 0.0 = expired)
  double get timerProgress {
    if (totalDurationSeconds <= 0) return 0.0;
    return (remainingSeconds / totalDurationSeconds).clamp(0.0, 1.0);
  }

  int get totalRounds => config.totalRounds;

  /// Human-readable round progress string (e.g. "Γύρος 2 από 5")
  String get roundProgressText => 'Γύρος $currentRound από $totalRounds';

  GameState copyWith({
    GamePhase? phase,
    GameConfiguration? config,
    Phrase? currentPhrase,
    int? currentTeamIndex,
    int? currentRound,
    List<Team>? teams,
    int? remainingSeconds,
    int? totalDurationSeconds,
    int? freePlayStreak,
    int? lastBonusAwarded,
    bool clearLastBonusAwarded = false,
    String? errorMessage,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      config: config ?? this.config,
      currentPhrase: currentPhrase ?? this.currentPhrase,
      currentTeamIndex: currentTeamIndex ?? this.currentTeamIndex,
      currentRound: currentRound ?? this.currentRound,
      teams: teams ?? this.teams,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      freePlayStreak: freePlayStreak ?? this.freePlayStreak,
      lastBonusAwarded: clearLastBonusAwarded
          ? null
          : (lastBonusAwarded ?? this.lastBonusAwarded),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
