import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../models/book_model.dart';
import 'bible_data.dart';
import 'version_service.dart';

class BibleService {
  static BibleData? _data;
  static List<BookTitle> _bookTitles = [];
  static String _loadedVersion = '';
  static bool _initFailed = false;
  static Completer<void>? _readyCompleter;

  static bool get isInitialized => _data != null;
  static bool get initFailed => _initFailed;
  static String get loadedVersion => _loadedVersion;

  /// Completes when the current initialize/switch finishes (with an error if
  /// loading failed), so callers can await instead of polling.
  static Future<void> get ready =>
      _readyCompleter?.future ?? Future.value();

  // Initialize the service by loading data from assets or a downloaded file
  static Future<void> initialize(AppController controller) async {
    if (_data != null && _loadedVersion == controller.bibleVersion.value) {
      return;
    }
    await _load(controller.bibleVersion.value);
  }

  /// Loads [abbrev], falling back to the bundled KJV if its file is missing.
  static Future<void> switchVersion(String abbrev) async {
    if (!await VersionService.isAvailable(abbrev)) {
      abbrev = 'kjv';
    }
    await _load(abbrev);
  }

  static Future<void> _load(String abbrev) async {
    final completer = Completer<void>();
    _readyCompleter = completer;
    try {
      _initFailed = false;

      final String rawJson;
      if (VersionService.byAbbrev(abbrev).bundled) {
        rawJson = await rootBundle.loadString('assets/kjv.json');
      } else {
        rawJson = await (await VersionService.versionFile(abbrev))
            .readAsString();
      }

      // Parse and index off the UI thread; the KJV JSON alone is ~6.5MB.
      _data = await Isolate.run(
          () => BibleData.fromFlatJson(json.decode(rawJson)));
      _loadedVersion = abbrev;

      if (_bookTitles.isEmpty) {
        final bookTitlesData =
            await rootBundle.loadString('assets/booktitle.json');
        final List<dynamic> titlesJson = json.decode(bookTitlesData);
        _bookTitles = titlesJson.map((x) => BookTitle.fromJson(x)).toList();
      }

      completer.complete();
    } catch (e) {
      _initFailed = true;
      completer.completeError(e);
      rethrow;
    }
  }

  Future<List<Book>> getVerses(String bookTitle, int chapter) async {
    final data = await _requireData();
    Get.find<AppController>().lastChapter = data.chapterCount(bookTitle);
    return data.chapterVerses(bookTitle, chapter);
  }

  Future<List<Book>> getChapters(String bookTitle) async {
    final data = await _requireData();
    final chapters = data.byBookChapter[bookTitle];
    if (chapters == null) return [];
    final firstVerses = chapters.values
        .where((verses) => verses.isNotEmpty)
        .map((verses) => verses.first)
        .toList()
      ..sort((a, b) => a.chapter.compareTo(b.chapter));
    return firstVerses;
  }

  Future<List<BookTitle>> getBookTitles(String testament) async {
    await _requireData();
    if (testament == 'all') {
      return _bookTitles;
    }
    return _bookTitles.where((book) => book.testament == testament).toList();
  }

  Future<List<Book>> searchVerses(String query, {String scope = 'All'}) async {
    if (query.trim().isEmpty) return [];
    final data = await _requireData();

    final lowerQuery = query.toLowerCase().trim();
    Set<String>? allowedBooks;

    if (scope != 'All') {
      final testament = scope == 'Old Testament' ? 'old' : 'new';
      allowedBooks = _bookTitles
          .where((b) => b.testament == testament)
          .map((b) => b.key)
          .toSet();
    }

    return data.verses.where((verse) {
      if (allowedBooks != null && !allowedBooks.contains(verse.book)) {
        return false;
      }
      return verse.text.toLowerCase().contains(lowerQuery) ||
          (verse.book.toLowerCase().contains(lowerQuery) &&
              verse.chapter == 1 &&
              verse.verse == 1);
    }).toList();
  }

  Future<BibleData> _requireData() async {
    if (_data == null) {
      await initialize(Get.find<AppController>());
    }
    final data = _data;
    if (data == null) {
      throw Exception('Bible data not loaded');
    }
    return data;
  }
}
