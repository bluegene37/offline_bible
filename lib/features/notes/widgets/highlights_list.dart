import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_utils.dart';
import '../../bible/controllers/bible_controller.dart';
import '../controllers/notes_controller.dart';

class HighlightsList extends StatelessWidget {
  const HighlightsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final notesController = Get.find<NotesController>();

    return GetBuilder<NotesController>(
      builder: (controller) {
        if (controller.highlights.isEmpty) {
          return const Center(child: Text('No highlights found'));
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: controller.highlights.length,
          itemBuilder: (context, index) {
            final highlight = controller.highlights[index];
            final highlightKey = highlight['id'] as String;

            return _buildHighlightCard(
                highlight, highlightKey, appController, notesController);
          },
        );
      },
    );
  }

  Widget _buildHighlightCard(Map highlight, String highlightKey,
      AppController appController, NotesController notesController) {
    return GetBuilder<AppController>(
      builder: (controller) {
        return Card(
          child: ListTile(
            title: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: " $highlightKey - ${highlight['version']} ",
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const TextSpan(text: '\n'),
                  TextSpan(
                    text: highlight['text']?.toString() ?? '',
                    style: TextStyle(
                      color: controller.textColorDynamic.value == Colors.white
                          ? Colors.black54
                          : Colors.black,
                    ),
                  ),
                  const TextSpan(text: '\n'),
                  TextSpan(
                    text: highlight['datetime']?.toString() ?? '',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            tileColor: AppColors.highlightColors[highlight['color'] ?? 0],
            trailing: _buildHighlightPopupMenu(highlightKey, notesController),
            onTap: () => _navigateToHighlight(highlightKey, appController),
          ),
        );
      },
    );
  }

  Widget _buildHighlightPopupMenu(
      String highlightKey, NotesController notesController) {
    return PopupMenuButton<String>(
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'goto', child: Text('Go to verse')),
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
      onSelected: (value) =>
          _handleHighlightMenuAction(value, highlightKey, notesController),
    );
  }

  void _navigateToHighlight(String highlightKey, AppController appController) {
    final parts = highlightKey.split(':');
    if (parts.length >= 3) {
      final bookTitle = parts[0];
      final chapter = int.tryParse(parts[1]) ?? 1;
      final verse = int.tryParse(parts[2]) ?? 1;

      appController.updateBookSelection(bookTitle, chapter);

      final bibleController = Get.find<BibleController>();

      // Set pending scroll index before loading chapter
      bibleController.pendingScrollVerseIndex = verse - 1;
      bibleController.loadChapter(bookTitle, chapter);

      appController.navigateToPage(2); // Switch to Bible tab
    }
  }

  void _handleHighlightMenuAction(
      String action, String highlightKey, NotesController notesController) {
    switch (action) {
      case 'goto':
        _navigateToHighlight(highlightKey, Get.find<AppController>());
        break;
      case 'delete':
        UiUtils.showConfirmationDialog(
          title: 'Delete Highlight?',
          content: 'This action cannot be undone.',
          onConfirm: () => notesController.deleteHighlight(highlightKey),
        );
        break;
    }
  }
}
