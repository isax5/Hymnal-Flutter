import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:hymnal_app/services/locator_service.dart';
import 'package:hymnal_app/services/settings_service.dart';
import 'package:hymnal_app/services/audio_service.dart';
import 'package:hymnal_app/styles/theme.dart';
import 'package:hymnal_app/layers/screens/main_tabs_screen.dart';
import 'package:get_it/get_it.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize audio background service with error handling
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.isax5.hymnal.channel.audio',
      androidNotificationChannelName: 'Hymnal Audio',
      androidNotificationOngoing: true,
    );
  } catch (e) {
    // If background audio fails to initialize, continue without it
    debugPrint('Warning: Background audio initialization failed: $e');
  }

  setupLocator();

  final settingsService = GetIt.I<SettingsService>();
  await settingsService.initialize();

  runApp(const HymnalApp());
}

class HymnalApp extends StatelessWidget {
  const HymnalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = GetIt.I<SettingsService>();

    return AnimatedBuilder(
      animation: settingsService,
      builder: (context, child) {
        ThemeMode themeMode;
        switch (settingsService.themeMode) {
          case 'light':
            themeMode = ThemeMode.light;
            break;
          case 'dark':
            themeMode = ThemeMode.dark;
            break;
          default:
            themeMode = ThemeMode.system;
        }

        return MaterialApp(
          title: 'Hymnal',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const MainTabsScreen(),
        );
      },
    );
  }
}
