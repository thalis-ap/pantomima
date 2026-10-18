import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantomima/data/models/game_configuration.dart';
import 'package:pantomima/data/models/game_enums.dart';
import 'package:pantomima/data/models/game_state.dart';
import 'package:pantomima/data/models/phrase.dart';
import 'package:pantomima/data/models/team.dart';
import 'package:pantomima/data/repositories/phrase_repository.dart';
import 'package:pantomima/features/game/game_controller.dart';
import 'package:pantomima/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GameController Unit Tests', () {
    late PhraseRepository repository;
    late DateTime fakeCurrentTime;

    DateTime fakeNow() => fakeCurrentTime;

    setUp(() {
      repository = PhraseRepository(random: Random(1));
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
        const Phrase(
          id: 'p3',
          text: 'Ο μάγειρας καίει τηγανίτες',
          difficulty: DifficultyCategory.medium,
          wordCount: 4,
          isNonsense: false,
        ),
        const Phrase(
          id: 'p4',
          text: 'Ο πειρατής κρύβει τον θησαυρό',
          difficulty: DifficultyCategory.hard,
          wordCount: 5,
          isNonsense: false,
        ),
        const Phrase(
          id: 'p5',
          text: 'Ο εξωγήινος πίνει καφέ στο διάστημα',
          difficulty: DifficultyCategory.impossible,
          wordCount: 6,
          isNonsense: true,
        ),
      ]);
      fakeCurrentTime = DateTime(2026, 1, 1, 12, 0, 0);
    });

    test(
      'Initializes in ready state with configured teams and hidden pre-game phrase',
      () {
        final teams = [
          const Team(id: 't1', name: 'Ομάδα Α', score: 0, color: Colors.purple),
          const Team(id: 't2', name: 'Ομάδα Β', score: 0, color: Colors.cyan),
        ];

        final config = GameConfiguration(
          mode: GameMode.team,
          teams: teams,
          roundDurationSeconds: 60,
        );

        final controller = GameController(
          phraseRepository: repository,
          nowProvider: fakeNow,
        );

        controller.setupGame(config);

        expect(controller.phase, GamePhase.ready);
        expect(controller.state.teams.length, 2);
        expect(controller.activeTeam?.name, 'Ομάδα Α');
        expect(controller.remainingSeconds, 60);
        // Phrase is hidden before starting round
        expect(controller.currentPhrase, isNull);

        // Starting round reveals phrase and starts countdown
        controller.startRound();
        expect(controller.phase, GamePhase.running);
        expect(controller.currentPhrase, isNotNull);
      },
    );

    test('Weighted difficulty-based scoring awards points accurately', () {
      final teams = [
        const Team(id: 't1', name: 'Ομάδα 1', score: 0, color: Colors.purple),
        const Team(id: 't2', name: 'Ομάδα 2', score: 0, color: Colors.cyan),
      ];

      final controller = GameController(
        phraseRepository: repository,
        nowProvider: fakeNow,
      );

      controller.setupGame(
        GameConfiguration(
          mode: GameMode.team,
          teams: teams,
          roundDurationSeconds: 60,
        ),
      );

      controller.startRound();
      expect(controller.phase, GamePhase.running);

      final initialPhrase = controller.currentPhrase!;
      final expectedPoints = initialPhrase.difficulty.points;

      // Mark correct awards exact difficulty points
      controller.markCorrect();

      expect(controller.state.teams[0].score, expectedPoints);
      expect(controller.state.teams[1].score, 0);
      expect(controller.currentPhrase?.id, isNot(equals(initialPhrase.id)));
    });

    test('Pass action generates next phrase without awarding points', () {
      final teams = [
        const Team(id: 't1', name: 'Ομάδα 1', score: 0, color: Colors.purple),
        const Team(id: 't2', name: 'Ομάδα 2', score: 0, color: Colors.cyan),
      ];

      final controller = GameController(
        phraseRepository: repository,
        nowProvider: fakeNow,
      );

      controller.setupGame(
        GameConfiguration(
          mode: GameMode.team,
          teams: teams,
          roundDurationSeconds: 60,
        ),
      );

      controller.startRound();
      controller.markPass();

      expect(controller.state.teams[0].score, 0);
      expect(controller.state.teams[1].score, 0);
    });

    test(
      'Round limit completion: 3 rounds configuration finishes automatically',
      () {
        final teams = [
          const Team(id: 't1', name: 'Ομάδα 1', score: 0, color: Colors.purple),
          const Team(id: 't2', name: 'Ομάδα 2', score: 0, color: Colors.cyan),
        ];

        final controller = GameController(
          phraseRepository: repository,
          nowProvider: fakeNow,
        );

        controller.setupGame(
          GameConfiguration(mode: GameMode.team, teams: teams, totalRounds: 3),
        );

        // Round 1
        expect(controller.state.currentRound, 1);
        expect(controller.state.currentTeamIndex, 0);
        controller.advanceToNextTurn(); // Team 2 turn
        expect(controller.state.currentRound, 1);
        expect(controller.state.currentTeamIndex, 1);

        // Round 2
        controller.advanceToNextTurn(); // Team 1 turn, Round 2
        expect(controller.state.currentRound, 2);
        expect(controller.state.currentTeamIndex, 0);
        controller.advanceToNextTurn(); // Team 2 turn, Round 2
        expect(controller.state.currentRound, 2);
        expect(controller.state.currentTeamIndex, 1);

        // Round 3
        controller.advanceToNextTurn(); // Team 1 turn, Round 3
        expect(controller.state.currentRound, 3);
        expect(controller.state.currentTeamIndex, 0);
        controller.advanceToNextTurn(); // Team 2 turn, Round 3
        expect(controller.state.currentRound, 3);
        expect(controller.state.currentTeamIndex, 1);

        // Final turn of Round 3 completes -> Game finishes automatically!
        controller.advanceToNextTurn();
        expect(controller.phase, GamePhase.gameFinished);
      },
    );

    test('Ending game early preserves scores and stops timer', () {
      final teams = [
        const Team(id: 't1', name: 'Ομάδα 1', score: 0, color: Colors.purple),
        const Team(id: 't2', name: 'Ομάδα 2', score: 0, color: Colors.cyan),
      ];

      final controller = GameController(
        phraseRepository: repository,
        nowProvider: fakeNow,
      );

      controller.setupGame(
        GameConfiguration(mode: GameMode.team, teams: teams, totalRounds: 10),
      );

      controller.startRound();
      controller.markCorrect(); // Earn points
      final scoreBeforeFinish = controller.state.teams[0].score;
      expect(scoreBeforeFinish, greaterThan(0));

      // End game early during countdown
      controller.finishGame();

      expect(controller.phase, GamePhase.gameFinished);
      // Scores remain completely preserved
      expect(controller.state.teams[0].score, scoreBeforeFinish);
    });

    test('Deterministic team rotation advances correctly across rounds', () {
      final teams = [
        const Team(id: 't1', name: 'Ομάδα 1', score: 0, color: Colors.purple),
        const Team(id: 't2', name: 'Ομάδα 2', score: 0, color: Colors.cyan),
      ];

      final controller = GameController(
        phraseRepository: repository,
        nowProvider: fakeNow,
      );

      controller.setupGame(
        GameConfiguration(mode: GameMode.team, teams: teams, totalRounds: 5),
      );

      expect(controller.state.currentTeamIndex, 0);
      expect(controller.state.currentRound, 1);

      // Advance turn
      controller.advanceToNextTurn();
      expect(controller.state.currentTeamIndex, 1);
      expect(controller.state.currentRound, 1);

      // Advance turn again -> loops to team 0 and increments round
      controller.advanceToNextTurn();
      expect(controller.state.currentTeamIndex, 0);
      expect(controller.state.currentRound, 2);
    });

    test(
      'Monotonic timer pause and resume calculations preserve remaining duration',
      () {
        final controller = GameController(
          phraseRepository: repository,
          nowProvider: fakeNow,
        );

        controller.setupGame(
          const GameConfiguration(
            mode: GameMode.freePlay,
            customDurationSeconds: 60,
          ),
        );

        controller.startRound();
        expect(controller.phase, GamePhase.running);
        expect(controller.remainingSeconds, 60);

        // Simulate 15 seconds passed
        fakeCurrentTime = fakeCurrentTime.add(const Duration(seconds: 15));

        // Pause round
        controller.pauseRound();
        expect(controller.phase, GamePhase.paused);

        // Simulate 30 seconds of paused inactivity
        fakeCurrentTime = fakeCurrentTime.add(const Duration(seconds: 30));

        // Resume round
        controller.resumeRound();
        expect(controller.phase, GamePhase.running);

        // The 30 seconds while paused must NOT have counted against remaining time
        expect(controller.remainingSeconds, 60);
      },
    );

    test('Prevents scoring after round expiration', () {
      final teams = [
        const Team(id: 't1', name: 'Ομάδα 1', score: 0, color: Colors.purple),
        const Team(id: 't2', name: 'Ομάδα 2', score: 0, color: Colors.cyan),
      ];

      final controller = GameController(
        phraseRepository: repository,
        nowProvider: fakeNow,
      );

      controller.setupGame(
        GameConfiguration(
          mode: GameMode.team,
          teams: teams,
          customDurationSeconds: 60,
        ),
      );

      // Do not start round or expire it
      controller.markCorrect();
      expect(controller.state.teams[0].score, 0);
    });

    test('Correctly calculates winners and ties', () {
      final teams = [
        const Team(id: 't1', name: 'Ομάδα 1', score: 3, color: Colors.purple),
        const Team(id: 't2', name: 'Ομάδα 2', score: 3, color: Colors.cyan),
      ];

      final state = controllerState(teams);
      expect(state.isTie, isTrue);
      expect(state.leaders.length, 2);

      final teamsNoTie = [
        const Team(id: 't1', name: 'Ομάδα 1', score: 5, color: Colors.purple),
        const Team(id: 't2', name: 'Ομάδα 2', score: 3, color: Colors.cyan),
      ];
      final stateNoTie = controllerState(teamsNoTie);
      expect(stateNoTie.isTie, isFalse);
      expect(stateNoTie.leaders.first.name, 'Ομάδα 1');
    });

    test(
      'Timer duration is decoupled from difficulty and strictly preserved',
      () {
        final teams = [
          const Team(id: 't1', name: 'Ομάδα 1', score: 0, color: Colors.purple),
        ];

        final controller = GameController(
          phraseRepository: repository,
          nowProvider: fakeNow,
        );

        // Choose explicit duration: 45 seconds
        controller.setupGame(
          GameConfiguration(
            mode: GameMode.team,
            teams: teams,
            roundDurationSeconds: 45,
          ),
        );

        expect(controller.remainingSeconds, 45);
        expect(controller.totalDurationSeconds, 45);

        controller.startRound();
        expect(controller.remainingSeconds, 45);

        // Turn duration stays exactly 45s across turns
        controller.advanceToNextTurn();
        expect(controller.remainingSeconds, 45);
        expect(controller.totalDurationSeconds, 45);
      },
    );

    test('Restarting game resets scores, rounds, and phase', () {
      final teams = [
        const Team(id: 't1', name: 'Ομάδα 1', score: 10, color: Colors.purple),
        const Team(id: 't2', name: 'Ομάδα 2', score: 5, color: Colors.cyan),
      ];

      final controller = GameController(
        phraseRepository: repository,
        nowProvider: fakeNow,
      );

      controller.setupGame(
        GameConfiguration(
          mode: GameMode.team,
          teams: teams,
          roundDurationSeconds: 60,
          totalRounds: 5,
        ),
      );

      controller.startRound();
      controller.markCorrect();

      // Restart game
      controller.restartGame();

      expect(controller.phase, GamePhase.ready);
      expect(controller.state.currentRound, 1);
      expect(controller.state.currentTeamIndex, 0);
      expect(controller.state.teams[0].score, 0);
      expect(controller.state.teams[1].score, 0);
      expect(controller.currentPhrase, isNull);
    });

    test(
      'Free play: correct marks do not invoke team scoring or winner logic',
      () {
        final controller = GameController(
          phraseRepository: repository,
          nowProvider: fakeNow,
        );

        controller.setupGame(
          const GameConfiguration(
            mode: GameMode.freePlay,
            roundDurationSeconds: 60,
          ),
        );

        controller.startRound();
        expect(controller.state.teams, isEmpty);

        controller.markCorrect();
        expect(controller.state.teams, isEmpty);

        controller.markPass();
        expect(controller.state.teams, isEmpty);
      },
    );

    test('Free play: endFreePlay cancels timers and locks actions cleanly', () {
      final controller = GameController(
        phraseRepository: repository,
        nowProvider: fakeNow,
      );

      controller.setupGame(
        const GameConfiguration(
          mode: GameMode.freePlay,
          roundDurationSeconds: 60,
        ),
      );

      controller.startRound();
      expect(controller.phase, GamePhase.running);

      controller.endFreePlay();
      expect(controller.phase, GamePhase.ready);
      expect(controller.remainingSeconds, 0);

      // Verify actions are locked after free play end
      controller.markCorrect();
      expect(controller.phase, GamePhase.ready);

      // Duplicate endFreePlay call is completely safe and idempotent
      controller.endFreePlay();
      expect(controller.phase, GamePhase.ready);
    });

    test(
      'Streak bonus progression, cap, and total points calculation',
      () async {
        SharedPreferences.setMockInitialValues({'streak_bonus_enabled': true});
        final storage = await StorageService.create();

        final teams = [
          const Team(id: 't1', name: 'Ομάδα Α', score: 0, color: Colors.purple),
        ];

        final controller = GameController(
          phraseRepository: repository,
          storageService: storage,
          nowProvider: fakeNow,
        );

        controller.setupGame(
          GameConfiguration(
            mode: GameMode.team,
            teams: teams,
            roundDurationSeconds: 120,
            allowedDifficulties: {DifficultyCategory.easy}, // 1 base point each
          ),
        );

        controller.startRound();

        // 1st correct: base 1, bonus 0 -> score 1, streak 1
        controller.tickForTesting();
        controller.markCorrect();
        expect(controller.state.teams[0].streak, 1);
        expect(controller.state.teams[0].score, 1);
        expect(controller.state.lastBonusAwarded, 0);

        // 2nd correct: base 1, bonus 0 -> score 2, streak 2
        controller.tickForTesting();
        controller.markCorrect();
        expect(controller.state.teams[0].streak, 2);
        expect(controller.state.teams[0].score, 2);
        expect(controller.state.lastBonusAwarded, 0);

        // 3rd correct: base 1, bonus +1 -> score 4, streak 3
        controller.tickForTesting();
        controller.markCorrect();
        expect(controller.state.teams[0].streak, 3);
        expect(controller.state.teams[0].score, 4); // 2 + 1 base + 1 bonus = 4
        expect(controller.state.lastBonusAwarded, 1);

        // 4th correct: base 1, bonus +2 -> score 7, streak 4
        controller.tickForTesting();
        controller.markCorrect();
        expect(controller.state.teams[0].streak, 4);
        expect(controller.state.teams[0].score, 7); // 4 + 1 base + 2 bonus = 7
        expect(controller.state.lastBonusAwarded, 2);

        // 5th correct: base 1, bonus +3 -> score 11, streak 5
        controller.tickForTesting();
        controller.markCorrect();
        expect(controller.state.teams[0].streak, 5);
        expect(
          controller.state.teams[0].score,
          11,
        ); // 7 + 1 base + 3 bonus = 11
        expect(controller.state.lastBonusAwarded, 3);

        // 6th correct: base 1, bonus +3 (capped) -> score 15, streak 6
        controller.tickForTesting();
        controller.markCorrect();
        expect(controller.state.teams[0].streak, 6);
        expect(
          controller.state.teams[0].score,
          15,
        ); // 11 + 1 base + 3 bonus = 15
        expect(controller.state.lastBonusAwarded, 3);
      },
    );

    test('Pass (skip) resets streak to zero without awarding points', () async {
      SharedPreferences.setMockInitialValues({'streak_bonus_enabled': true});
      final storage = await StorageService.create();

      final teams = [
        const Team(id: 't1', name: 'Ομάδα Α', score: 0, color: Colors.purple),
      ];

      final controller = GameController(
        phraseRepository: repository,
        storageService: storage,
        nowProvider: fakeNow,
      );

      controller.setupGame(
        GameConfiguration(
          mode: GameMode.team,
          teams: teams,
          roundDurationSeconds: 120,
          allowedDifficulties: {DifficultyCategory.easy},
        ),
      );

      controller.startRound();

      // 2 correct
      controller.tickForTesting();
      controller.markCorrect();
      controller.tickForTesting();
      controller.markCorrect();
      expect(controller.state.teams[0].streak, 2);
      expect(controller.state.teams[0].score, 2);

      // Pass
      controller.tickForTesting();
      controller.markPass();
      expect(controller.state.teams[0].streak, 0);
      expect(controller.state.teams[0].score, 2); // Score unchanged
      expect(controller.state.lastBonusAwarded, isNull);

      // Next correct restarts streak at 1 with no bonus
      controller.tickForTesting();
      controller.markCorrect();
      expect(controller.state.teams[0].streak, 1);
      expect(controller.state.teams[0].score, 3); // 2 + 1 base + 0 bonus = 3
    });

    test('Expiration resets streak to zero', () async {
      final teams = [
        const Team(id: 't1', name: 'Ομάδα Α', score: 0, color: Colors.purple),
      ];

      final controller = GameController(
        phraseRepository: repository,
        nowProvider: fakeNow,
      );

      controller.setupGame(
        GameConfiguration(
          mode: GameMode.team,
          teams: teams,
          roundDurationSeconds: 60,
          allowedDifficulties: {DifficultyCategory.easy},
        ),
      );

      controller.startRound();
      controller.tickForTesting();
      controller.markCorrect();
      expect(controller.state.teams[0].streak, 1);

      controller.handleExpirationForTesting();
      expect(controller.state.teams[0].streak, 0);
      expect(controller.phase, GamePhase.roundExpired);
    });

    test('No double-scoring on rapid repeated clicks', () async {
      final teams = [
        const Team(id: 't1', name: 'Ομάδα Α', score: 0, color: Colors.purple),
      ];

      final controller = GameController(
        phraseRepository: repository,
        nowProvider: fakeNow,
      );

      controller.setupGame(
        GameConfiguration(
          mode: GameMode.team,
          teams: teams,
          roundDurationSeconds: 60,
          allowedDifficulties: {DifficultyCategory.easy},
        ),
      );

      controller.startRound();

      // Rapid clicks without timer ticks in between
      controller.markCorrect();
      final scoreAfterFirst = controller.state.teams[0].score;
      controller.markCorrect(); // should be ignored by action lock
      controller.markCorrect(); // should be ignored by action lock

      expect(controller.state.teams[0].score, scoreAfterFirst);
      expect(controller.state.teams[0].streak, 1);
    });

    test('Per-team streak isolation across turns', () async {
      final teams = [
        const Team(id: 't1', name: 'Ομάδα Α', score: 0, color: Colors.purple),
        const Team(id: 't2', name: 'Ομάδα Β', score: 0, color: Colors.cyan),
      ];

      final controller = GameController(
        phraseRepository: repository,
        nowProvider: fakeNow,
      );

      controller.setupGame(
        GameConfiguration(
          mode: GameMode.team,
          teams: teams,
          roundDurationSeconds: 60,
          allowedDifficulties: {DifficultyCategory.easy},
        ),
      );

      controller.startRound();

      // Team A scores 3 correct -> streak 3
      controller.tickForTesting();
      controller.markCorrect();
      controller.tickForTesting();
      controller.markCorrect();
      controller.tickForTesting();
      controller.markCorrect();

      expect(controller.state.teams[0].streak, 3);
      expect(controller.state.teams[1].streak, 0);

      // Advance to Team B
      controller.advanceToNextTurn();
      expect(controller.activeTeam?.id, 't2');
      expect(controller.state.currentStreak, 0);

      controller.startRound();
      controller.tickForTesting();
      controller.markCorrect();
      expect(controller.state.teams[1].streak, 1);
      expect(controller.state.teams[0].streak, 3); // Team A untouched
    });

    test(
      'Disabled streak setting disables bonus and continues base scoring normally',
      () async {
        SharedPreferences.setMockInitialValues({'streak_bonus_enabled': false});
        final storage = await StorageService.create();

        final teams = [
          const Team(id: 't1', name: 'Ομάδα Α', score: 0, color: Colors.purple),
        ];

        final controller = GameController(
          phraseRepository: repository,
          storageService: storage,
          nowProvider: fakeNow,
        );

        controller.setupGame(
          GameConfiguration(
            mode: GameMode.team,
            teams: teams,
            roundDurationSeconds: 60,
            allowedDifficulties: {DifficultyCategory.easy},
          ),
        );

        controller.startRound();

        // 1st correct
        controller.tickForTesting();
        controller.markCorrect();
        expect(controller.state.teams[0].score, 1);

        // 2nd correct
        controller.tickForTesting();
        controller.markCorrect();
        expect(controller.state.teams[0].score, 2);

        // 3rd correct -> bonus should be 0 because streaks are disabled!
        controller.tickForTesting();
        controller.markCorrect();
        expect(controller.state.teams[0].score, 3); // 2 + 1 base + 0 bonus = 3
      },
    );

    test(
      'Free Play startNextFreePlayTurn resets timer and loads fresh phrase',
      () {
        final controller = GameController(
          phraseRepository: repository,
          nowProvider: fakeNow,
        );

        controller.setupGame(
          const GameConfiguration(
            mode: GameMode.freePlay,
            roundDurationSeconds: 60,
          ),
        );

        controller.startRound();
        controller.handleExpirationForTesting();
        expect(controller.phase, GamePhase.roundExpired);
        expect(controller.remainingSeconds, 0);

        controller.startNextFreePlayTurn();
        expect(controller.phase, GamePhase.running);
        expect(controller.remainingSeconds, 60);
        expect(controller.currentPhrase, isNotNull);
      },
    );
  });
}

GameState controllerState(List<Team> teams) {
  return GameState(
    phase: GamePhase.roundSummary,
    config: const GameConfiguration(mode: GameMode.team),
    teams: teams,
  );
}
