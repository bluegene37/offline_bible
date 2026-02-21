import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/notes_controller.dart';
import '../widgets/notes_list.dart';
import '../widgets/highlights_list.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({Key? key}) : super(key: key);

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
                    return const Center(child: CircularProgressIndicator());
                  case 1:
                    return const HighlightsList();
                  case 2:
                    return const NotesList();
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
            color: AppColors.themeColorShades[controller.colorThemeName.value],
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
                          ? AppColors
                              .themeColors[controller.colorThemeName.value]
                          : AppColors.themeColorShades[
                              controller.colorThemeName.value],
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
                          ? AppColors
                              .themeColors[controller.colorThemeName.value]
                          : AppColors.themeColorShades[
                              controller.colorThemeName.value],
                    ),
                    onPressed: () => notesController.switchTab(1),
                    child: const Text('Highlights'),
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
