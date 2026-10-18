import 'package:flutter/material.dart';
import '../../core/localization/greek_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/glass_card.dart';

/// Main menu screen for «Παντομίμα»
class HomeScreen extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onStartTeamGame;
  final VoidCallback onStartFreePlay;
  final VoidCallback onOpenSettings;

  const HomeScreen({
    super.key,
    this.isLoading = false,
    this.errorMessage,
    required this.onRetry,
    required this.onStartTeamGame,
    required this.onStartFreePlay,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primaryViolet),
              const SizedBox(height: 20),
              Text(
                GreekStrings.loading,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.alertRed,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(GreekStrings.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Column(
            children: [
              // Settings top-bar action
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined, size: 28),
                  tooltip: GreekStrings.settings,
                  onPressed: onOpenSettings,
                ),
              ),

              const Spacer(flex: 1),

              // Hero Area with authentic mime artwork and glowing purple gradient
              const AppLogo(size: 110, showShadow: true),

              const SizedBox(height: 22),

              // Title
              const Text(
                GreekStrings.appTitle,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 8),

              // Tagline
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  GreekStrings.appTagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.35,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Team Game Card Button
              _MenuModeCard(
                title: GreekStrings.teamGame,
                subtitle: GreekStrings.teamGameSubtitle,
                icon: Icons.groups_rounded,
                gradient: AppColors.primaryGradient,
                onTap: onStartTeamGame,
              ),

              const SizedBox(height: 16),

              // Free Play Card Button
              _MenuModeCard(
                title: GreekStrings.freePlay,
                subtitle: GreekStrings.freePlaySubtitle,
                icon: Icons.flash_on_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: onStartFreePlay,
              ),

              const Spacer(flex: 2),

              // Offline notice footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.offline_pin_rounded,
                    size: 16,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    GreekStrings.offlineNotice,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _MenuModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title: $subtitle',
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white60
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
