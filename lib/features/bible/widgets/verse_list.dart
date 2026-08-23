import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../controllers/bible_controller.dart';
import 'verse_tile.dart';

class VerseList extends StatelessWidget {
  const VerseList({super.key});

  @override
  Widget build(BuildContext context) {
    final bibleController = Get.find<BibleController>();
    return Obx(() => ScrollablePositionedList.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            top: 10.0,
            bottom: 80.0 + bibleController.bottomPadding.value,
          ),
          itemCount: bibleController.currentVerses.length,
          itemBuilder: (context, index) {
            final verse = bibleController.currentVerses[index];
            // No per-item entrance animation: in a builder-backed list it
            // re-runs every time a row scrolls back into view, and the Opacity
            // layer it needed cost a saveLayer per verse.
            return VerseTile(
              verse: verse,
              index: index,
              isLastVerse: index == bibleController.currentVerses.length - 1,
              onTap: () =>
                  _handleVerseTap(context, verse.verseKey, bibleController),
            );
          },
          itemScrollController: bibleController.itemScrollController,
          itemPositionsListener: bibleController.itemPositionsListener,
        ));
  }

  void _handleVerseTap(
      BuildContext context, String verseKey, BibleController controller) {
    controller.toggleVerseSelection(verseKey);
  }
}
