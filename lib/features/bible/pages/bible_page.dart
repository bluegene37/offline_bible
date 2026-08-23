import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Paper, not the themed app surface — see AppColors.paperLight.
      backgroundColor:
          isDark ? AppColors.paperDark : AppColors.paperLight,
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
                  _buildEmptyState(context, controller, appController)
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

  /// Shown when the reader has nothing to display. A failed load is a
  /// different problem from an empty chapter, and needs to say so — the
  /// startup path has no overlay to put a snackbar in.
  Widget _buildEmptyState(BuildContext context, BibleController controller,
      AppController appController) {
    return Obx(() {
      final error = appController.loadError.value;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                error == null ? Icons.menu_book_outlined : Icons.error_outline,
                size: 48,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              const SizedBox(height: 16),
              Text(
                error ?? 'No verses found for $bookTitle $chapter.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => error == null
                    ? controller.loadChapter(bookTitle, chapter)
                    : appController.retryLoad(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    });
  }
}
