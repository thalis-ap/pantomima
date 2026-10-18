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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
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
                  ? Container(
                      key: const ValueKey('paused'),
                      constraints: const BoxConstraints(minHeight: 180),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pause_circle_filled_rounded,
                            size: 64,
                            color: AppColors.primaryViolet.withValues(
                              alpha: 0.8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            GreekStrings.pause,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      key: ValueKey(phrase?.id ?? 'empty'),
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 180),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Difficulty badge & word count tag
                          if (phrase != null)
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 10,
                              runSpacing: 6,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${phrase!.wordCount} λέξεις',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 22),
                          // Phrase text
                          Text(
                            phrase?.text ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize:
                                  (phrase != null && phrase!.wordCount > 5)
                                  ? 26
                                  : 30,
                              fontWeight: FontWeight.w900,
                              height: 1.35,
                              letterSpacing: 0.3,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1B1433),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            // Top-right streak indicator pill
            if (showStreak)
              Positioned(top: 0, right: 0, child: _buildStreakPill()),
          ],
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
