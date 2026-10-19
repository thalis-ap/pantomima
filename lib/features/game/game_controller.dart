import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../data/models/game_configuration.dart';
import '../../data/models/game_enums.dart';
import '../../data/models/game_state.dart';
import '../../data/models/phrase.dart';
import '../../data/models/streak_calculator.dart';
import '../../data/models/team.dart';
import '../../data/repositories/phrase_repository.dart';
import '../../services/audio_service.dart';
import '../../services/haptics_service.dart';
import '../../services/storage_service.dart';

/// GameController manages game rules, turn rotation, scoring, and monotonic countdown
class GameController extends ChangeNotifier {
  final PhraseRepository phraseRepository;
  final AudioService? audioService;
  final HapticsService? hapticsService;
  final StorageService? storageService;
  final DateTime Function() _nowProvider;

  GameState _state;
  Timer? _timer;
  DateTime? _roundStartedAt;
  int _elapsedBeforePause = 0;
  bool _expirationTriggered = false;
  bool _actionLocked = false;
  String? _currentlyScoredPhraseId;
  int _roundPointsEarned = 0;

  GameController({
    required this.phraseRepository,
    this.audioService,
    this.hapticsService,
    this.storageService,
    DateTime Function()? nowProvider,
    GameConfiguration? initialConfig,
  }) : _nowProvider = nowProvider ?? DateTime.now,
       _state = GameState(
         phase: GamePhase.ready,
         config:
             initialConfig ?? const GameConfiguration(mode: GameMode.freePlay),
         teams: initialConfig?.teams ?? [],
       );

  bool get isStreakBonusEnabled => storageService?.streakBonusEnabled ?? true;

  GameState get state => _state;
  GamePhase get phase => _state.phase;
  Phrase? get currentPhrase => _state.currentPhrase;
  int get remainingSeconds => _state.remainingSeconds;
  int get totalDurationSeconds => _state.totalDurationSeconds;
  Team? get activeTeam => _state.activeTeam;

  /// Starts a new game with the specified configuration
  void setupGame(GameConfiguration config) {
    _cancelTimer();
    _expirationTriggered = false;
    _actionLocked = false;
    _elapsedBeforePause = 0;
    _currentlyScoredPhraseId = null;
    _roundPointsEarned = 0;

    final initialTeams = config.mode == GameMode.team
        ? config.teams.map((t) => t.copyWith(score: 0, streak: 0)).toList()
        : <Team>[];

    final duration = config.roundDurationSeconds;

    _state = GameState(
      phase: GamePhase.ready,
      config: config,
      currentPhrase: null, // Pre-game hides the phrase until round starts
      currentTeamIndex: 0,
      currentRound: 1,
      teams: initialTeams,
      remainingSeconds: duration,
      totalDurationSeconds: duration,
      freePlayStreak: 0,
      lastBonusAwarded: null,
    );

    notifyListeners();
  }

  /// Starts the active round countdown
  void startRound() {
    if (_state.phase == GamePhase.running) return;

    final phrase =
        _state.currentPhrase ??
        phraseRepository.getRandomPhrase(
          allowedDifficulties: _state.config.allowedDifficulties,
        );

    final duration = _state.remainingSeconds > 0
        ? _state.remainingSeconds
        : _state.config.roundDurationSeconds;

    _expirationTriggered = false;
    _actionLocked = false;
    _roundStartedAt = _nowProvider();
    _elapsedBeforePause = _state.totalDurationSeconds - duration;

    _state = _state.copyWith(
      phase: GamePhase.running,
      currentPhrase: phrase,
      remainingSeconds: duration,
      totalDurationSeconds: _state.totalDurationSeconds > 0
          ? _state.totalDurationSeconds
          : duration,
    );

    _startTimer();
    notifyListeners();
  }

  /// Pauses the countdown safely preserving elapsed time
  void pauseRound() {
    if (_state.phase != GamePhase.running) return;

    if (_roundStartedAt != null) {
      _elapsedBeforePause += _nowProvider()
          .difference(_roundStartedAt!)
          .inSeconds;
    }
    _cancelTimer();

    _state = _state.copyWith(phase: GamePhase.paused);
    notifyListeners();
  }

  /// Resumes the paused round
  void resumeRound() {
    if (_state.phase != GamePhase.paused) return;

    _roundStartedAt = _nowProvider();
    _state = _state.copyWith(phase: GamePhase.running);
    _startTimer();
    notifyListeners();
  }

