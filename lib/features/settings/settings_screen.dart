import 'package:flutter/material.dart';
import '../../core/localization/greek_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../services/storage_service.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/glass_card.dart';

/// Settings screen for audio, haptics, theme appearance, and default options
class SettingsScreen extends StatefulWidget {
  final StorageService storage;
  final Function(ThemeMode) onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.storage,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _sound;
  late bool _vibration;
  late ThemeMode _themeMode;
  late int _defaultDuration;
  late bool _streakBonus;

  @override
  void initState() {
    super.initState();
    _sound = widget.storage.soundEnabled;
    _vibration = widget.storage.vibrationEnabled;
    _themeMode = widget.storage.themeMode;
    _defaultDuration = widget.storage.defaultRoundDuration;
    _streakBonus = widget.storage.streakBonusEnabled;
  }

  void _onSoundToggle(bool val) {
    setState(() => _sound = val);
    widget.storage.soundEnabled = val;
  }

  void _onVibrationToggle(bool val) {
    setState(() => _vibration = val);
    widget.storage.vibrationEnabled = val;
  }

  void _onStreakBonusToggle(bool val) {
    setState(() => _streakBonus = val);
    widget.storage.streakBonusEnabled = val;
  }

  void _onThemeSelect(ThemeMode mode) {
    setState(() => _themeMode = mode);
    widget.storage.themeMode = mode;
    widget.onThemeChanged(mode);
  }

  void _onDurationSelect(int duration) {
    setState(() => _defaultDuration = duration);
    widget.storage.defaultRoundDuration = duration;
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(GreekStrings.resetSettings),
          content: const Text(GreekStrings.resetSettingsConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(GreekStrings.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.alertRed,
              ),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(ctx);

                await widget.storage.resetToDefaults();
                setState(() {
                  _sound = widget.storage.soundEnabled;
                  _vibration = widget.storage.vibrationEnabled;
                  _themeMode = widget.storage.themeMode;
                  _defaultDuration = widget.storage.defaultRoundDuration;
                  _streakBonus = widget.storage.streakBonusEnabled;
                });
                widget.onThemeChanged(_themeMode);

                nav.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(GreekStrings.resetSuccess),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                GreekStrings.confirm,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text(GreekStrings.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          physics: const BouncingScrollPhysics(),
          children: [
            // Audio & Haptics Section
            const Text(
              GreekStrings.audioAndHaptics,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryViolet,
              ),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      GreekStrings.soundEffects,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(GreekStrings.soundEffectsSubtitle),
                    value: _sound,
                    activeThumbColor: AppColors.primaryViolet,
                    onChanged: _onSoundToggle,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text(
                      GreekStrings.vibration,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(GreekStrings.vibrationSubtitle),
                    value: _vibration,
                    activeThumbColor: AppColors.primaryViolet,
                    onChanged: _onVibrationToggle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Appearance Section
            const Text(
              GreekStrings.appearance,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryViolet,
              ),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    GreekStrings.themeMode,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode_rounded),
                          label: Text(GreekStrings.themeDark),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode_rounded),
                          label: Text(GreekStrings.themeLight),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.brightness_auto_rounded),
                          label: Text(GreekStrings.themeSystem),
                        ),
                      ],
                      selected: {_themeMode},
                      onSelectionChanged: (set) => _onThemeSelect(set.first),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Round Duration Default
            const Text(
              GreekStrings.defaultTimerSetting,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryViolet,
              ),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    GreekStrings.roundDuration,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: StorageService.availableDurations.map((sec) {
                      return ChoiceChip(
                        label: Text(StorageService.formatDuration(sec)),
                        selected: _defaultDuration == sec,
                        onSelected: (val) {
                          if (val) _onDurationSelect(sec);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Streak Bonus Setting
            const Text(
              GreekStrings.streakBonus,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryViolet,
              ),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: SwitchListTile(
                title: const Text(
                  GreekStrings.streakBonus,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(GreekStrings.streakBonusDescription),
                value: _streakBonus,
                activeThumbColor: AppColors.primaryViolet,
                onChanged: _onStreakBonusToggle,
              ),
            ),
            const SizedBox(height: 24),

            // About Section
            const Text(
              GreekStrings.about,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryViolet,
              ),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const AppLogo(size: 48, showShadow: false),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            GreekStrings.appTitle,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            GreekStrings.appVersion,
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    GreekStrings.phrasesTotalLabel,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    GreekStrings.offlineNotice,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Reset Button
            OutlinedButton.icon(
              onPressed: _confirmReset,
              icon: const Icon(Icons.restore_rounded, color: Colors.redAccent),
              label: const Text(
                GreekStrings.resetSettings,
                style: TextStyle(color: Colors.redAccent),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
