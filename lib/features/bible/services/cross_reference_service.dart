import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/services.dart';

/// A single cross-reference target: a verse, or a run of verses in one chapter.
class CrossReference {
  final String book;
  final int chapter;
  final int startVerse;
  final int endVerse;

  const CrossReference({
    required this.book,
    required this.chapter,
    required this.startVerse,
    required this.endVerse,
  });

  bool get isRange => endVerse > startVerse;

  /// "Colossians 1:16-17"
  String get label =>
      '$book $chapter:$startVerse${isRange ? '-$endVerse' : ''}';

  /// Parses the compact stored form: "Book:chapter:start" or
  /// "Book:chapter:start-end". Book names may themselves contain no colons.
  static CrossReference? parse(String raw) {
    final parts = raw.split(':');
    if (parts.length < 3) return null;
    final book = parts.sublist(0, parts.length - 2).join(':');
    final chapter = int.tryParse(parts[parts.length - 2]);
    final verses = parts.last.split('-');
    final start = int.tryParse(verses.first);
    if (chapter == null || start == null) return null;
    final end = verses.length > 1 ? int.tryParse(verses[1]) ?? start : start;
    return CrossReference(
      book: book,
      chapter: chapter,
      startVerse: start,
      endVerse: end,
    );
  }
}

/// Treasury-of-Scripture-Knowledge style cross-references, from the
/// openbible.info dataset (CC-BY). Loaded lazily: it is a ~3.5MB asset and
/// most sessions never open the panel.
class CrossReferenceService {
  static Map<String, List<String>>? _index;
  static Future<void>? _loading;

  static bool get isLoaded => _index != null;

  static Future<void> ensureLoaded() {
    if (_index != null) return Future.value();
    return _loading ??= _load();
  }

  static Future<void> _load() async {
    final raw = await rootBundle.loadString('assets/cross_references.json');
    // Decoding 3.5MB of JSON on the UI thread drops frames; the parse is
    // pure so it moves to an isolate cleanly.
    _index = await Isolate.run(() {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(
            key,
            (value as List<dynamic>).map((e) => e.toString()).toList(),
          ));
    });
  }

  /// Cross-references for a verse key ("John:3:16"), best-voted first.
  /// Returns an empty list when the verse has none, which is common.
  static Future<List<CrossReference>> forVerse(String verseKey) async {
    await ensureLoaded();
    final raw = _index?[verseKey];
    if (raw == null) return const [];
    return raw
        .map(CrossReference.parse)
        .whereType<CrossReference>()
        .toList(growable: false);
  }

  /// Synchronous peek, for callers that only want to know whether to offer the
  /// panel. False before the index has loaded.
  static bool hasReferences(String verseKey) =>
      _index?.containsKey(verseKey) ?? false;
}
