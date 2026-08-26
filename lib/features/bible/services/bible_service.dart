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
  static Future<void> get ready => _readyCompleter?.future ?? Future.value();

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
    // Nothing may be awaiting `ready` at the moment this fails, and a
    // completer future carrying an unobserved error escalates to an unhandled
    // zone error on top of the exception the caller already gets.
    completer.future.catchError((Object _) {});
    _readyCompleter = completer;
    try {
      _initFailed = false;

      final String rawJson;
      if (VersionService.byAbbrev(abbrev).bundled) {
        rawJson = await rootBundle.loadString('assets/kjv.json');
      } else {
        rawJson =
            await (await VersionService.versionFile(abbrev)).readAsString();
      }

      // Parse and index off the UI thread; the KJV JSON alone is ~6.5MB.
      _data = await Isolate.run(
          () => BibleData.fromFlatJson(json.decode(rawJson) as List<dynamic>));
      _loadedVersion = abbrev;

      if (_bookTitles.isEmpty) {
        final bookTitlesData =
            await rootBundle.loadString('assets/booktitle.json');
        final titlesJson = json.decode(bookTitlesData) as List<dynamic>;
        _bookTitles = titlesJson
            .map((x) => BookTitle.fromJson(x as Map<String, dynamic>))
            .toList();
      }

      completer.complete();
    } catch (e) {
      _initFailed = true;
      completer.completeError(e);
      rethrow;
    }
  }

  /// One verse from the loaded translation, or null if the data is not ready
  /// or that reference does not exist in this translation. Synchronous because
  /// the lookup is an index hit, not I/O.
  static Book? verseOrNull(String bookTitle, int chapter, int verse) {
    final data = _data;
    if (data == null) return null;
    for (final candidate in data.chapterVerses(bookTitle, chapter)) {
      if (candidate.verse == verse) return candidate;
    }
    return null;
  }

  Future<List<Book>> getVerses(String bookTitle, int chapter) async {
    final data = await _requireData();
    Get.find<AppController>().lastChapter = data.chapterCount(bookTitle);
    return data.chapterVerses(bookTitle, chapter);
  }

  /// A single verse from the active translation, or null if the reference
  /// does not exist in it (verse numbering differs slightly between versions).
  Future<Book?> getVerse(String bookTitle, int chapter, int verse) async {
    final data = await _requireData();
    for (final candidate in data.chapterVerses(bookTitle, chapter)) {
      if (candidate.verse == verse) return candidate;
    }
    return null;
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

  /// Verses scanned between yields. Sized so each slice stays well inside a
  /// frame budget on a low-end device, letting the loading spinner animate
  /// instead of freezing for the length of the scan.
  static const int _searchChunkSize = 4000;

  Future<List<Book>> searchVerses(String query, {String scope = 'All'}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];
    final data = await _requireData();

    // A case-insensitive RegExp matches as fast as pre-lowercasing every verse
    // but without retaining a second ~8MB copy of the whole Bible.
    final matcher = RegExp(RegExp.escape(trimmed), caseSensitive: false);

    Set<String>? allowedBooks;
    if (scope != 'All') {
      final testament = scope == 'Old Testament' ? 'old' : 'new';
      allowedBooks = _bookTitles
          .where((b) => b.testament == testament)
          .map((b) => b.key)
          .toSet();
    }

    final verses = data.verses;
    final results = <Book>[];
    for (var start = 0; start < verses.length; start += _searchChunkSize) {
      final end = (start + _searchChunkSize).clamp(0, verses.length);
      for (var i = start; i < end; i++) {
        final verse = verses[i];
        if (allowedBooks != null && !allowedBooks.contains(verse.book)) {
          continue;
        }
        // Matching the book name only on its first verse gives searches like
        // "Romans" a single jump-to-book result instead of every verse in it.
        if (matcher.hasMatch(verse.text) ||
            (verse.chapter == 1 &&
                verse.verse == 1 &&
                matcher.hasMatch(verse.book))) {
          results.add(verse);
        }
      }
      if (end < verses.length) await Future<void>.delayed(Duration.zero);
    }
    return results;
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
