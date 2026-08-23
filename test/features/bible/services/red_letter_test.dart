import 'package:flutter_test/flutter_test.dart';
import 'package:offline_bible/features/bible/services/red_letter_service.dart';

void main() {
  group('RedLetterService.spansFor', () {
    test('returns nothing before the ranges are loaded', () {
      expect(RedLetterService.spansFor('John:3:16', 100), isEmpty);
    });

    test('returns nothing for a verse with no words of Christ', () {
      expect(RedLetterService.spansFor('Genesis:1:1', 55), isEmpty);
    });
  });
}
