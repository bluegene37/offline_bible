import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../controllers/bible_controller.dart';

class AudioPlayerBar extends StatelessWidget {
  const AudioPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final bibleController = Get.find<BibleController>();
    final appController = Get.find<AppController>();

    return Obx(() {
      final isPlaying = bibleController.isAudioPlaying.value;
      final isPaused = bibleController.isAudioPaused.value;
      final activeVerseIdx = bibleController.activeAudioVerseIndex.value;
      final totalVerses = bibleController.currentVerses.length;
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      final accentColor = appController.activeThemeColor;

      if (!isPlaying && !isPaused && activeVerseIdx < 0) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 84, left: 16, right: 16), // above floating nav
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF222222).withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDarkMode ? Colors.white24 : Colors.black12,
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
            // Playing indicator icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? Icons.volume_up_rounded : Icons.pause_rounded,
                color: accentColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Verse info
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${appController.bookSelected.value} ${appController.selectedChapter.value}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    activeVerseIdx >= 0 && activeVerseIdx < totalVerses
                        ? 'Verse ${activeVerseIdx + 1} of $totalVerses'
                        : 'Audio Bible',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Speed
            PopupMenuButton<double>(
              initialValue: bibleController.audioSpeechRate.value,
              tooltip: 'Playback Speed',
              onSelected: (speed) {
                bibleController.setAudioRate(speed);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 0.3, child: Text('0.75x Speed')),
                PopupMenuItem(value: 0.5, child: Text('1.0x Speed (Normal)')),
                PopupMenuItem(value: 0.6, child: Text('1.25x Speed')),
                PopupMenuItem(value: 0.7, child: Text('1.5x Speed')),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_formatSpeed(bibleController.audioSpeechRate.value)}x',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            // Previous verse
            IconButton(
              tooltip: 'Previous verse',
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.skip_previous_rounded,
                  size: 26, color: accentColor),
              onPressed: activeVerseIdx > 0
                  ? bibleController.skipToPreviousVerse
                  : null,
            ),

            // Play / Pause
            IconButton(
              tooltip: isPlaying ? 'Pause' : 'Play',
              visualDensity: VisualDensity.compact,
              icon: Icon(
                isPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_filled_rounded,
                size: 34,
                color: accentColor,
              ),
              onPressed: bibleController.toggleChapterAudio,
            ),

            // Next verse
            IconButton(
              tooltip: 'Next verse',
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.skip_next_rounded, size: 26, color: accentColor),
              onPressed: activeVerseIdx < totalVerses - 1
                  ? bibleController.skipToNextVerse
                  : null,
            ),

            // Stop
            IconButton(
              tooltip: 'Stop',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.close_rounded, size: 22, color: Colors.grey),
              onPressed: bibleController.stopAudio,
            ),
          ],
        ),
      ),
    ),
  ),
);
    });
  }

  String _formatSpeed(double rate) {
    if (rate <= 0.35) return '0.75';
    if (rate <= 0.55) return '1.0';
    if (rate <= 0.65) return '1.25';
    return '1.5';
  }
}
