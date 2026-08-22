import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../controllers/bible_controller.dart';
import '../widgets/verse_list.dart';
import '../widgets/selection_toolbar.dart';
import '../widgets/audio_player_bar.dart';

class BiblePage extends StatelessWidget {
  final String bookTitle;
  final int chapter;

  const BiblePage({
    super.key,
    required this.bookTitle,
    required this.chapter,
  });

  @override
  Widget build(BuildContext context) {
    final bibleController = Get.find<BibleController>();
    final appController = Get.find<AppController>();

    // Load chapter data when page is built, but skip when this chapter is
    // already loaded — a reload would reset scroll and stop chapter audio.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!bibleController.isChapterLoaded(bookTitle, chapter) ||
          bibleController.pendingScrollVerseIndex != null) {
        bibleController.loadChapter(bookTitle, chapter);
      }
    });

    return Scaffold(
      body: GetBuilder<BibleController>(
        builder: (controller) {
          return GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity == null) return;
              if (details.primaryVelocity! < -300) {
                // Swipe left -> Next chapter
                controller.navigateToNextChapter();
              } else if (details.primaryVelocity! > 300) {
                // Swipe right -> Previous chapter
                controller.navigateToPreviousChapter();
              }
            },
            child: Stack(
              children: [
                // The VerseList is always in the tree
                if (controller.currentVerses.isEmpty &&
                    !controller.isLoading.value)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('No verses found'),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () =>
                              controller.loadChapter(bookTitle, chapter),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else
                  VerseList(
                    key: ValueKey(
                        '${appController.bookSelected.value}-${appController.selectedChapter.value}'),
                  ),

                // Show a loading indicator on top
                if (controller.isLoading.value)
                  const Center(child: CircularProgressIndicator()),

                // Selection Toolbar
                const SelectionToolbar(),

                // Audio Player Bar
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: AudioPlayerBar(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
