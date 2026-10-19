import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/localization/greek_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/positive_int_validator.dart';
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
  static const List<int> _standardDurations = [60, 120, 180, 300];
  static const Map<int, String> _standardDurationLabels = {
    60: GreekStrings.duration1Min,
    120: GreekStrings.duration2Min,
    180: GreekStrings.duration3Min,
    300: GreekStrings.duration5Min,
  };

  late int _selectedDuration;
  bool _isCustomDuration = false;
  late TextEditingController _customDurationController;
  String? _durationValidationError;

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
    if (_standardDurations.contains(widget.initialDuration)) {
      _selectedDuration = widget.initialDuration;
      _isCustomDuration = false;
      _customDurationController = TextEditingController(text: '45');
    } else if (widget.initialDuration > 0) {
      _selectedDuration = widget.initialDuration;
      _isCustomDuration = true;
      _customDurationController = TextEditingController(
        text: widget.initialDuration.toString(),
      );
    } else {
      _selectedDuration = 60;
      _isCustomDuration = false;
      _customDurationController = TextEditingController(text: '45');
    }
  }

  @override
  void dispose() {
    _customDurationController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    if (_selectedDifficulties.isEmpty) return false;
    if (_isCustomDuration) {
      final res = PositiveIntValidator.validate(
        _customDurationController.text,
        emptyOrInvalidError: GreekStrings.invalidDurationError,
        overflowError: GreekStrings.durationOverflowError,
        min: 1,
        max: 3600,
      );
      if (!res.isValid) return false;
    }
    return true;
  }

  void _validateAndStart() {
    if (_selectedDifficulties.isEmpty) {
      setState(() {
        _validationError = GreekStrings.selectAtLeastOneDifficulty;
      });
      return;
    }

    int finalDuration = _selectedDuration;
    if (_isCustomDuration) {
      final res = PositiveIntValidator.validate(
        _customDurationController.text,
        emptyOrInvalidError: GreekStrings.invalidDurationError,
        overflowError: GreekStrings.durationOverflowError,
        min: 1,
        max: 3600,
      );
      if (!res.isValid) {
        setState(() {
          _durationValidationError = res.errorMessage;
          _validationError = res.errorMessage;
        });
        return;
      }
      finalDuration = res.value!;
    }

    final config = GameConfiguration(
      mode: GameMode.freePlay,
      teams: const [],
      roundDurationSeconds: finalDuration,
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

              // Duration Section (Standard choices: 1m, 2m, 3m, 5m, custom)
              const Text(
                GreekStrings.roundDuration,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._standardDurations.map((dur) {
                    final isSelected =
                        !_isCustomDuration && _selectedDuration == dur;
                    return ChoiceChip(
                      label: Text(_standardDurationLabels[dur]!),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _isCustomDuration = false;
                            _selectedDuration = dur;
                            _durationValidationError = null;
                            _validationError = null;
                          });
                        }
                      },
                    );
                  }),
                  ChoiceChip(
                    label: const Text(GreekStrings.durationCustom),
                    selected: _isCustomDuration,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _isCustomDuration = true;
                          final res = PositiveIntValidator.validate(
                            _customDurationController.text,
                            emptyOrInvalidError:
                                GreekStrings.invalidDurationError,
                            overflowError: GreekStrings.durationOverflowError,
                            min: 1,
                            max: 3600,
                          );
                          if (res.isValid) {
                            _selectedDuration = res.value!;
                            _durationValidationError = null;
                          } else {
                            _durationValidationError = res.errorMessage;
                          }
                        });
                      }
                    },
                  ),
                ],
              ),
              if (_isCustomDuration) ...[
                const SizedBox(height: 10),
                GlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _customDurationController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            hintText: GreekStrings.customDurationHint,
                            suffixText: GreekStrings.customDurationUnit,
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          onChanged: (val) {
                            final res = PositiveIntValidator.validate(
                              val,
                              emptyOrInvalidError:
                                  GreekStrings.invalidDurationError,
                              overflowError: GreekStrings.durationOverflowError,
                              min: 1,
                              max: 3600,
                            );
                            setState(() {
                              if (res.isValid) {
                                _selectedDuration = res.value!;
                                _durationValidationError = null;
                                _validationError = null;
                              } else {
                                _durationValidationError = res.errorMessage;
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (_durationValidationError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _durationValidationError!,
                    style: const TextStyle(
                      color: AppColors.alertRed,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
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
                onPressed: _isFormValid ? _validateAndStart : null,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
