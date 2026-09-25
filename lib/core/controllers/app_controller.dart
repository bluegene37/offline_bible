import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_bible/features/bible/controllers/bible_controller.dart';
import '../constants/app_constants.dart';
import '../services/error_reporter.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import 'dart:async';

import '../../features/bible/services/bible_service.dart';
import '../../features/bible/services/cross_reference_service.dart';
import '../../features/bible/services/red_letter_service.dart';
import '../../features/bible/services/version_service.dart';
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

  /// Words of Christ in red. Only meaningful for the bundled KJV, whose
  /// wording the ranges were derived against.
  final RxBool redLetterEnabled = true.obs;
  final RxString bibleVersion = AppConstants.defaultBibleVersion.obs;
  final RxBool isSwitchingVersion = false.obs;

  /// Set when a stored translation was withdrawn from the catalog, so its
  /// orphaned file can be cleaned up once storage is ready.
  String? _retiredVersion;

  /// Non-null when the Bible text could not be loaded at startup. Rendered as
  /// an in-page error by the reader — a snackbar here would be invisible,
  /// because this runs before there is an overlay to show it in.
  final RxnString loadError = RxnString();

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

  Future<void> init() async {
    _loadSettings();
    _deriveAccentColors();
    _watchPlatformBrightness();

    await _loadBibleData();

    // Restore last reading position before loading, so the first chapter
    // shown is the one the user was reading.
    final savedBook = StorageService.getSetting<String?>('lastReadBook', null);
    final savedChapter =
        StorageService.getSetting<int?>('lastReadChapter', null);
    if (savedBook != null && savedChapter != null) {
      bookSelected.value = savedBook;
      selectedChapter.value = savedChapter;
      globalIndex.value = AppConstants.biblePageIndex;
    }

    final bibleController = Get.find<BibleController>();
    await bibleController.loadChapter(
        bookSelected.value, selectedChapter.value);

    if (keepScreenOn.value) WakelockPlus.enable();

    // Warm the cross-reference index off the critical path so the first tap on
    // "Refs" does not pay a 3.5MB parse.
    unawaited(CrossReferenceService.ensureLoaded()
        .catchError((Object e, StackTrace s) {
      ErrorReporter.recordHandled(e, s, context: 'cross-reference index');
    }));
    unawaited(RedLetterService.load().catchError((Object e, StackTrace s) {
      ErrorReporter.recordHandled(e, s, context: 'red-letter ranges');
    }));
  }

  /// Loads the selected translation, falling back to the bundled KJV if the
  /// stored one is missing or corrupt. A downloaded file can be truncated by a
  /// crash mid-write, and without this the app would fail identically on every
  /// launch with no way out from the UI.
  Future<void> _loadBibleData() async {
    loadError.value = null;
    final retired = _retiredVersion;
    if (retired != null) {
      _retiredVersion = null;
      try {
        await VersionService.delete(retired);
      } catch (_) {
        // Best effort — the fallback to KJV has already happened.
      }
    }
    try {
      await BibleService.initialize(this);
      return;
    } catch (e, stack) {
      ErrorReporter.recordHandled(e, stack,
          context: 'load ${bibleVersion.value}');
    }

    if (bibleVersion.value != AppConstants.defaultBibleVersion) {
      // The stored translation is unusable — drop it and recover on KJV, which
      // ships in the app bundle and cannot go missing.
      final failed = bibleVersion.value;
      try {
        await VersionService.delete(failed);
      } catch (_) {
        // Best effort: if the file cannot be removed we still switch away.
      }
      bibleVersion.value = AppConstants.defaultBibleVersion;
      await StorageService.setSetting('bibleVersions', bibleVersion.value);
      try {
        await BibleService.initialize(this);
        loadError.value =
            'That translation could not be opened, so the King James Version '
            'was restored. Download it again from Settings to retry.';
        return;
      } catch (e, stack) {
        ErrorReporter.recordHandled(e, stack, context: 'load kjv fallback');
      }
    }

    loadError.value =
        'The Bible text could not be loaded. Please reinstall the app.';
  }

  /// Retries the load after a failure, for the reader's Retry button.
  Future<void> retryLoad() async {
    await _loadBibleData();
    if (loadError.value == null || BibleService.isInitialized) {
      await Get.find<BibleController>()
          .loadChapter(bookSelected.value, selectedChapter.value);
    }
    update();
  }

  void _loadSettings() {
    themePref.value = _loadThemePref();
    themeMode.value = _isEffectiveDark(themePref.value);
    bibleVersion.value = StorageService.getSetting(
        'bibleVersions', AppConstants.defaultBibleVersion);
    if (!VersionService.catalog.any((v) => v.abbrev == bibleVersion.value)) {
      // A version that has been withdrawn from the catalog (the mislabelled
      // French "Darby" shipped as English) would otherwise keep loading from
      // disk and rendering empty books. Drop it and fall back to KJV.
      _retiredVersion = bibleVersion.value;
      bibleVersion.value = AppConstants.defaultBibleVersion;
      StorageService.setSetting('bibleVersions', bibleVersion.value);
    }
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
    redLetterEnabled.value = StorageService.getSetting('redLetter', true);
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
      return (15 + oldOffset)
          .clamp(AppConstants.minFontSize, AppConstants.maxFontSize);
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
        return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
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
    final seed = AppColors.themeColors[colorThemeName.value] ??
        AppColors.themeColors['Sapphire']!;
    final lightScheme =
        ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
    final darkScheme =
        ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
    // Not the raw seed: several seeds (Sunset Amber, Ocean Cyan, Warm Coral…)
    // sit at 1.6-2.4:1 against the light surface, well under the 4.5:1 needed
    // for body text. The tonal primary lands every theme near 6.2:1.
    _lightAccent = lightScheme.primary;
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
        barTitle.value = bookSelected.value;
        if (Get.isRegistered<BibleController>()) {
          Get.find<BibleController>().loadChapters(bookSelected.value);
        }
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
    update();
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

  void toggleRedLetter(bool value) {
    redLetterEnabled.value = value;
    StorageService.setSetting('redLetter', value);
    update();
  }

  /// True when words of Christ should be coloured: the user wants them and the
  /// active translation is the one the ranges were built for.
  bool get showRedLetter =>
      redLetterEnabled.value &&
      bibleVersion.value == AppConstants.defaultBibleVersion;

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
