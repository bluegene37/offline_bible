import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/notes_controller.dart';
import '../../bible/pages/bible_page.dart';

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
            final highlightKeys = controller.highlights.keys.toList();
            final highlightKey = highlightKeys[index];

            return _buildHighlightCard(
              highlight, 
              highlightKey, 
              appController, 
              notesController
            );
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

  Widget _buildHighlightPopupMenu(String highlightKey, NotesController notesController) {
    return PopupMenuButton<String>(
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'goto', child: Text('Go to verse')),
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
      onSelected: (value) => _handleHighlightMenuAction(
        value, 
        highlightKey, 
        notesController
      ),
    );
  }

  void _navigateToHighlight(String highlightKey, AppController appController) {
    final parts = highlightKey.split(':');
    if (parts.length >= 3) {
      final bookTitle = parts[0];
      final chapter = int.tryParse(parts[1]) ?? 1;
      final verse = int.tryParse(parts[2]) ?? 1;

      appController.updateBookSelection(bookTitle, chapter);
      appController.navigateToPage(2);

      Get.to(() => BiblePage(bookTitle: bookTitle, chapter: chapter));
    }
  }

  void _handleHighlightMenuAction(String action, String highlightKey,
                                 NotesController notesController) {
    switch (action) {
      case 'goto':
        _navigateToHighlight(highlightKey, Get.find<AppController>());
        break;
      case 'delete':
        _showDeleteHighlightDialog(highlightKey, notesController);
        break;
    }
  }

  void _showDeleteHighlightDialog(String highlightKey, NotesController notesController) {
    Get.dialog(
      CupertinoAlertDialog(
        title: const Text('Delete Highlight?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              notesController.deleteHighlight(highlightKey);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}