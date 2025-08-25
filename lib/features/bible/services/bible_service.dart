import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/controllers/app_controller.dart';
import '../models/book_model.dart';

class BibleService {
  static String _cachedBibleData = '';
  static String _cachedBookTitles = '';

  Future<List<Book>> getVerses(String bookTitle, int chapter) async {
    if (_cachedBibleData.isEmpty) {
      // This would need to be called with proper context
      // Consider using a different approach for asset loading
      throw Exception('Bible data not loaded');
    }
    
    final body = json.decode(_cachedBibleData);
    final bookList = body.map<Book>(Book.fromJson).toList();
    final verses = bookList
        .where((verse) => verse.book == bookTitle && verse.chapter == chapter)
        .toList();
    
    // Update last chapter count
    final allChapters = bookList.where((x) => x.book == bookTitle).toList();
    final uniqueChapters = <int>{};
    for (final chapter in allChapters) {
      uniqueChapters.add(chapter.chapter);
    }
    
    return verses;
  }

  Future<List<Book>> getChapters(String bookTitle) async {
    if (_cachedBibleData.isEmpty) {
      throw Exception('Bible data not loaded');
    }
    
    final body = json.decode(_cachedBibleData);
    final allChapters = body.map<Book>((json) => Book.fromJson(json)).toList();
    final bookChapters = allChapters.where((x) => x.book == bookTitle).toList();
    
    final uniqueChapters = <int, Book>{};
    for (final chapter in bookChapters) {
      if (!uniqueChapters.containsKey(chapter.chapter)) {
        uniqueChapters[chapter.chapter] = chapter;
      }
    }
    
    return uniqueChapters.values.toList()..sort((a, b) => a.chapter.compareTo(b.chapter));
  }

  Future<List<BookTitle>> getBookTitles(String testament) async {
    if (_cachedBookTitles.isEmpty) {
      throw Exception('Book titles not loaded');
    }
    
    final body = json.decode(_cachedBookTitles);
    final bookTitles = body.map<BookTitle>(BookTitle.fromJson).toList();
    
    if (testament == 'all') {
      return bookTitles;
    }
    
    return bookTitles.where((book) => book.testament == testament).toList();
  }

  Future<List<Book>> searchVerses(String query) async {
    if (_cachedBibleData.isEmpty || query.trim().isEmpty) {
      return [];
    }
    
    final body = json.decode(_cachedBibleData);
    final bookList = body.map<Book>(Book.fromJson).toList();
    final lowerQuery = query.toLowerCase().trim();
    
    return bookList.where((verse) {
      return verse.text.toLowerCase().contains(lowerQuery) ||
             (verse.book.toLowerCase().contains(lowerQuery) && 
              verse.chapter == 1 && verse.verse == 1);
    }).toList();
  }

  // Method to cache bible data - should be called during app initialization
  static void cacheBibleData(String data) {
    _cachedBibleData = data;
  }

  static void cacheBookTitles(String data) {
    _cachedBookTitles = data;
  }
}