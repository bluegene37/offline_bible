import 'package:flutter_test/flutter_test.dart';
import 'package:offline_bible/features/bible/services/cross_reference_service.dart';

void main() {
  group('CrossReference.parse', () {
    test('reads a single verse', () {
      final r = CrossReference.parse('Romans:5:8')!;
      expect(r.book, 'Romans');
      expect(r.chapter, 5);
      expect(r.startVerse, 8);
      expect(r.endVerse, 8);
      expect(r.isRange, isFalse);
      expect(r.label, 'Romans 5:8');
    });

    test('reads a verse range', () {
      final r = CrossReference.parse('Colossians:1:16-17')!;
      expect(r.startVerse, 16);
      expect(r.endVerse, 17);
      expect(r.isRange, isTrue);
      expect(r.label, 'Colossians 1:16-17');
    });

    test('handles book names that contain digits and spaces', () {
      final r = CrossReference.parse('1 John:4:9-10')!;
      expect(r.book, '1 John');
      expect(r.chapter, 4);
      expect(r.label, '1 John 4:9-10');
    });

    test('rejects malformed input rather than throwing', () {
      expect(CrossReference.parse('nonsense'), isNull);
      expect(CrossReference.parse('Romans:notanumber:8'), isNull);
      expect(CrossReference.parse(''), isNull);
    });
  });
}
