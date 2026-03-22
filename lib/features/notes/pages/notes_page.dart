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
    return GetBuilder<AppController>(
      builder: (controller) {
        return Container(
          height: 50,
          decoration: BoxDecoration(
            color: controller.activeThemeShade,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GetBuilder<NotesController>(
                builder: (notesCtrl) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: controller.textColorDynamic.value,
                      backgroundColor: notesCtrl.currentTab.value == 2
                          ? controller.activeThemeColor
                          : controller.activeThemeShade,
                    ),
                    onPressed: () => notesController.switchTab(2),
                    child: const Text('Notes'),
                  );
                },
              ),
              GetBuilder<NotesController>(
                builder: (notesCtrl) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: controller.textColorDynamic.value,
                      backgroundColor: notesCtrl.currentTab.value == 1
                          ? controller.activeThemeColor
                          : controller.activeThemeShade,
                    ),
                    onPressed: () => notesController.switchTab(1),
                    child: const Text('Highlights'),
                  );
                },
              ),
              GetBuilder<NotesController>(
                builder: (notesCtrl) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: controller.textColorDynamic.value,
                      backgroundColor: notesCtrl.currentTab.value == 3
                          ? controller.activeThemeColor
                          : controller.activeThemeShade,
                    ),
                    onPressed: () => notesController.switchTab(3),
                    child: const Text('Bookmarks'),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
