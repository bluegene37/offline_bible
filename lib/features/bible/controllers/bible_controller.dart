import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/date_utils.dart';
import '../models/book_model.dart';
import '../services/bible_service.dart';

class BibleController extends GetxController {
  final AppController appController = Get.find<AppController>();
  final BibleService _bibleService = BibleService();

  ItemScrollController itemScrollController = ItemScrollController();
  ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final TextEditingController notesController = TextEditingController();

  final RxList<Book> currentVerses = <Book>[].obs;
  final RxList<Book> searchResults = <Book>[].obs;
  final RxList<Book> chapterList = <Book>[].obs;
  final RxDouble bottomPadding = 0.0.obs;
  final RxDouble sheetHeight = 0.0.obs;
  final RxBool isLoading = false.obs;

  int? pendingScrollVerseIndex;

  @override
  void onInit() {
    super.onInit();
    _setupScrollListener();
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }

  void _resetScrollControllers() {
    itemScrollController = ItemScrollController();
    itemPositionsListener = ItemPositionsListener.create();
    _setupScrollListener();
    update();
  }

  void _setupScrollListener() {
    itemPositionsListener.itemPositions.addListener(() {
      final positions = itemPositionsListener.itemPositions.value;
      if (positions.isNotEmpty) {
        // Navigation button hiding logic removed to keep it always visible
      }
    });
  }

  void deleteHighlight(String verseKey) {
    if (StorageService.highlightBox.containsKey(verseKey)) {
      StorageService.highlightBox.delete(verseKey);
      StorageService.textsBox.delete(verseKey);
    }
  }

  Future<void> loadChapter(String book, int chapter) async {
    while (!BibleService.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    try {
      isLoading.value = true;
      _resetScrollControllers();
      final verses = await _bibleService.getVerses(book, chapter);
      currentVerses.value = verses;
      appController.updateBookSelection(book, chapter);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load chapter: $e');
    } finally {
      isLoading.value = false;

      // Handle pending scroll if any
      if (pendingScrollVerseIndex != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          jumpToVerse(pendingScrollVerseIndex!);
          pendingScrollVerseIndex = null;
        });
      }
    }
  }

  Future<void> loadChapters(String book) async {
    try {
      isLoading.value = true;
      final chapters = await _bibleService.getChapters(book);
      chapterList.value = chapters;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load chapters: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchVerses(String query, {String scope = 'All'}) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isLoading.value = true;
      final results = await _bibleService.searchVerses(query, scope: scope);
      searchResults.value = results;
      _saveSearchHistory(query);

      // Update bar title counter AFTER results are ready
      final count = searchResults.length;
      appController.barTitle.value =
          count > 0 ? 'Search result: $count' : 'Search';

      // Notify GetBuilder listeners that results changed
      update();
    } catch (e) {
      Get.snackbar('Error', 'Search failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _saveSearchHistory(String query) {
    final timestamp = DateUtils.formatDateTime(DateTime.now());

    StorageService.historyBox.toMap().forEach((key, value) {
      if (value == query) {
        StorageService.historyBox.delete(key);
      }
    });

    StorageService.historyBox.put(timestamp, query);
  }

  void jumpToVerse(int verseIndex) {
    if (verseIndex >= 0 && verseIndex < currentVerses.length) {
      if (itemScrollController.isAttached) {
        itemScrollController.jumpTo(index: verseIndex);
      }
    }
  }

  void navigateToNextChapter() {
    if (appController.selectedChapter.value < appController.lastChapter) {
      final nextChapter = appController.selectedChapter.value + 1;
      loadChapter(appController.bookSelected.value, nextChapter);
    }
  }

  void navigateToPreviousChapter() {
    if (appController.selectedChapter.value > 1) {
      final prevChapter = appController.selectedChapter.value - 1;
      loadChapter(appController.bookSelected.value, prevChapter);
    }
  }

  void toggleVerseSelection(String verseKey) {
    if (appController.textUnderline.contains(verseKey)) {
      appController.textUnderline.remove(verseKey);
    } else {
      appController.textUnderline.add(verseKey);
    }
  }

  void saveHighlight(List<String> verseKeys, int colorIndex) {
    final timestamp = DateUtils.formatDateTime(DateTime.now());

    for (final key in verseKeys) {
      StorageService.highlightBox.put(key, colorIndex);

      final verse = currentVerses
          .firstWhereOrNull((v) => '${v.book}:${v.chapter}:${v.verse}' == key);

      if (verse != null) {
        final highlightData = {
          'datetime': timestamp,
          'text': verse.text,
          'version': appController.bibleVersion,
          'color': colorIndex,
        };
        StorageService.textsBox.put(key, highlightData);
      }
    }

    appController.clearTextSelection();
  }

  void saveNotes(List<String> verseKeys, String notes) {
    final timestamp = DateUtils.formatDateTime(DateTime.now());
    final noteId = DateUtils.generateUniqueId().toString();

    final noteData = {
      'book': verseKeys.toString(),
      'stamp': timestamp,
      'notes': notes,
    };

    StorageService.notesBox.put(noteId, noteData);
    appController.clearTextSelection();
    notesController.clear();
    // Refresh verse tiles so the note icon appears immediately
    appController.update();
  }

  void copyVerses(List<String> verseKeys) {
    final text = _formatVerses(verseKeys);
    if (text == null) return;
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar('Copied', 'Verses copied to clipboard');
    appController.clearTextSelection();
  }

  void shareVerses(List<String> verseKeys) {
    final text = _formatVerses(verseKeys);
    if (text == null) return;
    // ignore: deprecated_member_use
    Share.share(text);
    appController.clearTextSelection();
  }

  String? _formatVerses(List<String> verseKeys) {
    if (verseKeys.isEmpty) return null;

    final sortedKeys = List<String>.from(verseKeys)
      ..sort((a, b) {
        final indexA = currentVerses
            .indexWhere((v) => '${v.book}:${v.chapter}:${v.verse}' == a);
        final indexB = currentVerses
            .indexWhere((v) => '${v.book}:${v.chapter}:${v.verse}' == b);
        return indexA.compareTo(indexB);
      });

    final StringBuffer buffer = StringBuffer();
    String? currentBook;
    int? currentChapter;

    final firstKey = sortedKeys.first;
    final firstVerse = currentVerses.firstWhereOrNull(
        (v) => '${v.book}:${v.chapter}:${v.verse}' == firstKey);

    if (firstVerse != null) {
      buffer.writeln(
          '${firstVerse.book} ${firstVerse.chapter} (${appController.bibleVersion})\n');
      currentBook = firstVerse.book;
      currentChapter = firstVerse.chapter;
    }

    for (final key in sortedKeys) {
      final verse = currentVerses
          .firstWhereOrNull((v) => '${v.book}:${v.chapter}:${v.verse}' == key);
      if (verse != null) {
        if (verse.book != currentBook || verse.chapter != currentChapter) {
          buffer.writeln('\n${verse.book} ${verse.chapter}\n');
          currentBook = verse.book;
          currentChapter = verse.chapter;
        }
        buffer.write('[${verse.verse}] ${verse.text} ');
      }
    }
    return buffer.toString().trim();
  }
}
