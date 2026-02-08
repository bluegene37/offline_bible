import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/bible_controller.dart';

class FloatingNavigation extends StatelessWidget {
  const FloatingNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find();
    final BibleController bibleController = Get.find();

    return Obx(() {
      final int currentChapter = appController.selectedChapter.value;
      final String currentBook = appController.bookSelected.value;
      final int lastChapter = appController.lastChapter;

      final bool canGoBack = currentChapter > 1;
      final bool canGoForward = currentChapter < lastChapter;

      return Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavButton(
              icon: Icons.arrow_back_ios_new,
              label: canGoBack
                  ? '$currentBook ${currentChapter - 1}'
                  : 'First Chapter',
              onPressed:
                  canGoBack ? bibleController.navigateToPreviousChapter : null,
              isEnabled: canGoBack,
            ),
            const VerticalDivider(width: 1),
            _buildNavButton(
              icon: Icons.arrow_forward_ios,
              label: canGoForward
                  ? '$currentBook ${currentChapter + 1}'
                  : 'Last Chapter',
              onPressed:
                  canGoForward ? bibleController.navigateToNextChapter : null,
              isEnabled: canGoForward,
              isNext: true,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required bool isEnabled,
    bool isNext = false,
  }) {
    final AppController appController = Get.find();
    final textColor = isEnabled
        ? AppColors.themeColors[appController.colorThemeName.value]
        : Colors.grey.withValues(alpha: 0.6);

    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: isNext
            ? const BorderRadius.horizontal(right: Radius.circular(25))
            : const BorderRadius.horizontal(left: Radius.circular(25)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isNext) Icon(icon, color: textColor, size: 18),
              if (!isNext) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: isNext ? TextAlign.end : TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isNext) const SizedBox(width: 8),
              if (isNext) Icon(icon, color: textColor, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
