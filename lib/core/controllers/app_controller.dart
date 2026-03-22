import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_bible/features/bible/controllers/bible_controller.dart';
import '../../features/bible/models/book_model.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../../features/bible/services/bible_service.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:offline_bible/main.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class AppController extends GetxController {
  // Observable variables
  final RxString barTitle = AppConstants.appName.obs;
  final RxString bookSelected = AppConstants.defaultBook.obs;
  final RxInt selectedChapter = AppConstants.defaultChapter.obs;
  final RxString searchQuery = ''.obs;
  final RxInt globalIndex = AppConstants.biblePageIndex.obs;
  final RxString colorThemeName = AppConstants.defaultColorTheme.obs;
  final RxInt textColorIdx = AppConstants.defaultTextColorIndex.obs;
  final RxString globalFont = AppConstants.defaultFont.obs;
  final RxDouble fontSize = AppConstants.defaultFontSize.obs;
  final RxBool themeMode = false.obs;
  final RxBool hideFloatingBtn = false.obs;
  final RxBool showAds = true.obs;
  final RxList<String> textUnderline = <String>[].obs;
  final Rx<Color> textColorDynamic = Colors.black.obs;
  final RxBool keepScreenOn = false.obs;

  // Helper getters: return null in dark mode (pure black/white), color theme in light mode
  Color? get activeThemeColor => themeMode.value
      ? null
      : AppColors.themeColors[colorThemeName.value];

  Color? get activeThemeShade => themeMode.value
      ? null
      : AppColors.themeColorShades[colorThemeName.value];

  // Caching
  List<Book> cachedBibleData = [];
  List<BookTitle> cachedBookTitles = [];

  // Non-reactive variables
  String bibleVersion = AppConstants.defaultBibleVersion;
  int lastChapter = 1;
  bool refreshChapter = false;
  String bookSelectedHist = '';
  int selectedChapterHist = 0;
  String searchResultHist = '';
  int globalFontIdx = 8;

  Future<void> init() async {
    await _initializeApp();
  }

  Future<void> _initializeApp() async {
    await BibleService.initialize(this);
    _loadSettings();
    final bibleController = Get.find<BibleController>();
    bibleController.loadChapter(bookSelected.value, selectedChapter.value);
    bibleController.loadChapters(bookSelected.value);
    _updateTextColor();
    
    // Restore last reading position
    final savedBook = StorageService.getSetting<String?>('lastReadBook', null);
    final savedChapter = StorageService.getSetting<int?>('lastReadChapter', null);
    if (savedBook != null && savedChapter != null) {
      bookSelected.value = savedBook;
      selectedChapter.value = savedChapter;
      globalIndex.value = 2; // Default to Bible tab if reading position is saved
    }

    if (keepScreenOn.value) WakelockPlus.enable();
  }

  void _loadSettings() {
    themeMode.value = StorageService.getSetting('themeMode', false);
    bibleVersion = StorageService.getSetting(
        'bibleVersions', AppConstants.defaultBibleVersion);
    bookSelected.value =
        StorageService.getSetting('bookSelected', AppConstants.defaultBook);
    selectedChapter.value = StorageService.getSetting(
        'selectedChapter', AppConstants.defaultChapter);
    colorThemeName.value = StorageService.getSetting(
        'colorThemeName', AppConstants.defaultColorTheme);
    textColorIdx.value = StorageService.getSetting(
        'textColorIdx', AppConstants.defaultTextColorIndex);
    globalFont.value =
        StorageService.getSetting('globalFont', AppConstants.defaultFont);
    globalFontIdx = StorageService.getSetting('globalFontIdx', 8);
    fontSize.value =
        StorageService.getSetting('fontSize', AppConstants.defaultFontSize);
    keepScreenOn.value = StorageService.getSetting('keepScreenOn', false);
  }

  void _updateTextColor() {
    final brightness = ThemeData.estimateBrightnessForColor(
      AppColors.themeColors[colorThemeName.value]!,
    );
    textColorDynamic.value =
        brightness == Brightness.light ? Colors.black : Colors.white;
  }

  void updateColorTheme(String themeName) {
    colorThemeName.value = themeName;
    StorageService.setSetting('colorThemeName', themeName);
    _updateTextColor();

    // Force-apply the new theme immediately via AdaptiveTheme
    final context = Get.context;
    if (context != null) {
      AdaptiveTheme.of(context).setTheme(
        light: MyApp.buildLightTheme(themeName, globalFont.value),
        dark: MyApp.buildDarkTheme(globalFont.value),
      );
    }
    update();
  }

  void updateTextColor(int index) {
    textColorIdx.value = index;
    StorageService.setSetting('textColorIdx', index);
  }

  void updateFont(String font) {
    globalFont.value = font;
    StorageService.setSetting('globalFont', font);
    globalFontIdx = AppConstants.fontOptions.indexWhere((f) => f == font);
    StorageService.setSetting('globalFontIdx', globalFontIdx);
  }

  void updateFontSize(double size) {
    fontSize.value = size;
    StorageService.setSetting('fontSize', size);
    update();
  }

  void updateBookSelection(String book, int chapter) {
    bookSelected.value = book;
    selectedChapter.value = chapter;
    StorageService.setSetting('lastReadBook', book);
    StorageService.setSetting('lastReadChapter', chapter);
    update();
    barTitle.value = '$book $chapter';
    Get.find<BibleController>().loadChapters(book);
  }

  void navigateToVerse(String book, int chapter, int verse) {
    updateBookSelection(book, chapter);
    final bibleController = Get.find<BibleController>();
    bibleController.pendingScrollVerseIndex = verse - 1;
    bibleController.loadChapter(book, chapter);
    navigateToPage(2); // Go to Bible tab
  }

  void navigateToPage(int index) {
    globalIndex.value = index;
    textUnderline.clear();
  }

  void clearTextSelection() {
    textUnderline.clear();
  }

  void toggleThemeMode(bool isDark, BuildContext context) {
    themeMode.value = isDark;
    StorageService.setSetting('themeMode', isDark);
    if (isDark) {
      AdaptiveTheme.of(context).setDark();
    } else {
      AdaptiveTheme.of(context).setLight();
    }
    update();
  }

  void toggleKeepScreenOn(bool value) {
    keepScreenOn.value = value;
    StorageService.setSetting('keepScreenOn', value);
    if (value) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
    update();
  }
}
