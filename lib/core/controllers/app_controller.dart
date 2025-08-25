import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';

class AppController extends GetxController {
  // Observable variables
  final RxString barTitle = AppConstants.appName.obs;
  final RxString bookSelected = AppConstants.defaultBook.obs;
  final RxInt selectedChapter = AppConstants.defaultChapter.obs;
  final RxString searchQuery = ''.obs;
  final RxInt globalIndex = AppConstants.biblePageIndex.obs;
  final RxInt colorSliderIdx = AppConstants.defaultColorIndex.obs;
  final RxInt textColorIdx = AppConstants.defaultTextColorIndex.obs;
  final RxString globalFont = AppConstants.defaultFont.obs;
  final RxDouble fontSize = AppConstants.defaultFontSize.obs;
  final RxBool themeMode = false.obs;
  final RxBool hideFloatingBtn = false.obs;
  final RxBool showAds = true.obs;
  final RxList<String> textUnderline = <String>[].obs;
  final Rx<Color> textColorDynamic = Colors.black.obs;

  // Non-reactive variables
  String bibleVersion = AppConstants.defaultBibleVersion;
  int lastChapter = 1;
  bool refreshChapter = false;
  String bookSelectedHist = '';
  int selectedChapterHist = 0;
  String searchResultHist = '';
  int globalFontIdx = 8;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _updateTextColor();
  }

  void _loadSettings() {
    themeMode.value = StorageService.getSetting('themeMode', false);
    bibleVersion = StorageService.getSetting('bibleVersions', AppConstants.defaultBibleVersion);
    bookSelected.value = StorageService.getSetting('bookSelected', AppConstants.defaultBook);
    selectedChapter.value = StorageService.getSetting('selectedChapter', AppConstants.defaultChapter);
    colorSliderIdx.value = StorageService.getSetting('colorSliderIdx', AppConstants.defaultColorIndex);
    textColorIdx.value = StorageService.getSetting('textColorIdx', AppConstants.defaultTextColorIndex);
    globalFont.value = StorageService.getSetting('globalFont', AppConstants.defaultFont);
    globalFontIdx = StorageService.getSetting('globalFontIdx', 8);
    fontSize.value = StorageService.getSetting('fontSize', AppConstants.defaultFontSize);
  }

  void _updateTextColor() {
    final brightness = ThemeData.estimateBrightnessForColor(
      AppColors.themeColors[colorSliderIdx.value]
    );
    textColorDynamic.value = brightness == Brightness.light ? Colors.black : Colors.white;
  }

  void updateColorTheme(int index) {
    colorSliderIdx.value = index;
    StorageService.setSetting('colorSliderIdx', index);
    _updateTextColor();
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
  }

  void updateBookSelection(String book, int chapter) {
    bookSelected.value = book;
    selectedChapter.value = chapter;
    StorageService.setSetting('bookSelected', book);
    StorageService.setSetting('selectedChapter', chapter);
    barTitle.value = '$book $chapter';
  }

  void navigateToPage(int index) {
    globalIndex.value = index;
    textUnderline.clear();
  }

  void clearTextSelection() {
    textUnderline.clear();
  }
}