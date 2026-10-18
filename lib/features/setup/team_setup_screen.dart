import 'package:flutter/material.dart';
import '../../core/localization/greek_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/game_configuration.dart';
import '../../data/models/game_enums.dart';
import '../../data/models/team.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/greek_button.dart';

/// Screen to configure teams, round durations, and allowed difficulties
class TeamSetupScreen extends StatefulWidget {
  final Function(GameConfiguration) onStartGame;
  final int initialDuration;

  const TeamSetupScreen({
    super.key,
    required this.onStartGame,
    this.initialDuration = 60,
  });

  @override
  State<TeamSetupScreen> createState() => _TeamSetupScreenState();
}

class _TeamSetupScreenState extends State<TeamSetupScreen> {
  static const List<Color> _teamColors = [
    Color(0xFF8B5CF6), // Purple
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEC4899), // Pink
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFF3B82F6), // Blue
    Color(0xFF84CC16), // Lime
    Color(0xFFEF4444), // Red
  ];

  late List<TextEditingController> _nameControllers;
  late List<Color> _assignedColors;
  String? _validationError;

  // Duration settings: default 60 seconds (independent of difficulty)
  late int _selectedDuration;

  // Round settings: default 5 rounds (options: 3, 5, 10, custom)
  int _selectedRounds = 5;
  bool _isCustomRounds = false;
  late TextEditingController _customRoundsController;

  final Set<DifficultyCategory> _selectedDifficulties = {
    DifficultyCategory.easy,
    DifficultyCategory.medium,
    DifficultyCategory.hard,
    DifficultyCategory.impossible,
  };

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.initialDuration;
    // Default 2 teams
    _nameControllers = [
      TextEditingController(text: '${GreekStrings.defaultTeamPrefix} 1'),
      TextEditingController(text: '${GreekStrings.defaultTeamPrefix} 2'),
    ];
    _assignedColors = [_teamColors[0], _teamColors[1]];
    _customRoundsController = TextEditingController(text: '7');
  }

  @override
  void dispose() {
    for (var c in _nameControllers) {
      c.dispose();
    }
    _customRoundsController.dispose();
    super.dispose();
  }

  void _addTeam() {
    if (_nameControllers.length >= 8) {
      setState(() {
        _validationError = GreekStrings.maxTeamsError;
      });
      return;
    }
    setState(() {
      final idx = _nameControllers.length;
      _nameControllers.add(
        TextEditingController(
          text: '${GreekStrings.defaultTeamPrefix} ${idx + 1}',
        ),
      );
      _assignedColors.add(_teamColors[idx % _teamColors.length]);
      _validationError = null;
    });
  }

  void _removeTeam(int index) {
    if (_nameControllers.length <= 2) {
      setState(() {
        _validationError = GreekStrings.minTeamsError;
      });
      return;
    }
    setState(() {
      _nameControllers[index].dispose();
      _nameControllers.removeAt(index);
      _assignedColors.removeAt(index);
      _validationError = null;
    });
  }

  void _validateAndStart() {
    if (_nameControllers.length < 2) {
      setState(() => _validationError = GreekStrings.minTeamsError);
      return;
    }

    final names = <String>[];
    for (var c in _nameControllers) {
      final name = c.text.trim();
      if (name.isEmpty) {
        setState(() => _validationError = GreekStrings.emptyTeamNameError);
        return;
      }
      if (names.contains(name.toLowerCase())) {
        setState(() => _validationError = GreekStrings.duplicateTeamNameError);
        return;
      }
      names.add(name.toLowerCase());
    }

    if (_selectedDifficulties.isEmpty) {
      setState(
        () => _validationError = GreekStrings.selectAtLeastOneDifficulty,
      );
      return;
    }

    int finalRounds = _selectedRounds;
    if (_isCustomRounds) {
      final custom = int.tryParse(_customRoundsController.text.trim());
      if (custom == null || custom <= 0) {
        setState(() => _validationError = GreekStrings.invalidRoundsError);
        return;
      }
      finalRounds = custom;
    }

    final teams = <Team>[];
    for (int i = 0; i < _nameControllers.length; i++) {
      teams.add(
        Team(
          id: 'team_$i',
          name: _nameControllers[i].text.trim(),
          score: 0,
          color: _assignedColors[i],
        ),
      );
    }

    final config = GameConfiguration(
      mode: GameMode.team,
      teams: teams,
      roundDurationSeconds: _selectedDuration,
      totalRounds: finalRounds,
      allowedDifficulties: _selectedDifficulties,
    );

    widget.onStartGame(config);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(GreekStrings.setupTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Teams Section Header (Responsive Row with overflow protection)
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      GreekStrings.teamsSection,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: _nameControllers.length < 8
                            ? _addTeam
                            : null,
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          size: 20,
                        ),
                        label: const Text(GreekStrings.addTeam),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Teams List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _nameControllers.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: _assignedColors[index],
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: _nameControllers[index],
                            decoration: InputDecoration(
                              hintText: GreekStrings.teamNameHint,
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_nameControllers.length > 2)
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.redAccent,
                              size: 22,
                            ),
                            onPressed: () => _removeTeam(index),
                            tooltip: 'Αφαίρεση ομάδας',
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Game Length / Rounds Section
              const Text(
                GreekStrings.roundsTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text(GreekStrings.roundsOption3),
                    selected: !_isCustomRounds && _selectedRounds == 3,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _isCustomRounds = false;
                          _selectedRounds = 3;
                          _validationError = null;
                        });
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text(GreekStrings.roundsOption5),
                    selected: !_isCustomRounds && _selectedRounds == 5,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _isCustomRounds = false;
                          _selectedRounds = 5;
                          _validationError = null;
                        });
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text(GreekStrings.roundsOption10),
                    selected: !_isCustomRounds && _selectedRounds == 10,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _isCustomRounds = false;
                          _selectedRounds = 10;
                          _validationError = null;
                        });
                      }
                    },
                  ),
                  ChoiceChip(
                    label: const Text(GreekStrings.roundsCustom),
                    selected: _isCustomRounds,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _isCustomRounds = true;
                        });
                      }
                    },
                  ),
                ],
              ),
              if (_isCustomRounds) ...[
                const SizedBox(height: 10),
                GlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tune_rounded, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _customRoundsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Αριθμός γύρων (π.χ. 7)',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          onChanged: (val) {
                            final parsed = int.tryParse(val.trim());
                            if (parsed != null && parsed > 0) {
                              setState(() {
                                _selectedRounds = parsed;
                                _validationError = null;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
              const SizedBox(height: 20),

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
                gradient: AppColors.primaryGradient,
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
