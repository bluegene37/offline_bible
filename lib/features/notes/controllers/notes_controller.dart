import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/text_utils.dart';
import '../../../core/utils/date_utils.dart' as du;

class NotesController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxInt currentTab = 2.obs;
  final RxList notes = [].obs;
  final RxList highlights = [].obs;
  final RxList filteredNotes = [].obs;

  @override
  void onInit() {
    super.onInit();
    loadNotes();
    loadHighlights();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void switchTab(int tab) {
    currentTab.value = tab;
    update();
  }

  void loadNotes() {
    final Map<dynamic, dynamic> rawNotes = StorageService.notesBox.toMap();
    notes.value = rawNotes.entries.map((entry) {
      final note = Map<String, dynamic>.from(entry.value as Map);
      note['id'] = entry.key.toString();
      return note;
    }).toList();

    // Sort by timestamp descending (newest first)
    notes.sort((a, b) {
      final String? timeA = a['stamp'] as String?;
      final String? timeB = b['stamp'] as String?;

      final dtA = du.DateUtils.parseDateTime(timeA);
      final dtB = du.DateUtils.parseDateTime(timeB);

      if (dtA == null && dtB == null) return 0;
      if (dtA == null) return 1; // Nulls last
      if (dtB == null) return -1;

      return dtB.compareTo(dtA);
    });

    filteredNotes.value = notes;
    update();
  }

  void loadHighlights() {
    final Map<dynamic, dynamic> rawHighlights = StorageService.textsBox.toMap();
    highlights.value = rawHighlights.entries.map((entry) {
      final highlight = Map<String, dynamic>.from(entry.value as Map);
      highlight['id'] = entry.key.toString();
      return highlight;
    }).toList();

    // Sort by timestamp descending
    highlights.sort((a, b) {
      final String? timeA = a['datetime'] as String?;
      final String? timeB = b['datetime'] as String?;

      final dtA = du.DateUtils.parseDateTime(timeA);
      final dtB = du.DateUtils.parseDateTime(timeB);

      if (dtA == null && dtB == null) return 0;
      if (dtA == null) return 1;
      if (dtB == null) return -1;

      return dtB.compareTo(dtA);
    });
    update();
  }

  void filterNotes(String query) {
    if (query.trim().isEmpty) {
      filteredNotes.value = notes;
      update();
      return;
    }

    final lowerQuery = query.toLowerCase();
    filteredNotes.value = notes.where((note) {
      final noteText = note['notes']?.toString().toLowerCase() ?? '';
      final bookText = TextUtils.cleanNotesText(note['book']?.toString() ?? '')
          .toLowerCase();
      return noteText.contains(lowerQuery) || bookText.contains(lowerQuery);
    }).toList();
    update();
  }

  void deleteNote(String noteId) {
    StorageService.notesBox.delete(noteId);
    loadNotes();
  }

  void deleteHighlight(String highlightKey) {
    StorageService.highlightBox.delete(highlightKey);
    StorageService.textsBox.delete(highlightKey);
    loadHighlights();
  }

  void updateNote(String noteId, String newNotes) {
    final existingNote = StorageService.notesBox.get(noteId);
    if (existingNote != null) {
      existingNote['notes'] = newNotes;
      existingNote['stamp'] = du.DateUtils.formatDateTime(DateTime.now());
      StorageService.notesBox.put(noteId, existingNote);
      loadNotes();
    }
  }
}
