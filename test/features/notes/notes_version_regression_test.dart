// Regression: ISSUE-001 — a note's translation label followed the currently
// loaded version instead of the one the note was written against, so switching
// translations silently relabelled every existing note.
// Found by /qa on 2026-08-31
// Report: .gstack/qa-reports/qa-report-offline-bible-2026-08-31.md

import 'package:flutter_test/flutter_test.dart';
import 'package:offline_bible/features/notes/controllers/notes_controller.dart';

void main() {
  group('NotesController.versionOfNote', () {
    test('uses the version the note was written against, not the active one',
        () {
      final note = {
        'verses': ['John:3:16'],
        'notes': 'written while reading the KJV',
        'version': 'kjv',
      };
      // The reader has since been switched to a different translation.
      expect(NotesController.versionOfNote(note, 'asv'), 'KJV');
    });

    test('falls back to the active version for notes saved without one', () {
      final note = {
        'verses': ['John:3:16'],
        'notes': 'saved before the version was recorded',
      };
      expect(NotesController.versionOfNote(note, 'asv'), 'ASV');
    });

    test('treats an empty stored version as absent', () {
      final note = {'notes': 'x', 'version': ''};
      expect(NotesController.versionOfNote(note, 'web'), 'WEB');
    });

    test('treats a whitespace-only stored version as absent', () {
      final note = {'notes': 'x', 'version': '   '};
      expect(NotesController.versionOfNote(note, 'web'), 'WEB');
    });

    test('uppercases for consistency with the reader chip', () {
      final note = {'notes': 'x', 'version': 'basicenglish'};
      expect(NotesController.versionOfNote(note, 'kjv'), 'BASICENGLISH');
    });

    test('a non-string stored version is still rendered', () {
      final note = {'notes': 'x', 'version': 123};
      expect(NotesController.versionOfNote(note, 'kjv'), '123');
    });
  });
}
