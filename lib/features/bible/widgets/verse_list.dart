import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../core/controllers/app_controller.dart';
import '../controllers/bible_controller.dart';
import 'verse_tile.dart';
import 'bottom_action_sheet.dart';

class VerseList extends StatelessWidget {
  const VerseList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bibleController = Get.find<BibleController>();
    return ScrollablePositionedList.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        top: 10.0,
        bottom: bibleController.bottomPadding.value,
      ),
      itemCount: bibleController.currentVerses.length,
      itemBuilder: (context, index) {
        final verse = bibleController.currentVerses[index];
        return VerseTile(
          verse: verse,
          index: index,
          isLastVerse: index == bibleController.currentVerses.length - 1,
          onTap: () => _handleVerseTap(context, verse.verseKey, bibleController),
        );
      },
      itemScrollController: bibleController.itemScrollController,
      itemPositionsListener: bibleController.itemPositionsListener,
    );
  }

  void _handleVerseTap(BuildContext context, String verseKey, BibleController controller) {
    final appController = Get.find<AppController>();

    controller.toggleVerseSelection(verseKey);

    if (appController.textUnderline.isNotEmpty) {
      controller.bottomPadding.value = 120.0;
      _showBottomSheet(context, appController.textUnderline.toList());
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
