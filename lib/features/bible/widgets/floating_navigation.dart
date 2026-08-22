import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../controllers/bible_controller.dart';

class FloatingNavigation extends StatelessWidget {
  const FloatingNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find();
    final BibleController bibleController = Get.find();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final int currentChapter = appController.selectedChapter.value;
      final String currentBook = appController.bookSelected.value;
      final int lastChapter = appController.lastChapter;

      final bool canGoBack = currentChapter > 1;
      final bool canGoForward = currentChapter < lastChapter;

      return Container(
        height: 52,
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
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
                    onPressed: canGoBack ? () {
                      HapticFeedback.selectionClick();
                      bibleController.navigateToPreviousChapter();
                    } : null,
                    isEnabled: canGoBack,
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                  // Audio Listen Button
                  IconButton(
                    tooltip: 'Listen to Chapter',
                    icon: Obx(() => Icon(
                          bibleController.isAudioPlaying.value
                              ? Icons.pause_circle_filled_rounded
                              : Icons.volume_up_rounded,
                          color: Theme.of(context).primaryColor,
                          size: 26,
                        )),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      bibleController.toggleChapterAudio();
                    },
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                  _buildNavButton(
                    icon: Icons.arrow_forward_ios,
                    label: canGoForward
                        ? '$currentBook ${currentChapter + 1}'
                        : 'Last Chapter',
                    onPressed: canGoForward ? () {
                      HapticFeedback.selectionClick();
                      bibleController.navigateToNextChapter();
                    } : null,
                    isEnabled: canGoForward,
                    isNext: true,
                  ),
                ],
              ),
            ),
          ),
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
    final isDark = Get.theme.brightness == Brightness.dark;
    final textColor = isEnabled
        ? (Get.theme.primaryColor)
        : (isDark ? Colors.white38 : Colors.black38);

    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: isNext
            ? const BorderRadius.horizontal(right: Radius.circular(26))
            : const BorderRadius.horizontal(left: Radius.circular(26)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isNext) Icon(icon, color: textColor, size: 16),
              if (!isNext) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  textAlign: isNext ? TextAlign.end : TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isNext) const SizedBox(width: 8),
              if (isNext) Icon(icon, color: textColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
