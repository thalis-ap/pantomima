import 'package:flutter/material.dart';
import '../../../core/localization/greek_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/phrase.dart';
import '../../../data/models/streak_calculator.dart';
import '../../../shared/widgets/glass_card.dart';

/// Central card prominently displaying the Greek pantomime phrase
class PhraseCard extends StatelessWidget {
  final Phrase? phrase;
  final bool isPaused;
  final int streak;
  final bool isStreakBonusEnabled;

  const PhraseCard({
    super.key,
    required this.phrase,
    this.isPaused = false,
    this.streak = 0,
    this.isStreakBonusEnabled = true,
  });

  static const double kDifficultyRowHeight = 50.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final diffColor = phrase?.difficulty.color ?? AppColors.primaryViolet;
    final showStreak =
        isStreakBonusEnabled && streak > 0 && !isPaused && phrase != null;

    return Semantics(
      label:
          '${GreekStrings.phraseSemantic}: ${phrase?.text ?? ""}, ${GreekStrings.difficultySemantic}: ${phrase?.difficulty.nameEl ?? ""}',
      child: GlassCard(
        borderRadius: 28,
        padding: EdgeInsets.zero,
        gradient: isDark
            ? LinearGradient(
                colors: [
                  AppColors.darkCard,
                  diffColor.withValues(alpha: 0.12),
                  AppColors.darkSurface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        child: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [...previousChildren, ?currentChild],
                  );
                },
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.94,
                        end: 1.0,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: isPaused
                    ? Center(
                        key: const ValueKey('paused'),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pause_circle_filled_rounded,
                              size: 56,
                              color: AppColors.primaryViolet.withValues(
                                alpha: 0.8,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              GreekStrings.pause,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        key: ValueKey(phrase?.id ?? 'empty'),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (phrase != null) ...[
                            // 1. Fixed-height top row: Difficulty
                            SizedBox(
                              height: kDifficultyRowHeight,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: diffColor.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: diffColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    '${phrase!.difficulty.nameEl} • +${phrase!.difficulty.points} π.',
                                    style: TextStyle(
                                      color: diffColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Subtle divider between difficulty and remaining content
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.black.withValues(alpha: 0.08),
                            ),
                          ],
                          // 2. Expanded central area: Word count placed right above the phrase with small padding
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: phrase == null
                                  ? const SizedBox.shrink()
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Word count badge right above the phrase
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.12,
                                                  )
                                                : Colors.black.withValues(
                                                    alpha: 0.07,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: isDark
                                                  ? Colors.white.withValues(
                                                      alpha: 0.20,
                                                    )
                                                  : Colors.black.withValues(
                                                      alpha: 0.12,
                                                    ),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            '${phrase!.wordCount} λέξεις',
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.white.withValues(
                                                      alpha: 0.95,
                                                    )
                                                  : const Color(0xFF1B1433),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        // Phrase text directly beneath word count
                                        Flexible(
                                          child: LayoutBuilder(
                                            builder: (context, constraints) {
                                              return FittedBox(
                                                fit: BoxFit.scaleDown,
                                                alignment: Alignment.center,
                                                child: ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    maxWidth:
                                                        constraints.maxWidth,
                                                    maxHeight:
                                                        constraints.maxHeight,
                                                  ),
                                                  child: Text(
                                                    phrase!.text,
                                                    textAlign: TextAlign.center,
                                                    softWrap: true,
                                                    style: TextStyle(
                                                      fontSize:
                                                          (phrase!.wordCount >
                                                              5)
                                                          ? 26
                                                          : 30,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      height: 1.35,
                                                      letterSpacing: 0.3,
                                                      color: isDark
                                                          ? Colors.white
                                                          : const Color(
                                                              0xFF1B1433,
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
              ),
              // Top-right streak indicator pill
              if (showStreak)
                Positioned(top: 8, right: 12, child: _buildStreakPill()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakPill() {
    final bonus = StreakCalculator.calculateBonus(streak);
    final text = bonus > 0 ? '🔥 $streak  +$bonus' : '🔥 $streak';

    return Container(
      key: const ValueKey('streak_indicator'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF97316).withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF9800).withValues(alpha: 0.55),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 13,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
