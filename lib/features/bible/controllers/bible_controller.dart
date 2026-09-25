import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/bible_audio_handler.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/utils/date_utils.dart';
import '../models/book_model.dart';
import '../services/bible_service.dart';
import '../../notes/controllers/notes_controller.dart';

class BibleController extends GetxController {
  final AppController appController = Get.find<AppController>();
  final BibleService _bibleService = BibleService();
  final BibleAudioHandler _audio = Get.find<BibleAudioHandler>();

  ItemScrollController itemScrollController = ItemScrollController();
  ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final TextEditingController notesController = TextEditingController();

  final RxList<Book> currentVerses = <Book>[].obs;
  final RxList<Book> searchResults = <Book>[].obs;
  final RxList<Book> chapterList = <Book>[].obs;
  final RxDouble bottomPadding = 0.0.obs;
  final RxBool isLoading = false.obs;

  // TTS Audio State
  final RxBool isAudioPlaying = false.obs;
  final RxBool isAudioPaused = false.obs;
  final RxInt activeAudioVerseIndex = (-1).obs;
  final RxDouble audioSpeechRate = 0.5.obs;

  int? pendingScrollVerseIndex;

  @override
  void onInit() {
    super.onInit();
    _setupScrollListener();
    final savedRate = StorageService.getSetting('audioSpeechRate', 0.5);
    audioSpeechRate.value = savedRate;
    TtsService().setRate(savedRate);

    // Playback can also be driven from the lock screen or a headset button,
    // so the reader mirrors the handler rather than owning the state.
    _audio.onVerseChanged = (index) {
      activeAudioVerseIndex.value = index;
      jumpToVerse(index);
      update();
    };
    _audio.onStateChanged = (state) {
      isAudioPlaying.value = state == TtsState.playing;
      isAudioPaused.value = state == TtsState.paused;
      if (state == TtsState.stopped) activeAudioVerseIndex.value = -1;
      update();
    };
  }

