import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../bible/controllers/bible_controller.dart';

class SearchController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxBool hideHistory = false.obs;
  final RxList searchHistory = [].obs;

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
    searchHistory.value = StorageService.historyBox.values.toList();
  }

  void performSearch(String query) {
    if (query.trim().isEmpty) return;

    searchQuery.value = query;
    hideHistory.value = true;
    
    final bibleController = Get.find<BibleController>();
    bibleController.searchVerses(query);
    
    _saveToHistory(query);
    _updateSearchResults();
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
    StorageService.historyBox.toMap().forEach((key, value) {
      if (value == query) {
        StorageService.historyBox.delete(key);
      }
    });
    
    StorageService.historyBox.put(timestamp, query);
    _loadSearchHistory();
  }

  void _updateSearchResults() {
    final appController = Get.find<AppController>();
    final bibleController = Get.find<BibleController>();
    
    if (bibleController.searchResults.isNotEmpty) {
      appController.barTitle.value = 'Search result: ${bibleController.searchResults.length}';
    } else {
      appController.barTitle.value = 'Search';
    }
  }

  void selectHistoryItem(String query) {
    searchQuery.value = query;
    textController.text = query;
    hideHistory.value = true;
    
    final bibleController = Get.find<BibleController>();
    bibleController.searchVerses(query);
    
    _saveToHistory(query);
    _updateSearchResults();
  }

  void deleteHistoryItem(String key) {
    StorageService.historyBox.delete(key);
    _loadSearchHistory();
  }
}