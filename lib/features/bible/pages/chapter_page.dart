import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/bible_controller.dart';
import '../models/book_model.dart';

class ChapterPage extends StatefulWidget {
  const ChapterPage({super.key});

  @override
  State<ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {
  @override
  void initState() {
    super.initState();
    _ensureChaptersLoaded();
  }

  void _ensureChaptersLoaded() {
    final appController = Get.find<AppController>();
    final bibleController = Get.find<BibleController>();
    if (bibleController.chapterList.isEmpty ||
        bibleController.chapterList.firstOrNull?.book !=
            appController.bookSelected.value) {
      bibleController.loadChapters(appController.bookSelected.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Obx(() {
        final bibleController = Get.find<BibleController>();
        final bookName = appController.bookSelected.value;

        if (bibleController.isLoading.value &&
            bibleController.chapterList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final chapters = bibleController.chapterList;
        if (chapters.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No chapters found'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => bibleController.loadChapters(bookName),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: appController.activeThemeColor
                      .withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        appController.activeThemeColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: appController.activeThemeColor
                            .withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 20,
                        color: appController.activeThemeColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bookName,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${chapters.length} ${chapters.length == 1 ? "Chapter" : "Chapters"} • Select a chapter',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        appController
                            .navigateToPage(AppConstants.booksPageIndex);
                      },
                      icon: const Icon(Icons.swap_horiz, size: 18),
                      label: const Text('Change Book',
                          style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _buildChapterGrid(chapters, appController),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildChapterGrid(List<Book> chapters, AppController appController) {
    return GetBuilder<AppController>(
      builder: (controller) {
        final fontSize = controller.fontSize.value;
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          // Max-extent rather than a fixed column count: at 30pt a six-across
          // grid clips three-digit chapter numbers, so let the columns reflow.
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: fontSize * 2.4 + 15,
            childAspectRatio: 1,
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
                    color: isSelected ? (controller.activeThemeShade) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        chapter.chapter.toString(),
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w300,
                          color: isSelected
                              ? (controller.themeMode.value
                                  ? Colors.white
                                  : Colors.black)
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
    controller
        .navigateToPage(AppConstants.biblePageIndex); // Navigate to Bible page
  }
}
