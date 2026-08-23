import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notes_controller.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../core/utils/ui_utils.dart'; // For showConfirmationDialog

class BookmarksList extends StatelessWidget {
  const BookmarksList({super.key});

  @override
  Widget build(BuildContext context) {
    final notesController = Get.find<NotesController>();
    final appController = Get.find<AppController>();

    return Obx(() {
      if (notesController.bookmarks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bookmark_border, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No bookmarks yet',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bookmark verses to quickly find them later.',
                style: TextStyle(color: Colors.grey.shade500),
              )
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: notesController.bookmarks.length,
        itemBuilder: (context, index) {
          final bookmark = notesController.bookmarks[index];
          final String key = bookmark['id']?.toString() ?? '';
          final String text = bookmark['text']?.toString() ?? '';
          final String date =
              du.DateUtils.formatForDisplay(bookmark['datetime']?.toString());
          final String book = bookmark['book']?.toString() ?? '';
          final int chapter = bookmark['chapter'] is int
              ? bookmark['chapter'] as int
              : 0;
          final int verse =
              bookmark['verse'] is int ? bookmark['verse'] as int : 0;
          final String reference = '$book $chapter:$verse';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () {
                appController.navigateToVerse(book, chapter, verse);
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            reference,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: appController.activeThemeColor,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () {
                            UiUtils.showConfirmationDialog(
                              title: 'Delete Bookmark',
                              content: 'Are you sure you want to delete this bookmark?',
                              onConfirm: () => notesController.deleteBookmark(key),
                            );
                          },
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      text,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
