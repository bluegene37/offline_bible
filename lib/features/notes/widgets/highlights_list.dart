import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/utils/ui_utils.dart';
import '../../bible/controllers/bible_controller.dart';
import '../controllers/notes_controller.dart';

class HighlightsList extends StatelessWidget {
  const HighlightsList({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final notesController = Get.find<NotesController>();

    return GetBuilder<NotesController>(
      builder: (controller) {
        if (controller.highlights.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.highlight_alt,
                    size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No highlights yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Highlight verses to reflect on them later.',
                  style: TextStyle(color: Colors.grey.shade500),
                )
              ],
            ),
          );
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

  Widget _buildHighlightCard(
      Map<String, dynamic> highlight,
      String highlightKey,
      AppController appController,
      NotesController notesController) {
    // A stored index can outlive the palette it was written against, so clamp
    // rather than index blindly — an out-of-range value used to take down the
    // whole list, not just one card.
    final rawColorIndex = highlight['color'];
    final colorIndex = rawColorIndex is int ? rawColorIndex : 0;
    final highlightColor =
        (colorIndex >= 0 && colorIndex < AppColors.highlightColors.length)
            ? AppColors.highlightColors[colorIndex]
            : AppColors.highlightColors[0];

    return GetBuilder<AppController>(
      builder: (controller) {
        return Card(
          // Apply the highlight color to the entire card for consistent contrast
          color: highlightColor,
          child: ListTile(
            title: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: ' $highlightKey - '
                        '${NotesController.versionOfNote(highlight, appController.bibleVersion.value)} ',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const TextSpan(text: '\n'),
                  TextSpan(
                    text: highlight['text']?.toString() ?? '',
                    style: const TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                  const TextSpan(text: '\n'),
                  TextSpan(
                    text: du.DateUtils.formatForDisplay(
                        highlight['datetime']?.toString()),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
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

      appController
          .navigateToPage(AppConstants.biblePageIndex); // Switch to Bible tab
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
