import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outline_search_bar/outline_search_bar.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/text_utils.dart';
import '../controllers/notes_controller.dart';

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
                  final noteKeys = controller.notes.keys.toList();
                  final noteId = noteKeys[index];

                  return _buildNoteCard(note, noteId, appController, notesController);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(AppController appController, NotesController notesController,
                        BuildContext context) {
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
          onClearButtonPressed: (query) => _clearSearch(notesController, context),
        );
      },
    );
  }

  Widget _buildNoteCard(Map note, String noteId, AppController appController,
                       NotesController notesController) {
    final verseText = TextUtils.formatMultipleVerses(
      TextUtils.cleanNotesText(note['book']?.toString() ?? '').split(',')
    );

    return GetBuilder<AppController>(
      builder: (controller) {
        return Card(
          child: ListTile(
            title: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$verseText - ${appController.bibleVersion}',
                    style: TextStyle(
                      color: AppColors.textColors[controller.textColorIdx.value],
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const TextSpan(text: '\n\n'),
                  TextSpan(
                    text: "  ${note['notes']}",
                    style: TextStyle(
                      color: AppColors.textColors[controller.textColorIdx.value],
                    ),
                  ),
                  const TextSpan(text: '\n\n'),
                  TextSpan(
                    text: note['stamp']?.toString() ?? '',
                    style: TextStyle(
                      color: AppColors.textColors[controller.textColorIdx.value],
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            trailing: _buildPopupMenu(noteId, note, notesController),
          ),
        );
      },
    );
  }

  Widget _buildPopupMenu(String noteId, Map note, NotesController notesController) {
    return PopupMenuButton<String>(
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
      onSelected: (value) => _handleMenuAction(value, noteId, note, notesController),
    );
  }

  Color _getSearchBarColor(AppController controller) {
    return controller.colorSliderIdx.value == 0
        ? AppColors.textColors[controller.textColorIdx.value]
        : AppColors.themeColors[controller.colorSliderIdx.value];
  }

  void _clearSearch(NotesController notesController, BuildContext context) {
    notesController.searchController.clear();
    notesController.filterNotes('');
    FocusScope.of(context).unfocus();
  }

  void _handleMenuAction(String action, String noteId, Map note, 
                        NotesController notesController) {
    switch (action) {
      case 'edit':
        _showEditDialog(noteId, note, notesController);
        break;
      case 'delete':
        _showDeleteDialog(noteId, notesController);
        break;
    }
  }

  void _showEditDialog(String noteId, Map note, NotesController notesController) {
    final editController = TextEditingController(text: note['notes']?.toString() ?? '');
    
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Note'),
        content: TextField(
          controller: editController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Enter your notes...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              notesController.updateNote(noteId, editController.text);
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String noteId, NotesController notesController) {
    Get.dialog(
      CupertinoAlertDialog(
        title: const Text('Delete Note?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              notesController.deleteNote(noteId);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}