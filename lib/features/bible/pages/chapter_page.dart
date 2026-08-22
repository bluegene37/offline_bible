import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/bible_controller.dart';

class ChapterPage extends StatelessWidget {
  const ChapterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();

    return Scaffold(
      body: GetBuilder<BibleController>(
        builder: (controller) {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.chapterList.isEmpty) {
            return const Center(child: Text('No chapters found'));
          }

          return _buildChapterGrid(controller.chapterList, appController);
        },
      ),
    );
  }

  Widget _buildChapterGrid(List chapters, AppController appController) {
    return GetBuilder<AppController>(
      builder: (controller) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
          ),
          itemCount: chapters.length,
          itemBuilder: (context, index) {
            final chapter = chapters[index];
            final isSelected =
                controller.selectedChapter.value == chapter.chapter;

            return GridTile(
              child: InkWell(
                onTap: () => _selectChapter(chapter.chapter, controller),
                child: Container(
                  margin: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? (controller.activeThemeShade)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        chapter.chapter.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: isSelected
                              ? (controller.themeMode.value ? Colors.white : Colors.black)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _selectChapter(int chapterNumber, AppController controller) {
    final bibleController = Get.find<BibleController>();
    bibleController.loadChapter(controller.bookSelected.value, chapterNumber);
    controller.updateBookSelection(
      controller.bookSelected.value,
      chapterNumber,
    );
    controller.navigateToPage(AppConstants.biblePageIndex); // Navigate to Bible page
  }
}
