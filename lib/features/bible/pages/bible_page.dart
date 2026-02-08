import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../controllers/bible_controller.dart';
import '../widgets/verse_list.dart';
import '../widgets/selection_toolbar.dart';

class BiblePage extends StatelessWidget {
  final String bookTitle;
  final int chapter;

  const BiblePage({
    Key? key,
    required this.bookTitle,
    required this.chapter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bibleController = Get.find<BibleController>();
    final appController = Get.find<AppController>();

    // Load chapter data when page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bibleController.loadChapter(bookTitle, chapter);
    });

    return Scaffold(
      body: GetBuilder<BibleController>(
        builder: (controller) {
          return Stack(
            children: [
              // The VerseList is always in the tree
              if (controller.currentVerses.isEmpty &&
                  !controller.isLoading.value)
                const Center(child: Text('No verses found'))
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
            ],
          );
        },
      ),
    );
  }
}
