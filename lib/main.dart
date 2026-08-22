import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/controllers/app_controller.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_colors.dart';
import 'features/bible/controllers/bible_controller.dart';
import 'features/notes/controllers/notes_controller.dart';
import 'features/home/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // All offered fonts ship inside the app; never fetch fonts over the network.
  // GoogleFonts.config.allowRuntimeFetching = false;

  // Allow both portrait and landscape so tablets and larger phones can
  // read comfortably in either orientation.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize storage
  await StorageService.init();

  // Initialize controllers
  final appController = Get.put(AppController());
  Get.put(BibleController());
  Get.put(NotesController());
  await appController.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static ThemeData buildLightTheme(String colorThemeName, String fontFamily) {
    final seedColor = AppColors.themeColors[colorThemeName] ?? AppColors.themeColors['Sapphire']!;
    final baseScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: seedColor,
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
        indicatorColor: seedColor.withOpacity(0.2),
      ),
    );
  }

  static ThemeData buildDarkTheme(String colorThemeName, String fontFamily) {
    final seedColor = AppColors.themeColors[colorThemeName] ?? AppColors.themeColors['Sapphire']!;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
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
