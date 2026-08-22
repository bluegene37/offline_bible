import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../controllers/notes_controller.dart';
import '../widgets/notes_list.dart';
import '../widgets/highlights_list.dart';
import '../widgets/bookmarks_list.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final notesController = Get.find<NotesController>();

    return Scaffold(
      body: Column(
        children: [
          _buildTabHeader(appController, notesController),
          Expanded(
            child: GetBuilder<NotesController>(
              builder: (controller) {
                switch (controller.currentTab.value) {
                  case 0:
                    return const NotesList(); // Safe default instead of endless spinner
                  case 1:
                    return const HighlightsList();
                  case 2:
                    return const NotesList();
                  case 3:
                    return const BookmarksList();
                  default:
                    return const NotesList();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabHeader(
      AppController appController, NotesController notesController) {
    return GetBuilder<NotesController>(
      builder: (notesCtrl) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 2, label: Text('Notes')),
              ButtonSegment(value: 1, label: Text('Highlights')),
              ButtonSegment(value: 3, label: Text('Bookmarks')),
            ],
            selected: {notesCtrl.currentTab.value},
            onSelectionChanged: (Set<int> newSelection) {
              notesController.switchTab(newSelection.first);
            },
          ),
        );
      },
    );
  }
}