  @override
  void onClose() {
    stopAudio();
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

  // Audio. All of it goes through the media session so the lock screen,
  // headset buttons and the in-app bar stay in agreement.
  Future<void> toggleChapterAudio() async {
    if (isAudioPlaying.value) {
      await _audio.pause();
    } else {
      await _audio.play();
    }
  }

  Future<void> startChapterAudio({int startIndex = 0}) async {
    if (currentVerses.isEmpty) return;
    _publishChapterToAudio();
    await _audio.startFrom(startIndex);
  }

  Future<void> pauseAudio() => _audio.pause();

  Future<void> resumeAudio() => _audio.play();

  Future<void> stopAudio() async {
    await _audio.stop();
    isAudioPlaying.value = false;
    isAudioPaused.value = false;
    activeAudioVerseIndex.value = -1;
    update();
  }

  Future<void> skipToNextVerse() => _audio.skipToNext();

  Future<void> skipToPreviousVerse() => _audio.skipToPrevious();

  Future<void> setAudioRate(double rate) async {
    audioSpeechRate.value = rate;
    StorageService.setSetting('audioSpeechRate', rate);
    await TtsService().setRate(rate);
    update();
  }

  /// Hands the loaded chapter to the media session so the notification and
  /// lock screen show the right reference before playback starts.
  void _publishChapterToAudio() {
    _audio.setChapter(
      verses: currentVerses
          .map((v) => 'Verse ${v.verse}. ${v.text}')
          .toList(growable: false),
      reference:
          '${appController.bookSelected.value} ${appController.selectedChapter.value}',
      version: appController.bibleVersion.value,
    );
  }

  void deleteHighlight(String verseKey) {
    deleteHighlights([verseKey]);
  }

  void deleteHighlights(List<String> verseKeys) {
    for (final key in verseKeys) {
      StorageService.highlightBox.delete(key);
      StorageService.textsBox.delete(key);
    }
    appController.clearTextSelection();
    if (Get.isRegistered<NotesController>()) {
      Get.find<NotesController>().loadHighlights();
    }
    appController.update();
  }


  /// True when [book]/[chapter] is already the loaded chapter, so a rebuild
  /// does not need to reload (which would reset scroll and stop audio).
  bool isChapterLoaded(String book, int chapter) {
    return currentVerses.isNotEmpty &&
        appController.bookSelected.value == book &&
        appController.selectedChapter.value == chapter &&
        currentVerses.first.book == book &&
        currentVerses.first.chapter == chapter;
  }

  Future<void> loadChapter(String book, int chapter) async {
    stopAudio();
    // Wait for the Bible data to finish loading; getVerses retries and
    // reports the error if initialization failed.
    try {
      await BibleService.ready;
    } catch (_) {}
    try {
      isLoading.value = true;
      _resetScrollControllers();
      final verses = await _bibleService.getVerses(book, chapter);
      currentVerses.value = verses;
      appController.updateBookSelection(book, chapter);
      _publishChapterToAudio();
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
    appController.update();
  }

  void saveHighlight(List<String> verseKeys, int colorIndex) {
    if (colorIndex == -1) {
      deleteHighlights(verseKeys);
      return;
    }
    final timestamp = DateUtils.timestampNow();

    for (final key in verseKeys) {
      StorageService.highlightBox.put(key, colorIndex);

      final verse = currentVerses
          .firstWhereOrNull((v) => '${v.book}:${v.chapter}:${v.verse}' == key);

      if (verse != null) {
        final highlightData = {
          'datetime': timestamp,
          'text': verse.text,
          'version': appController.bibleVersion.value,
          'color': colorIndex,
        };
        StorageService.textsBox.put(key, highlightData);
      }
    }

    appController.clearTextSelection();
    if (Get.isRegistered<NotesController>()) {
      Get.find<NotesController>().loadHighlights();
    }
    appController.update();
  }

  void saveNotes(List<String> verseKeys, String notes) {
    final timestamp = DateUtils.timestampNow();
    final noteId = DateUtils.generateUniqueId();

    final noteData = {
      // 'verses' is the canonical reference list; 'book' keeps the legacy
      // stringified format so data written by newer builds stays readable
      // if the app is downgraded.
      'verses': verseKeys,
      'book': verseKeys.toString(),
      'stamp': timestamp,
      'notes': notes,
      // The translation the note was written against. Without it the list
      // labelled every note with whatever version happened to be loaded, so
      // switching translations silently relabelled the whole history.
      'version': appController.bibleVersion.value,
    };

    StorageService.notesBox.put(noteId, noteData);
    appController.clearTextSelection();
    notesController.clear();
    // Refresh verse tiles so the note icon appears immediately
    appController.update();
    if (Get.isRegistered<NotesController>()) {
      Get.find<NotesController>().loadNotes();
    }
  }

  void toggleBookmarks(List<String> verseKeys) {
    final timestamp = DateUtils.timestampNow();
    int added = 0;

    for (final key in verseKeys) {
      if (StorageService.bookmarksBox.containsKey(key)) {
        StorageService.bookmarksBox.delete(key);
      } else {
        final verse = currentVerses.firstWhereOrNull(
            (v) => '${v.book}:${v.chapter}:${v.verse}' == key);
        if (verse != null) {
          final bookmarkData = {
            'datetime': timestamp,
            'text': verse.text,
            'version': appController.bibleVersion.value,
            'book': verse.book,
            'chapter': verse.chapter,
            'verse': verse.verse,
          };
          StorageService.bookmarksBox.put(key, bookmarkData);
          added++;
        }
      }
    }

    appController.clearTextSelection();
    Get.snackbar('Bookmarks',
        added > 0 ? 'Added to bookmarks' : 'Removed from bookmarks',
        snackPosition: SnackPosition.BOTTOM);
    appController.update();
    if (Get.isRegistered<NotesController>()) {
      Get.find<NotesController>().loadBookmarks();
    }
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
    SharePlus.instance.share(ShareParams(text: text));
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
          '${firstVerse.book} ${firstVerse.chapter} (${appController.bibleVersion.value})\n');
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
