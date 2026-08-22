import 'package:flutter_test/flutter_test.dart';
import 'package:offline_bible/core/utils/text_utils.dart';
import 'package:offline_bible/features/notes/controllers/notes_controller.dart';

void main() {
  group('NotesController.verseKeysOfNote', () {
    test('reads the current list format', () {
      final note = {
        'verses': ['John:1:1', 'John:1:2'],
        'notes': 'hello',
      };
      expect(NotesController.verseKeysOfNote(note),
          ['John:1:1', 'John:1:2']);
    });

    test('falls back to the legacy stringified format', () {
      final note = {
        'book': '[John:1:1, John:1:2]',
        'notes': 'hello',
      };
      expect(NotesController.verseKeysOfNote(note),
          ['John:1:1', 'John:1:2']);
    });

    test('prefers list format when both are present', () {
      final note = {
        'verses': ['Genesis:1:1'],
        'book': '[John:1:1]',
      };
      expect(NotesController.verseKeysOfNote(note), ['Genesis:1:1']);
    });

    test('returns empty for malformed notes', () {
      expect(NotesController.verseKeysOfNote({'notes': 'x'}), isEmpty);
    });
  });

  group('TextUtils.formatVerseKeysCompact', () {
    test('single verse', () {
      expect(TextUtils.formatVerseKeysCompact(['Genesis:1:1']), 'Genesis 1:1');
    });

    test('collapses consecutive verses into a range', () {
      expect(
        TextUtils.formatVerseKeysCompact(
            ['Genesis:1:1', 'Genesis:1:2', 'Genesis:1:3']),
        'Genesis 1:1-3',
      );
    });

    test('sorts out-of-order selections before collapsing', () {
      expect(
        TextUtils.formatVerseKeysCompact(
            ['Genesis:1:3', 'Genesis:1:1', 'Genesis:1:2']),
        'Genesis 1:1-3',
      );
    });

    test('separates non-consecutive verses', () {
      expect(
        TextUtils.formatVerseKeysCompact(['Genesis:1:1', 'Genesis:1:5']),
        'Genesis 1:1; Genesis 1:5',
      );
    });

    test('separates chapters and books', () {
      expect(
        TextUtils.formatVerseKeysCompact(
            ['Genesis:1:31', 'Genesis:2:1', 'Exodus:2:5']),
        'Genesis 1:31; Genesis 2:1; Exodus 2:5',
      );
    });

    test('handles book names containing numbers', () {
      expect(
        TextUtils.formatVerseKeysCompact(['1 John:1:1', '1 John:1:2']),
        '1 John 1:1-2',
      );
    });

    test('empty and malformed input', () {
      expect(TextUtils.formatVerseKeysCompact([]), '');
      expect(TextUtils.formatVerseKeysCompact(['garbage']), '');
    });
  });
}
