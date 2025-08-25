import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/text_utils.dart';

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
  }

  void loadNotes() {
    notes.value = StorageService.notesBox.values.toList();
    filteredNotes.value = notes;
  }

  void loadHighlights() {
    highlights.value = StorageService.textsBox.values.toList();
  }

  void filterNotes(String query) {
    if (query.trim().isEmpty) {
      filteredNotes.value = notes;
      return;
    }

    final lowerQuery = query.toLowerCase();
    filteredNotes.value = notes.where((note) {
      final noteText = note['notes']?.toString().toLowerCase() ?? '';
      final bookText = TextUtils.cleanNotesText(note['book']?.toString() ?? '').toLowerCase();
      return noteText.contains(lowerQuery) || bookText.contains(lowerQuery);
    }).toList();
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
      existingNote['stamp'] = DateTime.now().toString();
      StorageService.notesBox.put(noteId, existingNote);
      loadNotes();
    }
  }
}