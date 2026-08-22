import 'package:flutter_test/flutter_test.dart';
import 'package:offline_bible/features/bible/services/bible_data.dart';
import 'package:offline_bible/features/bible/services/version_service.dart';
import 'dart:convert';

void main() {
  group('BibleData.fromFlatJson', () {
    final json = [
      {'book_id': 'Gen', 'book_name': 'Genesis', 'chapter': 1, 'verse': 1, 'text': 'v1'},
      {'book_id': 'Gen', 'book_name': 'Genesis', 'chapter': 1, 'verse': 2, 'text': 'v2'},
      {'book_id': 'Gen', 'book_name': 'Genesis', 'chapter': 2, 'verse': 1, 'text': 'v3'},
      {'book_id': 'Exo', 'book_name': 'Exodus', 'chapter': 1, 'verse': 1, 'text': 'v4'},
    ];

    test('indexes verses by book and chapter', () {
      final data = BibleData.fromFlatJson(json);
      expect(data.chapterVerses('Genesis', 1).length, 2);
      expect(data.chapterVerses('Genesis', 2).single.text, 'v3');
      expect(data.chapterVerses('Exodus', 1).single.text, 'v4');
      expect(data.chapterVerses('Exodus', 99), isEmpty);
      expect(data.chapterVerses('Unknown', 1), isEmpty);
    });

    test('computes chapter counts', () {
      final data = BibleData.fromFlatJson(json);
      expect(data.chapterCount('Genesis'), 2);
      expect(data.chapterCount('Exodus'), 1);
      expect(data.chapterCount('Unknown'), 1);
    });

    test('keeps all verses for search', () {
      final data = BibleData.fromFlatJson(json);
      expect(data.verses.length, 4);
    });
  });

  group('VersionService.normalizeGetBibleJson', () {
    test('flattens nested books and renames Song of Songs', () {
      final raw = jsonEncode({
        'translation': 'Test Version',
        'books': [
          {
            'nr': 22,
            'name': 'Song of Songs',
            'chapters': [
              {
                'chapter': 1,
                'verses': [
                  {'chapter': 1, 'verse': 1, 'text': ' A song.  '},
                  {'chapter': 1, 'verse': 2, 'text': 'Another verse.'},
                ],
              },
            ],
          },
        ],
      });

      final normalized = VersionService.normalizeGetBibleJson(raw);
      final flat = jsonDecode(normalized) as List;

      expect(flat.length, 2);
      expect(flat[0]['book_name'], 'Song of Solomon');
      expect(flat[0]['chapter'], 1);
      expect(flat[0]['verse'], 1);
      expect(flat[0]['text'], 'A song.');
    });

    test('normalized output loads into BibleData', () {
      final raw = jsonEncode({
        'books': [
          {
            'nr': 1,
            'name': 'Genesis',
            'chapters': [
              {
                'chapter': 1,
                'verses': [
                  {'chapter': 1, 'verse': 1, 'text': 'In the beginning'},
                ],
              },
            ],
          },
        ],
      });

      final data = BibleData.fromFlatJson(
          jsonDecode(VersionService.normalizeGetBibleJson(raw)));
      expect(data.chapterVerses('Genesis', 1).single.text, 'In the beginning');
    });
  });
}