  /// Monotonic countdown ticker
  void _startTimer() {
    _cancelTimer();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      _onTimerTick();
    });
  }

  void _onTimerTick() {
    _actionLocked = false;
    if (_state.phase != GamePhase.running || _roundStartedAt == null) return;

    final elapsed =
        _elapsedBeforePause +
        _nowProvider().difference(_roundStartedAt!).inSeconds;
    final remaining = max(0, _state.totalDurationSeconds - elapsed);

    if (remaining != _state.remainingSeconds) {
      // Audio tick during final 5 seconds
      if (remaining >= 1 && remaining <= 5) {
        audioService?.playTick();
        hapticsService?.timeWarning();
      }

      _state = _state.copyWith(remainingSeconds: remaining);
      notifyListeners();
    }

    if (remaining <= 0) {
      _handleExpiration();
    }
  }

  @visibleForTesting
  void tickForTesting() {
    _actionLocked = false;
    _onTimerTick();
  }

  /// Handles timer expiration exactly once
  void _handleExpiration() {
    if (_expirationTriggered) return;
    _expirationTriggered = true;
    _cancelTimer();

    audioService?.playBuzzer();
    hapticsService?.timeUp();

    // A timeout resets the streak to zero
    List<Team> updatedTeams = _state.teams;
    if (_state.config.mode == GameMode.team && _state.teams.isNotEmpty) {
      final activeIdx = _state.currentTeamIndex;
      final currentTeam = _state.teams[activeIdx];
      final updatedTeam = currentTeam.copyWith(streak: 0);
      updatedTeams = List<Team>.from(_state.teams);
      updatedTeams[activeIdx] = updatedTeam;
    }

    _state = _state.copyWith(
      phase: GamePhase.roundExpired,
      teams: updatedTeams,
      remainingSeconds: 0,
      freePlayStreak: 0,
      clearLastBonusAwarded: true,
    );
    notifyListeners();
  }

  @visibleForTesting
  void handleExpirationForTesting() {
    _handleExpiration();
  }

  /// Handles correct answer («Σωστό») atomically with difficulty-based scoring and streak bonus
  void markCorrect() {
    if (_actionLocked ||
        _state.phase != GamePhase.running ||
        _state.remainingSeconds <= 0) {
      return;
    }

    final phraseToScore = _state.currentPhrase;
    // A phrase must never award points twice
    if (phraseToScore == null || _currentlyScoredPhraseId == phraseToScore.id) {
      return;
    }

    _actionLocked = true;
    _currentlyScoredPhraseId = phraseToScore.id;

    audioService?.playCorrect();
    hapticsService?.success();

    int bonusAwarded = 0;
    List<Team> updatedTeams = _state.teams;
    int newFreePlayStreak = _state.freePlayStreak;

    if (_state.config.mode == GameMode.team && _state.teams.isNotEmpty) {
      final activeIdx = _state.currentTeamIndex;
      final currentTeam = _state.teams[activeIdx];
      final newStreak = currentTeam.streak + 1;
      final isEnabled = isStreakBonusEnabled;
      bonusAwarded = isEnabled ? StreakCalculator.calculateBonus(newStreak) : 0;
      final basePoints = phraseToScore.difficulty.points;
      final totalPoints = basePoints + bonusAwarded;
      _roundPointsEarned += totalPoints;
      final updatedTeam = currentTeam.copyWith(
        score: currentTeam.score + totalPoints,
        streak: newStreak,
      );

      updatedTeams = List<Team>.from(_state.teams);
      updatedTeams[activeIdx] = updatedTeam;
    } else {
      newFreePlayStreak = _state.freePlayStreak + 1;
      if (isStreakBonusEnabled) {
        bonusAwarded = StreakCalculator.calculateBonus(newFreePlayStreak);
      }
    }

    // Fetch next phrase without repeating current
    final nextPhrase = phraseRepository.getRandomPhrase(
      allowedDifficulties: _state.config.allowedDifficulties,
      currentPhrase: phraseToScore,
    );

    _state = _state.copyWith(
      teams: updatedTeams,
      currentPhrase: nextPhrase,
      freePlayStreak: newFreePlayStreak,
      lastBonusAwarded: bonusAwarded,
    );

    notifyListeners();
  }

  /// Handles pass action («Πάσο»): awards zero points and resets streak
  void markPass() {
    if (_actionLocked ||
        _state.phase != GamePhase.running ||
        _state.remainingSeconds <= 0) {
      return;
    }

    _actionLocked = true;
    _currentlyScoredPhraseId = null;

    audioService?.playPass();
    hapticsService?.pass();

    // Skipped phrase awards zero points and resets the streak to zero
    List<Team> updatedTeams = _state.teams;
    if (_state.config.mode == GameMode.team && _state.teams.isNotEmpty) {
      final activeIdx = _state.currentTeamIndex;
      final currentTeam = _state.teams[activeIdx];
      final updatedTeam = currentTeam.copyWith(streak: 0);

      updatedTeams = List<Team>.from(_state.teams);
      updatedTeams[activeIdx] = updatedTeam;
    }

    // Fetch next phrase without repeating current (no points awarded)
    final nextPhrase = phraseRepository.getRandomPhrase(
      allowedDifficulties: _state.config.allowedDifficulties,
      currentPhrase: _state.currentPhrase,
    );

    _state = _state.copyWith(
      teams: updatedTeams,
      currentPhrase: nextPhrase,
      freePlayStreak: 0,
      clearLastBonusAwarded: true,
    );

    notifyListeners();
  }

  /// Advances from round summary or expiration to the next team's turn
  void advanceToNextTurn() {
    _cancelTimer();
    _expirationTriggered = false;
    _actionLocked = false;
    _elapsedBeforePause = 0;

    if (_state.config.mode == GameMode.team && _state.teams.isNotEmpty) {
      final isLastTeamInRound =
          _state.currentTeamIndex == _state.teams.length - 1;

      // Check if all configured rounds have been completed
      if (isLastTeamInRound &&
          _state.currentRound >= _state.config.totalRounds) {
        finishGame();
        return;
      }

      final nextIdx = (_state.currentTeamIndex + 1) % _state.teams.length;
      final nextRound = isLastTeamInRound
          ? _state.currentRound + 1
          : _state.currentRound;

      final duration = _state.config.roundDurationSeconds;
      _roundPointsEarned = 0;

      _state = _state.copyWith(
        phase: GamePhase.ready,
        currentTeamIndex: nextIdx,
        currentRound: nextRound,
        currentPhrase: null, // Keep phrase hidden until user starts round
        remainingSeconds: duration,
        totalDurationSeconds: duration,
      );
    } else {
      // Free play reset for next turn
      final duration = _state.config.roundDurationSeconds;

      _state = _state.copyWith(
        phase: GamePhase.ready,
        currentPhrase: null,
        remainingSeconds: duration,
        totalDurationSeconds: duration,
      );
    }

    notifyListeners();
  }

  /// Starts a fresh Free Play attempt with a new phrase and reset timer
  void startNextFreePlayTurn() {
    _cancelTimer();
    _expirationTriggered = false;
    _actionLocked = false;
    _elapsedBeforePause = 0;

    final nextPhrase = phraseRepository.getRandomPhrase(
      allowedDifficulties: _state.config.allowedDifficulties,
      currentPhrase: _state.currentPhrase,
    );

    final duration = _state.config.roundDurationSeconds;
    _roundStartedAt = _nowProvider();

    _state = _state.copyWith(
      phase: GamePhase.running,
      currentPhrase: nextPhrase,
      remainingSeconds: duration,
      totalDurationSeconds: duration,
      freePlayStreak: 0,
      clearLastBonusAwarded: true,
    );

    _startTimer();
    notifyListeners();
  }

  /// Free play next phrase action
  void nextFreePlayPhrase() {
    final duration = _state.config.roundDurationSeconds;

    _cancelTimer();
    _expirationTriggered = false;
    _actionLocked = false;
    _elapsedBeforePause = 0;

    _state = _state.copyWith(
      phase: GamePhase.ready,
      currentPhrase: null,
      remainingSeconds: duration,
      totalDurationSeconds: duration,
    );

    notifyListeners();
  }

  /// Safely finishes team game session and navigates to final results
  void finishGame() {
    _cancelTimer();
    _state = _state.copyWith(phase: GamePhase.gameFinished);
    notifyListeners();
  }

  /// Safely completes a free play session without team scores or winner evaluation
  void endFreePlay() {
    _cancelTimer();
    _expirationTriggered = true;
    _actionLocked = true;
    _state = _state.copyWith(phase: GamePhase.ready, remainingSeconds: 0);
    notifyListeners();
  }

  /// Safely restarts current game
  void restartGame() {
    setupGame(_state.config);
  }

  /// Resets the current round's countdown to the configured duration and resumes in a fresh playable state
  void resetRound() {
    _cancelTimer();
    _expirationTriggered = false;
    _actionLocked = false;
    _elapsedBeforePause = 0;
    _currentlyScoredPhraseId = null;

    final duration = _state.config.roundDurationSeconds;
    final samePhrase =
        _state.currentPhrase ??
        phraseRepository.getRandomPhrase(
          allowedDifficulties: _state.config.allowedDifficulties,
        );

    List<Team> updatedTeams = _state.teams;
    if (_state.config.mode == GameMode.team && _state.teams.isNotEmpty) {
      final activeIdx = _state.currentTeamIndex;
      final currentTeam = _state.teams[activeIdx];
      final updatedTeam = currentTeam.copyWith(
        score: max(0, currentTeam.score - _roundPointsEarned),
        streak: 0,
      );
      updatedTeams = List<Team>.from(_state.teams);
      updatedTeams[activeIdx] = updatedTeam;
    }
    _roundPointsEarned = 0;

    _roundStartedAt = _nowProvider();

    _state = _state.copyWith(
      phase: GamePhase.running,
      teams: updatedTeams,
      currentPhrase: samePhrase,
      remainingSeconds: duration,
      totalDurationSeconds: duration,
      freePlayStreak: 0,
      clearLastBonusAwarded: true,
    );

    _startTimer();
    notifyListeners();
  }

  /// Responds to app backgrounding
  void onAppPaused() {
    if (_state.phase == GamePhase.running) {
      pauseRound();
    }
  }

  /// Responds to app resuming
  void onAppResumed() {
    // Keep paused state so user is in control of when to resume
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}
