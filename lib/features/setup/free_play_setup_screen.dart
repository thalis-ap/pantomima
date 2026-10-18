import 'package:flutter/material.dart';
import '../../core/localization/greek_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/game_configuration.dart';
import '../../data/models/game_enums.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/greek_button.dart';

/// Screen to configure Free Play mode (difficulty and timer duration, no teams)
class FreePlaySetupScreen extends StatefulWidget {
  final Function(GameConfiguration) onStartGame;
  final int initialDuration;

  const FreePlaySetupScreen({
    super.key,
    required this.onStartGame,
    this.initialDuration = 60,
  });

  @override
  State<FreePlaySetupScreen> createState() => _FreePlaySetupScreenState();
}

class _FreePlaySetupScreenState extends State<FreePlaySetupScreen> {
  late int _selectedDuration;
  final Set<DifficultyCategory> _selectedDifficulties = {
    DifficultyCategory.easy,
    DifficultyCategory.medium,
    DifficultyCategory.hard,
    DifficultyCategory.impossible,
  };
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.initialDuration;
  }

  void _validateAndStart() {
    if (_selectedDifficulties.isEmpty) {
      setState(() {
        _validationError = GreekStrings.selectAtLeastOneDifficulty;
      });
      return;
    }

    final config = GameConfiguration(
      mode: GameMode.freePlay,
      teams: const [],
      roundDurationSeconds: _selectedDuration,
      allowedDifficulties: _selectedDifficulties,
    );

    widget.onStartGame(config);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(GreekStrings.freePlayModeTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Mode Info & Instruction
              GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                borderRadius: 22,
                gradient: LinearGradient(
                  colors: [
                    AppColors.electricBlue.withValues(alpha: 0.18),
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
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '«${GreekStrings.preGameInstruction}»',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Duration Section (Explicit presets: 30, 45, 60, 90, 120s)
              const Text(
                GreekStrings.roundDuration,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [30, 45, 60, 90, 120].map((dur) {
                  return ChoiceChip(
                    label: Text('$dur ${GreekStrings.seconds}'),
                    selected: _selectedDuration == dur,
                    onSelected: (val) {
                      if (val) setState(() => _selectedDuration = dur);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Difficulty Selection with Point Indicators
              const Text(
                GreekStrings.difficultySelection,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: DifficultyCategory.values.map((cat) {
                  final isSelected = _selectedDifficulties.contains(cat);
                  return FilterChip(
                    label: Text('${cat.nameEl} (+${cat.points} π.)'),
                    selected: isSelected,
                    selectedColor: cat.color.withValues(alpha: 0.25),
                    checkmarkColor: cat.color,
                    side: BorderSide(
                      color: isSelected
                          ? cat.color
                          : Colors.grey.withValues(alpha: 0.3),
                      width: 1.2,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDifficulties.add(cat);
                        } else {
                          if (_selectedDifficulties.length > 1) {
                            _selectedDifficulties.remove(cat);
                          }
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Validation Error Message
              if (_validationError != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.alertRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.alertRed, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.alertRed,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _validationError!,
                          style: const TextStyle(
                            color: AppColors.alertRed,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Start Game Button
              GreekButton(
                text: GreekStrings.startGame,
                icon: Icons.play_arrow_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onPressed: _validateAndStart,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
