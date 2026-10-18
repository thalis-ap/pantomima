import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'data/repositories/phrase_repository.dart';
import 'services/audio_service.dart';
import 'services/haptics_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prefer portrait mode for optimal party mobile gameplay
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI navigation bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F0B1E),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize storage service
  final storageService = await StorageService.create();

  // Create core services and repository
  final phraseRepository = PhraseRepository();
  final audioService = AudioService(storageService);
  final hapticsService = HapticsService(storageService);

  runApp(
    PantomimaApp(
      phraseRepository: phraseRepository,
      storageService: storageService,
      audioService: audioService,
      hapticsService: hapticsService,
    ),
  );
}
