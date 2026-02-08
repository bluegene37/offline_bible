import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'core/controllers/app_controller.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_colors.dart';
import 'features/bible/controllers/bible_controller.dart';
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
  await appController.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appController) {
        return AdaptiveTheme(
          light: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            primaryColor:
                AppColors.themeColors[appController.colorThemeName.value],
            fontFamily: appController.globalFont.value,
            colorScheme: ColorScheme.fromSeed(
              seedColor:
                  AppColors.themeColors[appController.colorThemeName.value]!,
              brightness: Brightness.light,
            ),
          ),
          dark: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primaryColor:
                AppColors.themeColors[appController.colorThemeName.value],
            fontFamily: appController.globalFont.value,
            colorScheme: ColorScheme.fromSeed(
              seedColor:
                  AppColors.themeColors[appController.colorThemeName.value]!,
              brightness: Brightness.dark,
            ),
          ),
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
