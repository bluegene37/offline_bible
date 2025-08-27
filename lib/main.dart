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
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize storage
  await StorageService.init();
  
  // Initialize controllers
  Get.put(AppController());
  Get.put(BibleController());

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
            useMaterial3: false,
            brightness: Brightness.light,
            primaryColor: AppColors.themeColors[appController.colorSliderIdx.value],
            fontFamily: appController.globalFont.value,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.themeColors[appController.colorSliderIdx.value],
              brightness: Brightness.light,
            ),
          ),
          dark: ThemeData(
            useMaterial3: false,
            brightness: Brightness.dark,
            primaryColor: AppColors.themeColors[appController.colorSliderIdx.value],
            fontFamily: appController.globalFont.value,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.themeColors[appController.colorSliderIdx.value],
              brightness: Brightness.dark,
            ),
          ),
          initial: appController.themeMode.value 
              ? AdaptiveThemeMode.dark 
              : AdaptiveThemeMode.light,
          builder: (theme, darkTheme) => GetMaterialApp(
            title: 'Simple Bible',
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