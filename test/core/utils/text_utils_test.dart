import 'package:flutter_test/flutter_test.dart';
import 'package:offline_bible/core/utils/text_utils.dart';

void main() {
  group('TextUtils.noteReferencesVerse', () {
    test('matches a verse key stored in the note', () {
      expect(
        TextUtils.noteReferencesVerse('[John:1:1, John:1:2]', 'John:1:1'),
        isTrue,
      );
      expect(
        TextUtils.noteReferencesVerse('[John:1:1, John:1:2]', 'John:1:2'),
        isTrue,
      );
    });

    test('does not match a verse whose key is a superstring', () {
      expect(
        TextUtils.noteReferencesVerse('[John:1:1]', 'John:1:10'),
        isFalse,
      );
      expect(
        TextUtils.noteReferencesVerse('[John:1:10]', 'John:1:1'),
        isFalse,
      );
    });

    test('does not match unrelated verses', () {
      expect(
        TextUtils.noteReferencesVerse('[Genesis:1:1]', 'John:1:1'),
        isFalse,
      );
    });
  });
}
