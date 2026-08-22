import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_bible/features/bible/controllers/bible_controller.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../../features/bible/services/bible_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class AppController extends GetxController {
  // Observable variables
  final RxString barTitle = AppConstants.appName.obs;
  final RxString bookSelected = AppConstants.defaultBook.obs;
  final RxInt selectedChapter = AppConstants.defaultChapter.obs;
  final RxString searchQuery = ''.obs;
  final RxInt globalIndex = AppConstants.biblePageIndex.obs;
  final RxString colorThemeName = AppConstants.defaultColorTheme.obs;
  final RxString globalFont = AppConstants.defaultFont.obs;
  final RxDouble fontSize = AppConstants.defaultFontSize.obs;
  final RxDouble lineHeight = AppConstants.defaultLineHeight.obs;

  /// 'system' | 'light' | 'dark'
  final RxString themePref = 'system'.obs;

  /// Effective dark flag for the currently applied theme. Kept in sync with
  /// [themePref] and, in system mode, the platform brightness.
  final RxBool themeMode = false.obs;

  final RxBool hideFloatingBtn = false.obs;
  final RxList<String> textUnderline = <String>[].obs;
  final Rx<Color> textColorDynamic = Colors.black.obs;
  final RxBool keepScreenOn = false.obs;
  final RxString bibleVersion = AppConstants.defaultBibleVersion.obs;
  final RxBool isSwitchingVersion = false.obs;

  // Accent colors derived from the selected seed, safe on both backgrounds.
  Color _lightAccent = Colors.black;
  Color _darkAccent = Colors.white;
  Color _lightShade = Colors.grey.shade200;
  Color _darkShade = Colors.grey.shade800;

  /// Accent color for the current brightness. Never null: dark mode keeps the
  /// user's color as a tonally lightened accent instead of dropping it.
  Color get activeThemeColor => themeMode.value ? _darkAccent : _lightAccent;

  /// Soft container shade of the accent for the current brightness.
  Color get activeThemeShade => themeMode.value ? _darkShade : _lightShade;

  // Non-reactive variables
  int lastChapter = 1;
  bool refreshChapter = false;
  String bookSelectedHist = '';
  int selectedChapterHist = 0;
  String searchResultHist = '';

  Future<void> init() async {
    _loadSettings();
    _deriveAccentColors();
    _watchPlatformBrightness();

    try {
      await BibleService.initialize(this);
    } catch (e) {
      Get.snackbar(
          'Error', 'Failed to load Bible data. Please restart the app.');
    }

    // Restore last reading position before loading, so the first chapter
    // shown is the one the user was reading.
    final savedBook = StorageService.getSetting<String?>('lastReadBook', null);
    final savedChapter = StorageService.getSetting<int?>('lastReadChapter', null);
    if (savedBook != null && savedChapter != null) {
      bookSelected.value = savedBook;
      selectedChapter.value = savedChapter;
      globalIndex.value = AppConstants.biblePageIndex;
    }

    final bibleController = Get.find<BibleController>();
    await bibleController.loadChapter(bookSelected.value, selectedChapter.value);

    if (keepScreenOn.value) WakelockPlus.enable();
  }

  void _loadSettings() {
    themePref.value = _loadThemePref();
    themeMode.value = _isEffectiveDark(themePref.value);
    bibleVersion.value = StorageService.getSetting(
        'bibleVersions', AppConstants.defaultBibleVersion);
    bookSelected.value =
        StorageService.getSetting('bookSelected', AppConstants.defaultBook);
    selectedChapter.value = StorageService.getSetting(
        'selectedChapter', AppConstants.defaultChapter);
    colorThemeName.value = StorageService.getSetting(
        'colorThemeName', AppConstants.defaultColorTheme);
    if (!AppColors.themeColors.containsKey(colorThemeName.value)) {
      colorThemeName.value = AppConstants.defaultColorTheme;
    }
    globalFont.value =
        StorageService.getSetting('globalFont', AppConstants.defaultFont);
    if (!AppConstants.fontOptions.contains(globalFont.value)) {
      // A previously saved font that is no longer bundled falls back cleanly.
      globalFont.value = AppConstants.defaultFont;
    }
    fontSize.value = _loadFontSize();
    lineHeight.value =
        StorageService.getSetting('lineHeight', AppConstants.defaultLineHeight);
    keepScreenOn.value = StorageService.getSetting('keepScreenOn', false);
  }

  String _loadThemePref() {
    final saved = StorageService.getSetting<String?>('themePref', null);
    if (saved != null) return saved;
    // Migrate from the old boolean dark-mode setting.
    final oldBool = StorageService.getSetting<bool?>('themeMode', null);
    if (oldBool != null) return oldBool ? 'dark' : 'light';
    return 'system';
  }

  double _loadFontSize() {
    final savedPx = StorageService.getSetting<double?>('fontSizePx', null);
    if (savedPx != null) return savedPx;
    // Migrate from the old 0-15 offset scale (rendered as 15 + offset px).
    final oldOffset = StorageService.getSetting<double?>('fontSize', null);
    if (oldOffset != null) {
      return (15 + oldOffset).clamp(
          AppConstants.minFontSize, AppConstants.maxFontSize);
    }
    return AppConstants.defaultFontSize;
  }

  bool _isEffectiveDark(String pref) {
    switch (pref) {
      case 'dark':
        return true;
      case 'light':
        return false;
      default:
        return WidgetsBinding
                .instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    }
  }

  void _watchPlatformBrightness() {
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
        () {
      if (themePref.value == 'system') {
        themeMode.value = _isEffectiveDark('system');
        _updateTextColor();
        update();
      }
    };
  }

  void _deriveAccentColors() {
    final seed = AppColors.themeColors[colorThemeName.value] ?? AppColors.themeColors['Sapphire']!;
    final lightScheme =
        ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
    final darkScheme =
        ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
    _lightAccent = seed;
    _darkAccent = darkScheme.primary;
    _lightShade = lightScheme.primaryContainer;
    _darkShade = darkScheme.primaryContainer;
    _updateTextColor();
  }

  void _updateTextColor() {
    final brightness = ThemeData.estimateBrightnessForColor(activeThemeColor);
    textColorDynamic.value =
        brightness == Brightness.light ? Colors.black : Colors.white;
  }

  void updateColorTheme(String themeName) {
    colorThemeName.value = themeName;
    StorageService.setSetting('colorThemeName', themeName);
    _deriveAccentColors();
    update();
  }

  void updateFont(String font) {
    globalFont.value = font;
    StorageService.setSetting('globalFont', font);
    update();
  }

  void updateFontSize(double size) {
    fontSize.value = size;
    StorageService.setSetting('fontSizePx', size);
    update();
  }

  void updateLineHeight(double height) {
    lineHeight.value = height;
    StorageService.setSetting('lineHeight', height);
    update();
  }

  Future<void> changeBibleVersion(String abbrev) async {
    if (abbrev == bibleVersion.value || isSwitchingVersion.value) return;
    isSwitchingVersion.value = true;
    try {
      await BibleService.switchVersion(abbrev);
      bibleVersion.value = BibleService.loadedVersion;
      StorageService.setSetting('bibleVersions', bibleVersion.value);
      final bibleController = Get.find<BibleController>();
      await bibleController.loadChapter(
          bookSelected.value, selectedChapter.value);
      update();
    } catch (e) {
      Get.snackbar('Error', 'Could not switch version: $e');
    } finally {
      isSwitchingVersion.value = false;
    }
  }

  void updateBookSelection(String book, int chapter) {
    bookSelected.value = book;
    selectedChapter.value = chapter;
    final nowIso = DateTime.now().toIso8601String();
    StorageService.setSetting('lastReadBook', book);
    StorageService.setSetting('lastReadChapter', chapter);
    StorageService.setSetting('lastReadTimestamp', nowIso);
    update();
    barTitle.value = '$book $chapter';
    Get.find<BibleController>().loadChapters(book);
  }

  String get lastReadTimeFormatted {
    final raw = StorageService.getSetting<String?>('lastReadTimestamp', null);
    if (raw == null) return 'Recently';
    try {
      final dt = DateTime.parse(raw);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return 'Recently';
    }
  }

  void navigateToVerse(String book, int chapter, int verse) {
    updateBookSelection(book, chapter);
    final bibleController = Get.find<BibleController>();
    bibleController.pendingScrollVerseIndex = verse - 1;
    bibleController.loadChapter(book, chapter);
    navigateToPage(AppConstants.biblePageIndex); // Go to Bible tab
  }

  void navigateToPage(int index) {
    globalIndex.value = index;
    textUnderline.clear();
    switch (index) {
      case AppConstants.booksPageIndex:
        barTitle.value = "Books (66)";
        break;
      case AppConstants.chaptersPageIndex:
        barTitle.value = "Chapters";
        break;
      case AppConstants.biblePageIndex:
        barTitle.value = '${bookSelected.value} ${selectedChapter.value}';
        break;
      case AppConstants.plansPageIndex:
        barTitle.value = "Reading Plans";
        break;
      case AppConstants.searchPageIndex:
        barTitle.value = "Search";
        break;
      case AppConstants.notesPageIndex:
        barTitle.value = "Saved Items";
        break;
      case AppConstants.settingsPageIndex:
        barTitle.value = "Settings";
        break;
    }
  }

  void clearTextSelection() {
    textUnderline.clear();
  }

  void setThemePref(String pref, BuildContext context) {
    themePref.value = pref;
    StorageService.setSetting('themePref', pref);
    themeMode.value = _isEffectiveDark(pref);
    switch (pref) {
      case 'dark':
        Get.changeThemeMode(ThemeMode.dark);
        break;
      case 'light':
        Get.changeThemeMode(ThemeMode.light);
        break;
      default:
        Get.changeThemeMode(ThemeMode.system);
    }
    _updateTextColor();
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
