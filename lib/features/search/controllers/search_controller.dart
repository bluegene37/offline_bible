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
  final RxList searchHistory = [].obs;
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

  void _loadSearchHistory() {
    final historyMap = StorageService.historyBox.toMap();
    searchHistory.value = historyMap.entries.map((entry) {
      return {'id': entry.key, 'query': entry.value};
    }).toList();
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
    final timestamp = DateUtils.formatDateTime(DateTime.now());

    // Remove existing entry if it exists
    String? keyToDelete;
    StorageService.historyBox.toMap().forEach((key, value) {
      if (value == query) {
        keyToDelete = key;
      }
    });

    if (keyToDelete != null) {
      StorageService.historyBox.delete(keyToDelete);
    }

    StorageService.historyBox.put(timestamp, query);
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

  void setSearchScope(String scope) {
    searchScope.value = scope;
    if (searchQuery.isNotEmpty) {
      performSearch(searchQuery.value);
    }
  }
}
