import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../core/controllers/app_controller.dart';
import '../controllers/bible_controller.dart';
import '../widgets/verse_tile.dart';
import '../widgets/bottom_action_sheet.dart';

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
    final appController = Get.find<AppController>();
    final bibleController = Get.find<BibleController>();

    // Load chapter data when page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bibleController.loadChapter(bookTitle, chapter);
    });

    return Scaffold(
      body: GetBuilder<BibleController>(
        builder: (controller) {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.currentVerses.isEmpty) {
            return const Center(child: Text('No verses found'));
          }

          return Obx(() => ScrollablePositionedList.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: 10.0,
              bottom: controller.bottomPadding.value,
            ),
            itemCount: controller.currentVerses.length,
            itemBuilder: (context, index) {
              final verse = controller.currentVerses[index];
              return VerseTile(
                verse: verse,
                index: index,
                isLastVerse: index == controller.currentVerses.length - 1,
                onTap: () => _handleVerseTap(context, verse.verseKey, controller),
              );
            },
            itemScrollController: controller.itemScrollController,
            itemPositionsListener: controller.itemPositionsListener,
          ));
        },
      ),
    );
  }

  void _handleVerseTap(BuildContext context, String verseKey, BibleController controller) {
    final appController = Get.find<AppController>();
    
    if (appController.textUnderline.isNotEmpty) {
      controller.bottomPadding.value = 120.0;
      _showBottomSheet(context, appController.textUnderline);
    } else {
      controller.bottomPadding.value = 0.0;
      Navigator.of(context).maybePop();
    }
  }

  void _showBottomSheet(BuildContext context, List<String> selectedVerses) {
    final bottomSheetController = Scaffold.of(context).showBottomSheet(
      (BuildContext context) => BottomActionSheet(selectedVerses: selectedVerses),
    );

    bottomSheetController.closed.then((_) {
      final bibleController = Get.find<BibleController>();
      final appController = Get.find<AppController>();
      
      bibleController.bottomPadding.value = 0.0;
      bibleController.sheetHeight.value = 0.0;
      appController.clearTextSelection();
    });
  }
}