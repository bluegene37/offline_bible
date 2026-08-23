import 'package:flutter_test/flutter_test.dart';
import 'package:offline_bible/core/utils/date_utils.dart';

void main() {
  group('Stored timestamps', () {
    test('are written as ISO-8601 so they survive a locale change', () {
      final stored = DateUtils.timestampNow();
      expect(DateTime.tryParse(stored), isNotNull);
    });

    test('round-trip through parseDateTime', () {
      final before = DateTime.now();
      final parsed = DateUtils.parseDateTime(DateUtils.timestampNow());
      expect(parsed, isNotNull);
      expect(
        parsed!.difference(before).inSeconds.abs(),
        lessThanOrEqualTo(1),
      );
    });

    test('still parse the legacy localized format', () {
      // Written by builds before the ISO switch; these records must keep
      // sorting correctly rather than collapsing to "unparseable".
      final legacy = DateUtils.formatDateTime(DateTime(2024, 3, 5, 14, 30, 15));
      final parsed = DateUtils.parseDateTime(legacy);
      expect(parsed, isNotNull);
      expect(parsed!.year, 2024);
      expect(parsed.month, 3);
      expect(parsed.day, 5);
    });

    test('unparseable input is shown verbatim rather than dropped', () {
      expect(DateUtils.formatForDisplay('not a date'), 'not a date');
      expect(DateUtils.formatForDisplay(null), '');
    });
  });

  group('Record ids', () {
    test('are unique within the same millisecond', () {
      // The old scheme had tenth-of-a-second resolution, so two notes saved
      // in quick succession shared an id and one overwrote the other.
      final ids = List.generate(500, (_) => DateUtils.generateUniqueId());
      expect(ids.toSet().length, ids.length);
    });
  });
}
