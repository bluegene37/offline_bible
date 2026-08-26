import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/controllers/app_controller.dart';
import 'core/services/bible_audio_handler.dart';
import 'core/services/error_reporter.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_colors.dart';
import 'features/bible/controllers/bible_controller.dart';
import 'features/notes/controllers/notes_controller.dart';
import 'features/home/pages/home_page.dart';

void main() {
  // Everything below runs inside a guarded zone, so a failure during startup
  // is reported instead of vanishing into a blank screen.
  ErrorReporter.install(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Allow both portrait and landscape so tablets and larger phones can
    // read comfortably in either orientation.
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    LicenseRegistry.addLicense(() async* {
      final text = await rootBundle.loadString('assets/fonts/OFL.txt');
      yield LicenseEntryWithLineBreaks(const ['fonts'], text);
      yield const LicenseEntryWithLineBreaks(
        ['cross-reference data'],
        'Cross-reference data is derived from the openbible.info '
        'cross-references dataset (https://www.openbible.info/labs/cross-references/), '
        'licensed under the Creative Commons Attribution licence (CC BY).',
      );
    });

    // Initialize storage
    await StorageService.init();

    // Media session for chapter audio: gives Android a playback foreground
    // service and both platforms lock-screen controls.
    final audioHandler = await AudioService.init(
      builder: BibleAudioHandler.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'dev.genexis.offlinebible.audio',
        androidNotificationChannelName: 'Chapter audio',
        // Must exist, or NotificationManager.notify throws and takes the
        // process down. The plugin's default is mipmap/ic_launcher, which this
        // app does not have — its launcher icon is mipmap/launcher_icon.
        androidNotificationIcon: 'drawable/ic_stat_bible',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
    Get.put<BibleAudioHandler>(audioHandler, permanent: true);

    // Initialize controllers
    final appController = Get.put(AppController());
    Get.put(BibleController());
    Get.put(NotesController());
    await appController.init();

    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static ThemeData buildLightTheme(String colorThemeName, String fontFamily) {
    final seedColor = AppColors.themeColors[colorThemeName] ??
        AppColors.themeColors['Sapphire']!;
    final baseScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      // The tonal primary, not the raw seed: seeds like Sunset Amber sit at
      // 1.6:1 against the light surface. Material derives this tone precisely
      // so it stays legible on the scheme's own background.
      primaryColor: baseScheme.primary,
      fontFamily: fontFamily,
      colorScheme: baseScheme.copyWith(
        surface: AppColors.lightSurface,
      ),
      scaffoldBackgroundColor: AppColors.lightSurface,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 0, // modern airy feel
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: seedColor.withValues(alpha: 0.2),
      ),
    );
  }

  static ThemeData buildDarkTheme(String colorThemeName, String fontFamily) {
    final seedColor = AppColors.themeColors[colorThemeName] ??
        AppColors.themeColors['Sapphire']!;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: colorScheme.primary,
      fontFamily: fontFamily,
      colorScheme: colorScheme.copyWith(
        surface: AppColors.darkSurface,
      ),
      scaffoldBackgroundColor: AppColors.darkSurface,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeMode _initialMode(String pref) {
    switch (pref) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appController) {
        final lightTheme = buildLightTheme(
          appController.colorThemeName.value,
          appController.globalFont.value,
        );
        final darkTheme = buildDarkTheme(
          appController.colorThemeName.value,
          appController.globalFont.value,
        );

        return GetMaterialApp(
          title: 'Offline Bible',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: _initialMode(appController.themePref.value),
          home: const HomePage(),
          getPages: [
            GetPage(name: '/', page: () => const HomePage()),
          ],
        );
      },
    );
  }
}
