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

  static String formatMultipleVerses(List<String> verses) {
    if (verses.isEmpty) return '';
    
    final firstVerse = verses.first;
    final parts = parseVerseKey(firstVerse);
    if (parts.isEmpty) return '';
    
    String result = firstVerse;
    for (int i = 1; i < verses.length; i++) {
      final verseParts = parseVerseKey(verses[i]);
      if (verseParts.isNotEmpty) {
        result += ', ${verseParts.last}';
      }
    }
    return result;
  }
}