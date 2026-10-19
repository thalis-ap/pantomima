import 'package:flutter/material.dart';
import 'core/localization/greek_strings.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/phrase_repository.dart';
import 'features/game/game_controller.dart';
import 'features/game/game_screen.dart';
import 'features/home/home_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/setup/free_play_setup_screen.dart';
import 'features/setup/team_setup_screen.dart';
import 'services/audio_service.dart';
import 'services/haptics_service.dart';
import 'services/storage_service.dart';

/// Root application widget for «Παντομίμα»
class PantomimaApp extends StatefulWidget {
  final PhraseRepository phraseRepository;
  final StorageService storageService;
  final AudioService audioService;
  final HapticsService hapticsService;

  const PantomimaApp({
    super.key,
    required this.phraseRepository,
    required this.storageService,
    required this.audioService,
    required this.hapticsService,
  });

  @override
  State<PantomimaApp> createState() => _PantomimaAppState();
}

class _PantomimaAppState extends State<PantomimaApp> {
  late ThemeMode _themeMode;
  late GameController _gameController;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.storageService.themeMode;
    _gameController = GameController(
      phraseRepository: widget.phraseRepository,
      audioService: widget.audioService,
      hapticsService: widget.hapticsService,
      storageService: widget.storageService,
    );
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (!widget.phraseRepository.isInitialized) {
        await widget.phraseRepository.initialize();
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Αποτυχία φόρτωσης συλλογής φράσεων: $e';
      });
    }
  }

  void _onThemeChanged(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  void _navigateToTeamSetup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => TeamSetupScreen(
          initialDuration: widget.storageService.defaultRoundDuration,
          onStartGame: (config) {
            _gameController.setupGame(config);
            Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => GameScreen(
                  controller: _gameController,
                  onExit: () => Navigator.popUntil(context, (r) => r.isFirst),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateToFreePlay(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => FreePlaySetupScreen(
          initialDuration: widget.storageService.defaultRoundDuration,
          onStartGame: (config) {
            _gameController.setupGame(config);
            Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) => GameScreen(
                  controller: _gameController,
                  onExit: () => Navigator.popUntil(context, (r) => r.isFirst),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          storage: widget.storageService,
          onThemeChanged: _onThemeChanged,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gameController.dispose();
    widget.audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: GreekStrings.appTitle,
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: Builder(
        builder: (context) => HomeScreen(
          isLoading: _isLoading,
          errorMessage: _errorMessage,
          onRetry: _initializeData,
          onStartTeamGame: () => _navigateToTeamSetup(context),
          onStartFreePlay: () => _navigateToFreePlay(context),
          onOpenSettings: () => _navigateToSettings(context),
        ),
      ),
    );
  }
}
