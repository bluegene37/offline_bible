import 'package:hive_ce_flutter/adapters.dart';
import '../constants/app_constants.dart';

class StorageService {
  static late Box _settingsBox;
  static late Box _highlightBox;
  static late Box _historyBox;
  static late Box _notesBox;
  static late Box _textsBox;
  static late Box _bookmarksBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
    _highlightBox = await Hive.openBox(AppConstants.highlightBox);
    _historyBox = await Hive.openBox(AppConstants.historyBox);
    _notesBox = await Hive.openBox(AppConstants.notesBox);
    _textsBox = await Hive.openBox(AppConstants.textsBox);
    _bookmarksBox = await Hive.openBox(AppConstants.bookmarksBox);
  }

  // Settings operations
  static T getSetting<T>(String key, T defaultValue) {
    return _settingsBox.get(key, defaultValue: defaultValue);
  }

  static Future<void> setSetting<T>(String key, T value) async {
    await _settingsBox.put(key, value);
  }

  // Highlight operations
  static Box get highlightBox => _highlightBox;
  static Box get historyBox => _historyBox;
  static Box get notesBox => _notesBox;
  static Box get textsBox => _textsBox;
  static Box get bookmarksBox => _bookmarksBox;

  // Clear all data (for debugging)
  static Future<void> clearAll() async {
    await _settingsBox.clear();
    await _highlightBox.clear();
    await _historyBox.clear();
    await _notesBox.clear();
    await _textsBox.clear();
    await _bookmarksBox.clear();
  }
}