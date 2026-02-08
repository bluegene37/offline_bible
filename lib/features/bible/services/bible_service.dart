import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../models/book_model.dart';

class BibleService {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  // Initialize the service by loading data from assets
  static Future<void> initialize(AppController controller) async {
    if (_isInitialized) return;

    try {
      // Load and parse Bible data from assets
      final bibleData = await rootBundle.loadString('assets/kjv.json');
      final List<dynamic> bibleJson = json.decode(bibleData);
      controller.cachedBibleData =
          bibleJson.map((x) => Book.fromJson(x)).toList();

      // Load and parse book titles from assets
      final bookTitlesData =
          await rootBundle.loadString('assets/booktitle.json');
      final List<dynamic> titlesJson = json.decode(bookTitlesData);
      controller.cachedBookTitles =
          titlesJson.map((x) => BookTitle.fromJson(x)).toList();

      _isInitialized = true;
    } catch (e) {
      // print('Error loading Bible data: $e');
    }
  }

  Future<List<Book>> getVerses(String bookTitle, int chapter) async {
    final AppController controller = Get.find();
    if (controller.cachedBibleData.isEmpty) {
      // Retry initialization if empty (e.g. hot reload or race condition)
      await initialize(controller);
      if (controller.cachedBibleData.isEmpty) {
        throw Exception('Bible data not loaded');
      }
    }

    final verses = controller.cachedBibleData
        .where((verse) => verse.book == bookTitle && verse.chapter == chapter)
        .toList();

    // Update last chapter count (optimization: calculate only if needed or store pre-calculated)
    // For now, we filter again or we can optimization later.
    // Optimization: filtering the whole bible for one book is okay but maybe we can optimize this too.
    // Let's keep it simple for now but using the list.
    final allChapters =
        controller.cachedBibleData.where((x) => x.book == bookTitle);

    // Efficiently find max chapter
    int maxChapter = 1;
    for (final b in allChapters) {
      if (b.chapter > maxChapter) maxChapter = b.chapter;
    }

    // Update the controller with last chapter info
    controller.lastChapter = maxChapter;

    return verses;
  }

  Future<List<Book>> getChapters(String bookTitle) async {
    final AppController controller = Get.find();
    if (controller.cachedBibleData.isEmpty) {
      await initialize(controller);
    }

    // This logic extracts first verse of each chapter to represent the chapter?
    // Or just all verses?
    // The original code:
    // final allChapters = body.map<Book>((json) => Book.fromJson(json)).toList();
    // final bookChapters = allChapters.where((x) => x.book == bookTitle).toList();
    // final uniqueChapters = <int, Book>{}; ...
    // Note: This seems to just get one Book object per chapter to list them.

    final bookChapters =
        controller.cachedBibleData.where((x) => x.book == bookTitle);

    final uniqueChapters = <int, Book>{};
    for (final chapter in bookChapters) {
      if (!uniqueChapters.containsKey(chapter.chapter)) {
        uniqueChapters[chapter.chapter] = chapter;
      }
    }

    return uniqueChapters.values.toList()
      ..sort((a, b) => a.chapter.compareTo(b.chapter));
  }

  Future<List<BookTitle>> getBookTitles(String testament) async {
    final AppController controller = Get.find();
    if (controller.cachedBookTitles.isEmpty) {
      await initialize(controller);
    }

    if (testament == 'all') {
      return controller.cachedBookTitles;
    }

    return controller.cachedBookTitles
        .where((book) => book.testament == testament)
        .toList();
  }

  Future<List<Book>> searchVerses(String query, {String scope = 'All'}) async {
    final AppController controller = Get.find();
    if (controller.cachedBibleData.isEmpty || query.trim().isEmpty) {
      return [];
    }

    final lowerQuery = query.toLowerCase().trim();
    Set<String>? allowedBooks;

    if (scope != 'All') {
      final testament = scope == 'Old Testament' ? 'old' : 'new';
      allowedBooks = controller.cachedBookTitles
          .where((b) => b.testament == testament)
          .map((b) => b.key)
          .toSet();
    }

    return controller.cachedBibleData.where((verse) {
      if (allowedBooks != null && !allowedBooks.contains(verse.book)) {
        return false;
      }
      return verse.text.toLowerCase().contains(lowerQuery) ||
          (verse.book.toLowerCase().contains(lowerQuery) &&
              verse.chapter == 1 &&
              verse.verse == 1);
    }).toList();
  }
}
