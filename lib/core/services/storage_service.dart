import 'package:hive_ce_flutter/adapters.dart';
import '../constants/app_constants.dart';

class StorageService {
  static late Box<dynamic> _settingsBox;
  static late Box<dynamic> _highlightBox;
  static late Box<dynamic> _historyBox;
  static late Box<dynamic> _notesBox;
  static late Box<dynamic> _textsBox;
  static late Box<dynamic> _bookmarksBox;
  static late Box<dynamic> _readingPlansBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
    _highlightBox = await Hive.openBox(AppConstants.highlightBox);
    _historyBox = await Hive.openBox(AppConstants.historyBox);
    _notesBox = await Hive.openBox(AppConstants.notesBox);
    _textsBox = await Hive.openBox(AppConstants.textsBox);
    _bookmarksBox = await Hive.openBox(AppConstants.bookmarksBox);
    _readingPlansBox = await Hive.openBox(AppConstants.readingPlansBox);
  }

  /// Reads a setting, falling back to [defaultValue] when the stored value is
  /// absent *or* of an unexpected type. Hive is untyped, so a value written by
  /// an older build with a different shape would otherwise throw on read.
  static T getSetting<T>(String key, T defaultValue) {
    final dynamic value = _settingsBox.get(key);
    return value is T ? value : defaultValue;
  }

  static Future<void> setSetting<T>(String key, T value) async {
    await _settingsBox.put(key, value);
  }

  static Box<dynamic> get highlightBox => _highlightBox;
  static Box<dynamic> get historyBox => _historyBox;
  static Box<dynamic> get notesBox => _notesBox;
  static Box<dynamic> get textsBox => _textsBox;
  static Box<dynamic> get bookmarksBox => _bookmarksBox;
  static Box<dynamic> get readingPlansBox => _readingPlansBox;
}
