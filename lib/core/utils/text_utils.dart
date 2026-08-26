class TextUtils {
  static String formatVerseReference(String book, int chapter, int verse) {
    return '$book $chapter:$verse';
  }

  static String formatChapterReference(String book, int chapter) {
    return '$book $chapter';
  }

  static List<String> parseVerseKey(String key) {
    final parts = key.split(':');
    return parts.length >= 3 ? parts : [];
  }

  static String cleanNotesText(String text) {
    return text.replaceAll('[', '').replaceAll(']', '');
  }

  /// Whether a note's stored verse-key list (e.g. "[John:1:1, John:1:2]")
  /// references [verseKey] exactly. A plain substring check would wrongly
  /// match "John:1:1" against "John:1:10".
  static bool noteReferencesVerse(String storedKeys, String verseKey) {
    return cleanNotesText(storedKeys)
        .split(',')
        .map((k) => k.trim())
        .contains(verseKey);
  }

  /// Formats verse keys as a compact human reference, collapsing runs of
  /// consecutive verses: ["Genesis:1:1", "Genesis:1:2", "Genesis:1:3"]
  /// becomes "Genesis 1:1-3". Different books/chapters are separated with
  /// semicolons: "Genesis 1:1-2; Exodus 2:5".
  static String formatVerseKeysCompact(List<String> verseKeys) {
    final refs = <({String book, int chapter, int verse})>[];
    for (final key in verseKeys) {
      final parts = parseVerseKey(key);
      if (parts.length < 3) continue;
      final chapter = int.tryParse(parts[parts.length - 2]);
      final verse = int.tryParse(parts.last);
      if (chapter == null || verse == null) continue;
      final book = parts.sublist(0, parts.length - 2).join(':');
      refs.add((book: book, chapter: chapter, verse: verse));
    }
    if (refs.isEmpty) return '';

    // Keep books in first-selected order, but sort verses within a book.
    final bookOrder = <String, int>{};
    for (final ref in refs) {
      bookOrder.putIfAbsent(ref.book, () => bookOrder.length);
    }
    refs.sort((a, b) {
      if (a.book != b.book) {
        return bookOrder[a.book]!.compareTo(bookOrder[b.book]!);
      }
      if (a.chapter != b.chapter) return a.chapter.compareTo(b.chapter);
      return a.verse.compareTo(b.verse);
    });

    final buffer = StringBuffer();
    String? runBook;
    int? runChapter;
    int? runStart;
    int? runEnd;

    void flushRun() {
      if (runBook == null) return;
      if (buffer.isNotEmpty) buffer.write('; ');
      buffer.write('$runBook $runChapter:$runStart');
      if (runEnd != runStart) buffer.write('-$runEnd');
    }

    for (final ref in refs) {
      final continuesRun = ref.book == runBook &&
          ref.chapter == runChapter &&
          ref.verse == (runEnd ?? -2) + 1;
      if (continuesRun) {
        runEnd = ref.verse;
      } else {
        flushRun();
        runBook = ref.book;
        runChapter = ref.chapter;
        runStart = ref.verse;
        runEnd = ref.verse;
      }
    }
    flushRun();

    return buffer.toString();
  }
}
