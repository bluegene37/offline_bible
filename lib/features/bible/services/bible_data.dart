import '../models/book_model.dart';

/// Parsed Bible content with pre-built indexes so chapter lookups are O(1)
/// instead of scanning every verse in the Bible.
class BibleData {
  final List<Book> verses;
  final Map<String, Map<int, List<Book>>> byBookChapter;
  final Map<String, int> chapterCounts;

  const BibleData({
    required this.verses,
    required this.byBookChapter,
    required this.chapterCounts,
  });

  static BibleData fromFlatJson(List<dynamic> json) {
    final verses = json
        .map((x) => Book.fromJson(x as Map<String, dynamic>))
        .toList(growable: false);
    return fromVerses(verses);
  }

  static BibleData fromVerses(List<Book> verses) {
    final byBookChapter = <String, Map<int, List<Book>>>{};
    final chapterCounts = <String, int>{};

    for (final verse in verses) {
      final chapters = byBookChapter.putIfAbsent(verse.book, () => {});
      chapters.putIfAbsent(verse.chapter, () => []).add(verse);
      if (verse.chapter > (chapterCounts[verse.book] ?? 0)) {
        chapterCounts[verse.book] = verse.chapter;
      }
    }

    return BibleData(
      verses: verses,
      byBookChapter: byBookChapter,
      chapterCounts: chapterCounts,
    );
  }

  List<Book> chapterVerses(String book, int chapter) {
    return byBookChapter[book]?[chapter] ?? const [];
  }

  int chapterCount(String book) => chapterCounts[book] ?? 1;
}
