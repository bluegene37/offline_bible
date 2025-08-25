import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/bible_controller.dart';

class FloatingNavigation extends StatelessWidget {
  const FloatingNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final bibleController = Get.find<BibleController>();

    return GetBuilder<AppController>(
      builder: (controller) {
        final canGoBack = controller.selectedChapter.value > 1;
        final canGoForward = controller.selectedChapter.value < bibleController.lastChapter;

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: 30,
              bottom: 20,
              width: 40,
              height: 40,
              child: FloatingActionButton(
                backgroundColor: AppColors.themeColors[controller.colorSliderIdx.value],
                heroTag: 'back',
                onPressed: canGoBack ? () => bibleController.navigateToPreviousChapter() : null,
                child: Icon(
                  Icons.navigate_before_rounded,
                  size: 40,
                  color: canGoBack 
                      ? controller.textColorDynamic.value 
                      : Colors.black12,
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: 20,
              width: 40,
              height: 40,
              child: FloatingActionButton(
                backgroundColor: AppColors.themeColors[controller.colorSliderIdx.value],
                heroTag: 'next',
                onPressed: canGoForward ? () => bibleController.navigateToNextChapter() : null,
                child: Icon(
                  Icons.navigate_next_rounded,
                  size: 40,
                  color: canGoForward 
                      ? controller.textColorDynamic.value 
                      : Colors.black12,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}