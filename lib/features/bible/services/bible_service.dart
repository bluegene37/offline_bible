import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../models/book_model.dart';

class BibleService {
  static String _cachedBibleData = '';
  static String _cachedBookTitles = '';
  static bool _isInitialized = false;

  // Initialize the service by loading data from assets
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Load Bible data from assets
      final bibleData = await rootBundle.loadString('assets/kjv.json');
      _cachedBibleData = bibleData;
      
      // Load book titles from assets
      final bookTitlesData = await rootBundle.loadString('assets/booktitle.json');
      _cachedBookTitles = bookTitlesData;
      
      _isInitialized = true;
    } catch (e) {
      print('Error loading Bible data: $e');
    }
  }

  Future<List<Book>> getVerses(String bookTitle, int chapter) async {
    await _ensureInitialized();
    
    if (_cachedBibleData.isEmpty) {
      throw Exception('Bible data not loaded');
    }
    
    final List<dynamic> body = json.decode(_cachedBibleData);
    final bookList = body.map<Book>((json) => Book.fromJson(json)).toList();
    final verses = bookList
        .where((verse) => verse.book == bookTitle && verse.chapter == chapter)
        .toList();
    
    // Update last chapter count
    final allChapters = bookList.where((x) => x.book == bookTitle).toList();
    final uniqueChapters = <int>{};
    for (final chapter in allChapters) {
      uniqueChapters.add(chapter.chapter);
    }
    
    // Update the controller with last chapter info
    final bibleController = Get.find<BibleController>();
    bibleController.lastChapter = uniqueChapters.isNotEmpty ? uniqueChapters.reduce((a, b) => a > b ? a : b) : 1;
    
    return verses;
  }

  Future<List<Book>> getChapters(String bookTitle) async {
    await _ensureInitialized();
    
    if (_cachedBibleData.isEmpty) {
      throw Exception('Bible data not loaded');
    }
    
    final List<dynamic> body = json.decode(_cachedBibleData);
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
    await _ensureInitialized();
    
    if (_cachedBookTitles.isEmpty) {
      throw Exception('Book titles not loaded');
    }
    
    final List<dynamic> body = json.decode(_cachedBookTitles);
    final bookTitles = body.map<BookTitle>((json) => BookTitle.fromJson(json)).toList();
    
    if (testament == 'all') {
      return bookTitles;
    }
    
    return bookTitles.where((book) => book.testament == testament).toList();
  }

  Future<List<Book>> searchVerses(String query) async {
    await _ensureInitialized();
    
    if (_cachedBibleData.isEmpty || query.trim().isEmpty) {
      return [];
    }
    
    final List<dynamic> body = json.decode(_cachedBibleData);
    final bookList = body.map<Book>((json) => Book.fromJson(json)).toList();
    final lowerQuery = query.toLowerCase().trim();
    
    return bookList.where((verse) {
      return verse.text.toLowerCase().contains(lowerQuery) ||
             (verse.book.toLowerCase().contains(lowerQuery) && 
              verse.chapter == 1 && verse.verse == 1);
    }).toList();
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }
}