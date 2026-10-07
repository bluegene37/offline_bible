import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:offline_bible/core/constants/app_constants.dart';
import 'package:offline_bible/core/controllers/app_controller.dart';
import 'package:offline_bible/core/services/bible_audio_handler.dart';
import 'package:offline_bible/core/services/storage_service.dart';
import 'package:offline_bible/features/bible/controllers/bible_controller.dart';
import 'package:offline_bible/features/bible/models/book_model.dart';
import 'package:offline_bible/features/notes/controllers/notes_controller.dart';

class TestAudioHandler extends BibleAudioHandler {
  @override
  void setChapter({
    required List<String> verses,
    required String reference,
    required String version,
  }) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Box<dynamic> highlightBox;
  late Box<dynamic> textsBox;
  late Box<dynamic> settingsBox;
  late Box<dynamic> notesBox;
  late Box<dynamic> bookmarksBox;
  late AppController appController;
  late NotesController notesController;
  late BibleController bibleController;

  setUp(() async {
    Get.reset();
    tempDir = await Directory.systemTemp.createTemp('highlight_test_');
    Hive.init(tempDir.path);

    highlightBox = await Hive.openBox(AppConstants.highlightBox);
    textsBox = await Hive.openBox(AppConstants.textsBox);
    settingsBox = await Hive.openBox(AppConstants.settingsBox);
    notesBox = await Hive.openBox(AppConstants.notesBox);
    bookmarksBox = await Hive.openBox(AppConstants.bookmarksBox);

    StorageService.initForTesting(
      highlightBox: highlightBox,
      textsBox: textsBox,
      settingsBox: settingsBox,
      notesBox: notesBox,
      bookmarksBox: bookmarksBox,
    );

    appController = Get.put(AppController());
    Get.put<BibleAudioHandler>(TestAudioHandler());
    bibleController = Get.put(BibleController());
    notesController = Get.put(NotesController());

    // Provide mock verses
    bibleController.currentVerses.assignAll([
      const Book(
          id: '1',
          book: 'John',
          chapter: 3,
          verse: 16,
          text: 'For God so loved the world...'),
      const Book(
          id: '2',
          book: 'John',
          chapter: 3,
          verse: 17,
          text: 'For God sent not his Son...'),
    ]);
  });

  tearDown(() async {
    Get.reset();
    await highlightBox.close();
    await textsBox.close();
    await settingsBox.close();
    await notesBox.close();
    await bookmarksBox.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Highlight removal and real-time update', () {
    test('clearTextSelection clears selection and triggers update', () {
      appController.textUnderline.addAll(['John:3:16', 'John:3:17']);
      expect(appController.textUnderline.length, equals(2));

      var updateCalled = false;
      appController.addListener(() {
        updateCalled = true;
      });

      appController.clearTextSelection();
      expect(appController.textUnderline, isEmpty);
      expect(updateCalled, isTrue);
    });

    test('toggleVerseSelection toggles selection and triggers update', () {
      var updateCount = 0;
      appController.addListener(() {
        updateCount++;
      });

      bibleController.toggleVerseSelection('John:3:16');
      expect(appController.textUnderline, contains('John:3:16'));
      expect(updateCount, equals(1));

      bibleController.toggleVerseSelection('John:3:16');
      expect(appController.textUnderline, isNot(contains('John:3:16')));
      expect(updateCount, equals(2));
    });

    test(
        'saveHighlight with valid color saves and notifies appController real time',
        () {
      appController.textUnderline.add('John:3:16');

      var updateCalled = false;
      appController.addListener(() {
        updateCalled = true;
      });

      bibleController.saveHighlight(['John:3:16'], 2);

      expect(highlightBox.get('John:3:16'), equals(2));
      expect(textsBox.containsKey('John:3:16'), isTrue);
      expect(notesController.highlightColorFor('John:3:16'), equals(2));
      expect(appController.textUnderline, isEmpty);
      expect(updateCalled, isTrue);
    });

    test(
        'deleteHighlights removes highlights and notifies appController real time',
        () {
      // Setup highlight first
      bibleController.saveHighlight(['John:3:16', 'John:3:17'], 2);
      expect(notesController.highlightColorFor('John:3:16'), equals(2));
      expect(notesController.highlightColorFor('John:3:17'), equals(2));

      // Select them
      appController.textUnderline.addAll(['John:3:16', 'John:3:17']);

      var updateCalled = false;
      appController.addListener(() {
        updateCalled = true;
      });

      bibleController.deleteHighlights(['John:3:16', 'John:3:17']);

      expect(highlightBox.containsKey('John:3:16'), isFalse);
      expect(highlightBox.containsKey('John:3:17'), isFalse);
      expect(textsBox.containsKey('John:3:16'), isFalse);
      expect(textsBox.containsKey('John:3:17'), isFalse);
      expect(notesController.highlightColorFor('John:3:16'), isNull);
      expect(notesController.highlightColorFor('John:3:17'), isNull);
      expect(appController.textUnderline, isEmpty);
      expect(updateCalled, isTrue);
    });

    test(
        'saveHighlight with -1 (no color) delegates to deleteHighlights and updates real time',
        () {
      // Setup highlight first
      bibleController.saveHighlight(['John:3:16'], 3);
      expect(notesController.highlightColorFor('John:3:16'), equals(3));

      // Select verse
      appController.textUnderline.add('John:3:16');

      var updateCalled = false;
      appController.addListener(() {
        updateCalled = true;
      });

      // User taps "no color highlight" (-1)
      bibleController.saveHighlight(['John:3:16'], -1);

      expect(highlightBox.containsKey('John:3:16'), isFalse);
      expect(textsBox.containsKey('John:3:16'), isFalse);
      expect(notesController.highlightColorFor('John:3:16'), isNull);
      expect(appController.textUnderline, isEmpty);
      expect(updateCalled, isTrue);
    });
  });
}
