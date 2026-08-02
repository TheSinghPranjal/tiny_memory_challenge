import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_challenge/controllers/app_controllers.dart';
import 'package:memory_challenge/core/navigation/app_route_observer.dart';
import 'package:memory_challenge/core/theme/app_theme.dart';
import 'package:memory_challenge/screens/home_screen.dart';
import 'package:memory_challenge/services/ad_service.dart';
import 'package:memory_challenge/services/audio_service.dart';
import 'package:memory_challenge/services/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final storage = LocalStorageService();
  await storage.init();

  final audio = AudioService();
  await audio.init();

  final ads = AdService();
  await ads.init();

  final settings = storage.loadSettings();
  audio.applyToggles(
    sound: settings.soundEnabled,
    music: settings.musicEnabled,
    vibration: settings.vibrationEnabled,
  );

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(storage),
        audioServiceProvider.overrideWithValue(audio),
        adServiceProvider.overrideWithValue(ads),
      ],
      child: const TinyThinkApp(),
    ),
  );
}

class TinyThinkApp extends StatelessWidget {
  const TinyThinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiny Think - Memory Challenge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      navigatorObservers: [appRouteObserver],
      home: const HomeScreen(),
    );
  }
}
