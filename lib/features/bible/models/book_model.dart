class Book {
  final String id;
  final String book;
  final int chapter;
  final int verse;
  final String text;

  const Book({
    required this.id,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['book_id'] ?? '',
      book: json['book_name'] ?? '',
      chapter: json['chapter'] ?? 0,
      verse: json['verse'] ?? 0,
      text: json['text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_id': id,
      'book_name': book,
      'chapter': chapter,
      'verse': verse,
      'text': text,
    };
  }

  String get verseKey => '$book:$chapter:$verse';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Book &&
        other.id == id &&
        other.book == book &&
        other.chapter == chapter &&
        other.verse == verse;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        book.hashCode ^
        chapter.hashCode ^
        verse.hashCode;
  }
}

class BookTitle {
  final String testament;
  final String key;
  final String val;

  const BookTitle({
    required this.testament,
    required this.key,
    required this.val,
  });

  factory BookTitle.fromJson(Map<String, dynamic> json) {
    return BookTitle(
      testament: json['testament'] ?? '',
      key: json['key'] ?? '',
      val: json['val'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'testament': testament,
      'key': key,
      'val': val,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookTitle &&
        other.testament == testament &&
        other.key == key &&
        other.val == val;
  }

  @override
  int get hashCode {
    return testament.hashCode ^ key.hashCode ^ val.hashCode;
  }
}