import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../bible/controllers/bible_controller.dart';

class BibleSearchController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxBool hideHistory = false.obs;
  final RxList<Map<String, dynamic>> searchHistory =
      <Map<String, dynamic>>[].obs;
  final RxString searchScope = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSearchHistory();
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  /// Most recent searches only. Unbounded history was both a slow read and a
  /// list nobody scrolls to the bottom of.
  static const int _maxHistoryEntries = 50;

  void _loadSearchHistory() {
    final historyMap = StorageService.historyBox.toMap();
    // Keys are monotonic, so insertion order is chronological — newest first.
    searchHistory.value = historyMap.entries
        .map((entry) => {'id': entry.key, 'query': entry.value})
        .toList()
        .reversed
        .toList();
  }

  void performSearch(String query) {
    if (query.trim().isEmpty) return;

    searchQuery.value = query;
    hideHistory.value = true;

    final bibleController = Get.find<BibleController>();
    bibleController.searchVerses(query, scope: searchScope.value);

    _saveToHistory(query);
  }

  void clearSearch(BuildContext context) {
    searchQuery.value = '';
    textController.clear();
    hideHistory.value = false;

    final appController = Get.find<AppController>();
    appController.barTitle.value = "Search";

    SystemChannels.textInput.invokeMethod('TextInput.hide');
    FocusScope.of(context).unfocus();
  }

  void updateQuery(String query) {
    if (query.isEmpty) {
      searchQuery.value = query;
      hideHistory.value = false;
    }
  }

  void _saveToHistory(String query) {
    final box = StorageService.historyBox;

    // Drop any earlier entry for the same query so it re-enters as newest.
    final duplicateKeys = box
        .toMap()
        .entries
        .where((entry) => entry.value == query)
        .map((entry) => entry.key)
        .toList();
    for (final key in duplicateKeys) {
      box.delete(key);
    }

    // A unique key, not a timestamp: two searches within the same second used
    // to collide and overwrite one another.
    box.put(DateUtils.generateUniqueId(), query);

    if (box.length > _maxHistoryEntries) {
      final excess = box.keys.take(box.length - _maxHistoryEntries).toList();
      for (final key in excess) {
        box.delete(key);
      }
    }

    _loadSearchHistory();
  }

  void selectHistoryItem(String query) {
    searchQuery.value = query;
    textController.text = query;
    hideHistory.value = true;

    final bibleController = Get.find<BibleController>();
    bibleController.searchVerses(query, scope: searchScope.value);

    _saveToHistory(query);
  }

  void deleteHistoryItem(String key) {
    StorageService.historyBox.delete(key);
    _loadSearchHistory();
  }

  void clearAllHistory() {
    StorageService.historyBox.clear();
    _loadSearchHistory();
  }

  void setSearchScope(String scope) {
    searchScope.value = scope;
    if (searchQuery.isNotEmpty) {
      performSearch(searchQuery.value);
    }
  }
}
