import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outline_search_bar/outline_search_bar.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/text_utils.dart';
import '../../../core/utils/ui_utils.dart';
import '../controllers/notes_controller.dart';
import 'note_editor_sheet.dart';

class NotesList extends StatelessWidget {
  const NotesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final notesController = Get.find<NotesController>();

    return Column(
      children: [
        _buildSearchBar(appController, notesController, context),
        Expanded(
          child: GetBuilder<NotesController>(
            builder: (controller) {
              if (controller.filteredNotes.isEmpty) {
                return const Center(child: Text('No notes found'));
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: controller.filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = controller.filteredNotes[index];
                  final noteId = note['id'] as String;

                  return _buildNoteCard(
                      note, noteId, appController, notesController);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(AppController appController,
      NotesController notesController, BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        return OutlineSearchBar(
          focusNode: FocusNode(),
          clearButtonColor: _getSearchBarColor(controller),
          cursorColor: _getSearchBarColor(controller),
          searchButtonIconColor: _getSearchBarColor(controller),
          borderColor: _getSearchBarColor(controller),
          margin: const EdgeInsets.all(8.0),
          textEditingController: notesController.searchController,
          hintText: 'Search notes...',
          onSearchButtonPressed: (query) => notesController.filterNotes(query),
          onClearButtonPressed: (query) =>
              _clearSearch(notesController, context),
        );
      },
    );
  }

  Widget _buildNoteCard(Map note, String noteId, AppController appController,
      NotesController notesController) {
    final verseText = TextUtils.formatMultipleVerses(
        TextUtils.cleanNotesText(note['book']?.toString() ?? '').split(','));

    return GetBuilder<AppController>(
      builder: (controller) {
        final isDarkMode = controller.themeMode.value;
        // In dark mode, ensure text is white/light. In light mode, use black or user choice.
        // For UI lists, standardizing on Black/White is usually better than the reader setting.
        final textColor = isDarkMode ? Colors.white : Colors.black87;
        final cardColor = isDarkMode ? Colors.grey[800] : null;

        return Card(
          color: cardColor,
          child: ListTile(
            title: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$verseText - ${appController.bibleVersion}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const TextSpan(text: '\n\n'),
                  TextSpan(
                    text: "  ${note['notes']}",
                    style: TextStyle(
                      color: textColor,
                    ),
                  ),
                  const TextSpan(text: '\n\n'),
                  TextSpan(
                    text: note['stamp']?.toString() ?? '',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            trailing:
                _buildPopupMenu(noteId, note, notesController, isDarkMode),
          ),
        );
      },
    );
  }

  Widget _buildPopupMenu(String noteId, Map note,
      NotesController notesController, bool isDarkMode) {
    return PopupMenuButton<String>(
      icon:
          Icon(Icons.more_vert, color: isDarkMode ? Colors.white : Colors.grey),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
      onSelected: (value) =>
          _handleMenuAction(value, noteId, note, notesController),
    );
  }

  Color _getSearchBarColor(AppController controller) {
    return AppColors.themeColors[controller.colorThemeName.value]!;
  }

  void _clearSearch(NotesController notesController, BuildContext context) {
    notesController.searchController.clear();
    notesController.filterNotes('');
    FocusScope.of(context).unfocus();
  }

  void _handleMenuAction(
      String action, String noteId, Map note, NotesController notesController) {
    switch (action) {
      case 'edit':
        _showEditDialog(noteId, note, notesController);
        break;
      case 'delete':
        UiUtils.showConfirmationDialog(
          title: 'Delete Note?',
          content: 'This action cannot be undone.',
          onConfirm: () => notesController.deleteNote(noteId),
        );
        break;
    }
  }

  void _showEditDialog(
      String noteId, Map note, NotesController notesController) {
    // Parse verses back from string if possible, or just pass noteId
    Get.bottomSheet(
      NoteEditorSheet(
        verseKeys: [], // Logic to parse keys or just load by ID
        existingNoteId: noteId,
        initialText: note['notes']?.toString(),
      ),
      isScrollControlled: true,
    );
  }
}
