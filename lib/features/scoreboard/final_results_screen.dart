import 'package:flutter/material.dart';
import '../../core/localization/greek_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/team.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/greek_button.dart';

/// Screen displayed when a team game concludes
class FinalResultsScreen extends StatelessWidget {
  final List<Team> teams;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  const FinalResultsScreen({
    super.key,
    required this.teams,
    required this.onPlayAgain,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sorted = List<Team>.from(teams)
      ..sort((a, b) => b.score.compareTo(a.score));
    final maxScore = sorted.isNotEmpty ? sorted.first.score : 0;
    final winners = sorted.where((t) => t.score == maxScore).toList();
    final isTie = winners.length > 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text(GreekStrings.finalResults),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Trophy Icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.passAmber.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 52,
                ),
              ),
              const SizedBox(height: 20),
              // Winner announcement
              Text(
                isTie ? GreekStrings.tie : GreekStrings.winnerIs,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isTie
                    ? winners.map((w) => w.name).join(' & ')
                    : (winners.isNotEmpty ? winners.first.name : ''),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryViolet,
                ),
              ),
              const SizedBox(height: 24),
              // Detailed Score List
              Expanded(
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: ListView.separated(
                    itemCount: sorted.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final team = sorted[index];
                      final isWinner = winners.contains(team);

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isWinner
                              ? AppColors.primaryViolet.withValues(alpha: 0.18)
                              : (isDark
                                    ? AppColors.darkSurface
                                    : AppColors.lightCard),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isWinner
                                ? AppColors.primaryViolet
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: team.color,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                team.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: isWinner
                                      ? FontWeight.w900
                                      : FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '${team.score} πόντοι',
                              style: TextStyle(
                                color: team.color,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Action Buttons
              GreekButton(
                text: GreekStrings.playAgain,
                icon: Icons.replay_rounded,
                gradient: AppColors.primaryGradient,
                onPressed: onPlayAgain,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onHome,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  GreekStrings.home,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
