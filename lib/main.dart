import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/controllers/app_controller.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_colors.dart';
import 'features/bible/controllers/bible_controller.dart';
import 'features/notes/controllers/notes_controller.dart';
import 'features/home/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Unlock orientation (remove restriction to portrait only)
  // This allows users to read in landscape mode on tablets or larger phones.
  // Unlock orientation to allow landscape mode
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
    final seedColor = AppColors.themeColors[colorThemeName]!;
    final baseScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );
    // Very subtle tint for backgrounds — almost white
    final lightTint = HSLColor.fromColor(seedColor)
        .withSaturation(0.08)
        .withLightness(0.98)
        .toColor();

    // Override surface colors to remove Material 3's default bluish tint
    final colorScheme = baseScheme.copyWith(
      surface: lightTint,
      surfaceContainerHighest: AppColors.themeColorShades[colorThemeName],
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: seedColor,
      fontFamily: fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: lightTint,
      appBarTheme: AppBarTheme(
        backgroundColor: seedColor,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightTint,
      ),
    );
  }

  /// Builds the dark ThemeData with neutral black/white colors.
  static ThemeData buildDarkTheme(String fontFamily) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.dark(
        primary: Colors.white,
        secondary: Colors.grey.shade400,
        onPrimary: Colors.black,
        surface: Colors.grey.shade900,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appController) {
        final lightTheme = buildLightTheme(
          appController.colorThemeName.value,
          appController.globalFont.value,
        );
        final darkTheme = buildDarkTheme(appController.globalFont.value);

        return AdaptiveTheme(
          light: lightTheme,
          dark: darkTheme,
          initial: appController.themeMode.value
              ? AdaptiveThemeMode.dark
              : AdaptiveThemeMode.light,
          builder: (theme, darkTheme) => GetMaterialApp(
            title: 'Offline Bible',
            debugShowCheckedModeBanner: false,
            theme: theme,
            darkTheme: darkTheme,
            home: const HomePage(),
            getPages: [
              GetPage(name: '/', page: () => const HomePage()),
            ],
          ),
        );
      },
    );
  }
}
