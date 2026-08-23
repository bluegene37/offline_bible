import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:offline_bible/features/bible/services/version_service.dart';

void main() {
  group('Version catalog', () {
    test('abbreviations are unique and every entry names its rights', () {
      final abbrevs = VersionService.catalog.map((v) => v.abbrev).toList();
      expect(abbrevs.toSet().length, abbrevs.length,
          reason: 'duplicate abbrev would make byAbbrev ambiguous');
      for (final version in VersionService.catalog) {
        expect(version.name.trim(), isNotEmpty);
        expect(version.copyright.trim(), isNotEmpty,
            reason: '${version.abbrev} must carry an attribution string');
      }
    });

    test('exactly one bundled version, and it is the default', () {
      final bundled = VersionService.catalog.where((v) => v.bundled).toList();
      expect(bundled.length, 1);
      expect(bundled.single.abbrev, 'kjv');
    });

    test("does not offer getbible's 'darby' slug", () {
      // That slug is the FRENCH Darby (lang=fr). It was listed as an English
      // translation, and since books are looked up by name, 56 of 66 books
      // resolved to nothing ("Genèse" vs "Genesis"). There is no English
      // Darby on the API — do not re-add it.
      expect(
        VersionService.catalog.any((v) => v.abbrev == 'darby'),
        isFalse,
      );
    });

    test('byAbbrev falls back to the bundled version for unknown input', () {
      expect(VersionService.byAbbrev('does-not-exist').abbrev, 'kjv');
    });

    test('every downloadable version is distinct from the bundled one', () {
      // Red-letter ranges are character offsets into the bundled KJV wording.
      // If another version were ever marked bundled they would be applied to
      // text they were not derived from, colouring the wrong words.
      final downloadable =
          VersionService.catalog.where((v) => !v.bundled).map((v) => v.abbrev);
      expect(downloadable, isNot(contains('kjv')));
    });
  });

  group('normalizeGetBibleJson', () {
    test('aligns book naming with the bundled index', () {
      final raw = json.encode({
        'books': [
          {
            'nr': 22,
            'name': 'Song of Songs',
            'chapters': [
              {
                'chapter': 1,
                'verses': [
                  {'chapter': 1, 'verse': 1, 'text': '  The song of songs.  '}
                ]
              }
            ]
          }
        ]
      });

      final flat = json.decode(VersionService.normalizeGetBibleJson(raw))
          as List<dynamic>;
      final verse = flat.single as Map<String, dynamic>;

      expect(verse['book_name'], 'Song of Solomon');
      expect(verse['text'], 'The song of songs.',
          reason: 'surrounding whitespace should be trimmed');
      expect(verse['chapter'], 1);
      expect(verse['verse'], 1);
    });
  });
}
