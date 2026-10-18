import 'package:flutter/material.dart';
import '../../core/localization/greek_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/game_enums.dart';
import '../../data/models/game_state.dart';
import '../../data/models/team.dart';
import '../scoreboard/final_results_screen.dart';
import '../scoreboard/scoreboard_dialog.dart';
import 'game_controller.dart';
import 'widgets/circular_timer.dart';
import 'widgets/phrase_card.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/greek_button.dart';

/// Active game screen for Team Mode and Free Play Mode
class GameScreen extends StatefulWidget {
  final GameController controller;
  final VoidCallback onExit;

  const GameScreen({super.key, required this.controller, required this.onExit});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  bool _hasExited = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _hasExited = true;
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      widget.controller.onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      widget.controller.onAppResumed();
    }
  }

  void _onControllerUpdate() {
    if (!mounted) return;

    final state = widget.controller.state;
    // When free-play turn finishes explicitly with gameFinished:
    // Automatically return to the main screen without showing a winner or team rankings.
    if (state.config.mode == GameMode.freePlay &&
        state.phase == GamePhase.gameFinished) {
      if (!_hasExited) {
        _hasExited = true;
        // Stop the countdown completely and cancel any pending timers
        widget.controller.endFreePlay();
        // Return the user to the main screen automatically without showing a winner
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.onExit();
          }
        });
      }
      return;
    }

    setState(() {});
  }

  void _confirmExit() {
    final wasRunning = widget.controller.phase == GamePhase.running;
    if (wasRunning) {
      widget.controller.pauseRound();
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(GreekStrings.exitConfirmationTitle),
          content: const Text(GreekStrings.exitConfirmationContent),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (wasRunning) {
                  widget.controller.resumeRound();
                }
              },
              child: const Text(GreekStrings.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.alertRed,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                if (!_hasExited) {
                  _hasExited = true;
                  if (widget.controller.state.config.mode ==
                      GameMode.freePlay) {
                    widget.controller.endFreePlay();
                  }
                  widget.onExit();
                }
              },
              child: const Text(
                GreekStrings.exitGame,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmEarlyEnd() {
    final isTeamMode = widget.controller.state.config.mode == GameMode.team;
    final wasRunning = widget.controller.phase == GamePhase.running;
    if (wasRunning) {
      widget.controller.pauseRound();
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            isTeamMode
                ? GreekStrings.earlyEndConfirmationTitle
                : GreekStrings.exitConfirmationTitle,
          ),
          content: Text(
            isTeamMode
                ? GreekStrings.earlyEndConfirmationContent
                : GreekStrings.exitConfirmationContent,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (wasRunning) {
                  widget.controller.resumeRound();
                }
              },
              child: Text(
                isTeamMode ? GreekStrings.resume : GreekStrings.cancel,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.alertRed,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                if (!_hasExited) {
                  if (isTeamMode) {
                    widget.controller.finishGame();
                  } else {
                    _hasExited = true;
                    widget.controller.endFreePlay();
                    widget.onExit();
                  }
                }
              },
              child: Text(
                isTeamMode
                    ? GreekStrings.earlyEndAction
                    : GreekStrings.exitGame,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showScoreboardSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ScoreboardDialog(
          teams: widget.controller.state.teams,
          currentRound: widget.controller.state.currentRound,
          onNextRound: () {
            Navigator.pop(ctx);
            widget.controller.advanceToNextTurn();
          },
          onFinishGame: () {
            Navigator.pop(ctx);
            widget.controller.finishGame();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    final isTeamMode = state.config.mode == GameMode.team;
    final activeTeam = state.activeTeam;

    // If game has concluded, show final results screen ONLY for team mode
    if (state.phase == GamePhase.gameFinished) {
      if (isTeamMode) {
        return FinalResultsScreen(
          teams: state.teams,
          onPlayAgain: () => widget.controller.restartGame(),
          onHome: widget.onExit,
        );
      } else {
        // Free play must NEVER show a winner screen, dialog, or rankings
        return const Scaffold(body: SizedBox.shrink());
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            tooltip: GreekStrings.exitGame,
            onPressed: _confirmExit,
          ),
          title: Text(
            isTeamMode
                ? (activeTeam != null
                      ? '${GreekStrings.activeTeamPrefix} ${activeTeam.name}'
                      : GreekStrings.appTitle)
                : GreekStrings.freePlayModeTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isTeamMode && activeTeam != null ? activeTeam.color : null,
            ),
          ),
          actions: [
            if (isTeamMode)
              IconButton(
                icon: const Icon(Icons.leaderboard_rounded),
                tooltip: GreekStrings.standingsTitle,
                onPressed: _showScoreboardSheet,
              ),
            IconButton(
              icon: const Icon(Icons.flag_circle_outlined),
              tooltip: isTeamMode
                  ? GreekStrings.finishGame
                  : GreekStrings.exitGame,
              onPressed: _confirmEarlyEnd,
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                // Top status bar (Round & score in team mode)
                if (isTeamMode && activeTeam != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: activeTeam.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: activeTeam.color.withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${GreekStrings.round} ${state.currentRound} ${GreekStrings.roundOf} ${state.totalRounds}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${GreekStrings.scoreLabel} ${activeTeam.score}',
                          style: TextStyle(
                            color: activeTeam.color,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Main Gameplay or Pre-Game View
                if (state.phase == GamePhase.ready)
                  Expanded(
                    child: Center(
                      child: _buildPreGameCard(state, isTeamMode, activeTeam),
                    ),
                  )
                else if (!isTeamMode && state.phase == GamePhase.roundExpired)
                  Expanded(
                    child: Center(child: _buildFreePlayTimeUpView(state)),
                  )
                else ...[
                  // Countdown Timer widget
                  CircularTimer(
                    remainingSeconds: state.remainingSeconds,
                    totalDurationSeconds: state.totalDurationSeconds,
                    isRunning: state.phase == GamePhase.running,
                    size: 130,
                  ),

                  const SizedBox(height: 16),

                  // Central Phrase Card
                  Expanded(
                    child: Center(
                      child: PhraseCard(
                        phrase: state.currentPhrase,
                        isPaused: state.phase == GamePhase.paused,
                        streak: state.currentStreak,
                        isStreakBonusEnabled:
                            widget.controller.isStreakBonusEnabled,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Dynamic Game Controls
                if (isTeamMode || state.phase != GamePhase.roundExpired)
                  _buildActionControls(state, isTeamMode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreGameCard(GameState state, bool isTeamMode, Team? activeTeam) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isTeamMode && activeTeam != null
        ? activeTeam.color
        : AppColors.primaryViolet;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active Team / Free Play Hero Info
          if (isTeamMode && activeTeam != null) ...[
            CircleAvatar(
              radius: 34,
              backgroundColor: activeTeam.color.withValues(alpha: 0.2),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: activeTeam.color,
                child: Text(
                  '${state.currentTeamIndex + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              activeTeam.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: activeTeam.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${GreekStrings.round} ${state.currentRound} ${GreekStrings.roundOf} ${state.totalRounds}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.electricBlue.withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.flash_on_rounded,
                color: AppColors.electricBlue,
                size: 42,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              GreekStrings.freePlayModeTitle,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ],

          const SizedBox(height: 16),

          // Required Instructional Banner
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            borderRadius: 22,
            gradient: LinearGradient(
              colors: [
                accentColor.withValues(alpha: 0.16),
                AppColors.darkCard.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Color(0xFFFBBF24),
                  size: 28,
                ),
                const SizedBox(height: 10),
                Text(
                  '«${GreekStrings.preGameInstruction}»',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Configuration Overview Badges
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.timer_outlined, size: 16),
                label: Text('${state.totalDurationSeconds} δευτ.'),
                backgroundColor: isDark ? Colors.white10 : Colors.black12,
              ),
              ...state.config.allowedDifficulties.map(
                (d) => Chip(
                  label: Text('${d.nameEl} (+${d.points} π.)'),
                  labelStyle: TextStyle(
                    color: d.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  backgroundColor: d.color.withValues(alpha: 0.15),
                  side: BorderSide(color: d.color.withValues(alpha: 0.4)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionControls(GameState state, bool isTeamMode) {
    switch (state.phase) {
      case GamePhase.ready:
        return GreekButton(
          text: GreekStrings.startRound,
          icon: Icons.play_arrow_rounded,
          gradient: AppColors.primaryGradient,
          onPressed: () => widget.controller.startRound(),
        );

      case GamePhase.running:
        return Column(
          children: [
            Row(
              children: [
                // Pass button
                Expanded(
                  child: GreekButton(
                    text: GreekStrings.pass,
                    icon: Icons.skip_next_rounded,
                    gradient: AppColors.passGradient,
                    semanticLabel: GreekStrings.passButtonSemantic,
                    onPressed: () => widget.controller.markPass(),
                  ),
                ),
                const SizedBox(width: 14),
                // Correct button
                Expanded(
                  child: GreekButton(
                    text: GreekStrings.correct,
                    icon: Icons.check_circle_rounded,
                    gradient: AppColors.successGradient,
                    semanticLabel: GreekStrings.correctButtonSemantic,
                    onPressed: () => widget.controller.markCorrect(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Pause button
            TextButton.icon(
              onPressed: () => widget.controller.pauseRound(),
              icon: const Icon(Icons.pause_rounded, size: 20),
              label: const Text(GreekStrings.pause),
            ),
          ],
        );

      case GamePhase.paused:
        return GreekButton(
          text: GreekStrings.resume,
          icon: Icons.play_arrow_rounded,
          gradient: AppColors.primaryGradient,
          semanticLabel: GreekStrings.resumeButtonSemantic,
          onPressed: () => widget.controller.resumeRound(),
        );

      case GamePhase.roundExpired:
        if (!isTeamMode) {
          return const SizedBox.shrink();
        }
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.alertRed.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.alertRed, width: 1.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.alarm_off_rounded,
                    color: AppColors.alertRed,
                    size: 24,
                  ),
                  SizedBox(width: 10),
                  Text(
                    GreekStrings.timeUp,
                    style: TextStyle(
                      color: AppColors.alertRed,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GreekButton(
              text: 'Βαθμολογία & Επόμενη Ομάδα',
              icon: Icons.leaderboard_rounded,
              gradient: AppColors.primaryGradient,
              onPressed: _showScoreboardSheet,
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFreePlayTimeUpView(GameState state) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.alertRed.withValues(alpha: 0.15),
              border: Border.all(
                color: AppColors.alertRed.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.alarm_off_rounded,
              color: AppColors.alertRed,
              size: 56,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            GreekStrings.freePlayTimeUpTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            GreekStrings.freePlayTimeUpSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          if (state.currentPhrase != null) ...[
            GlassCard(
              padding: const EdgeInsets.all(20),
              borderRadius: 20,
              child: Column(
                children: [
                  const Text(
                    'Τελευταία φράση:',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white60,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.currentPhrase!.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Chip(
                    label: Text(
                      '${state.currentPhrase!.difficulty.nameEl} (+${state.currentPhrase!.difficulty.points} π.)',
                      style: TextStyle(
                        color: state.currentPhrase!.difficulty.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: state.currentPhrase!.difficulty.color
                        .withValues(alpha: 0.15),
                    side: BorderSide(
                      color: state.currentPhrase!.difficulty.color.withValues(
                        alpha: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
          GreekButton(
            text: GreekStrings.nextPhrase,
            icon: Icons.refresh_rounded,
            gradient: AppColors.primaryGradient,
            onPressed: () {
              widget.controller.startNextFreePlayTurn();
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              if (!_hasExited) {
                _hasExited = true;
                widget.controller.endFreePlay();
                widget.onExit();
              }
            },
            icon: const Icon(Icons.home_rounded),
            label: const Text(
              GreekStrings.endFreePlayAction,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
