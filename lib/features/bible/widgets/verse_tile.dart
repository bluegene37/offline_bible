import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/storage_service.dart';

import '../controllers/bible_controller.dart';
import '../models/book_model.dart';
import '../services/version_service.dart';
import '../../notes/controllers/notes_controller.dart';
import '../../notes/widgets/note_editor_sheet.dart';

class VerseTile extends StatelessWidget {
  final Book verse;
  final int index;
  final bool isLastVerse;
  final VoidCallback? onTap;

  const VerseTile({
    super.key,
    required this.verse,
    required this.index,
    this.isLastVerse = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final verseKey = verse.verseKey;

    return GetBuilder<AppController>(
      builder: (controller) {
        final isSelected = controller.textUnderline.contains(verseKey);
        final hasHighlight = StorageService.highlightBox.containsKey(verseKey);
        final hasNotes = _hasNotes(verseKey);
        final hasBookmark = StorageService.bookmarksBox.containsKey(verseKey);

        final bibleCtrl = Get.isRegistered<BibleController>() ? Get.find<BibleController>() : null;
        final isAudioActive = bibleCtrl != null && bibleCtrl.activeAudioVerseIndex.value == index;

        return ListTile(
          tileColor: isAudioActive
              ? (controller.activeThemeColor.withValues(alpha: 0.25))
              : null,
          trailing: hasNotes || hasBookmark || isAudioActive
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isAudioActive)
                      const Icon(Icons.volume_up_rounded, color: Colors.amber, size: 20),
                    if (hasBookmark)
                      Icon(Icons.bookmark, color: controller.activeThemeColor, size: 20),
                    if (hasNotes) _buildNotesIcon(context, verseKey, controller),
                  ],
                )
              : null,
          title: _buildVerseText(
              context, controller, verseKey, isSelected, hasHighlight, isAudioActive),
          subtitle: isLastVerse ? _buildCopyrightText() : null,
          onTap: () {
            HapticFeedback.selectionClick();
            onTap?.call();
          },
          onLongPress: () {
            HapticFeedback.selectionClick();
            onTap?.call();
          },
        );
      },
    );
  }

  Widget _buildVerseText(BuildContext context, AppController controller,
      String verseKey, bool isSelected, bool hasHighlight, bool isAudioActive) {
    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.top,
            child: Padding(
              padding: const EdgeInsets.only(right: 6.0, top: 2.0),
              child: Text(
                '${verse.verse}',
                style: GoogleFonts.getFont(
                  controller.globalFont.value,
                  fontSize: controller.fontSize.value * 0.65,
                  color: _getTextColor(context, hasHighlight).withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          TextSpan(
            text: verse.text,
            style: GoogleFonts.getFont(
              controller.globalFont.value,
              fontSize: controller.fontSize.value,
              height: controller.lineHeight.value,
              color: _getTextColor(context, hasHighlight),
              fontWeight: isAudioActive ? FontWeight.w500 : FontWeight.normal,
              decoration: isSelected ? TextDecoration.underline : null,
              decorationStyle: isSelected ? TextDecorationStyle.dashed : null,
              backgroundColor: isAudioActive
                  ? (controller.activeThemeColor.withOpacity(0.15))
                  : _getBackgroundColor(context, verseKey, hasHighlight),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTextColor(BuildContext context, bool hasHighlight) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (hasHighlight && !isDark) {
      // Light mode paints the full pastel marker, so text must be dark.
      return Colors.black;
    }
    return isDark ? Colors.white : Colors.black;
  }

  Color? _getBackgroundColor(BuildContext context, String verseKey,
      bool hasHighlight) {
    if (!hasHighlight) return null;

    final colorIndex =
        StorageService.highlightBox.get(verseKey, defaultValue: 0);
    final color = (colorIndex >= 0 &&
            colorIndex < AppColors.highlightColors.length)
        ? AppColors.highlightColors[colorIndex]
        : AppColors.highlightColors[0];

    // Dark mode dims the marker to a tint so white text stays readable
    // and the page doesn't glow.
    return Theme.of(context).brightness == Brightness.dark
        ? color.withValues(alpha: 0.30)
        : color;
  }

  Widget _buildNotesIcon(
      BuildContext context, String verseKey, AppController controller) {
    return IconButton(
      icon: Icon(
        Icons.note,
        color: controller.activeThemeColor,
      ),
      onPressed: () => _onNoteIconTap(context, verseKey),
    );
  }

  void _onNoteIconTap(BuildContext context, String verseKey) {
    final noteId = Get.find<NotesController>().noteIdForVerse(verseKey);
    if (noteId == null) return;
    final note = StorageService.notesBox.get(noteId);
    if (note == null) return;

    Get.bottomSheet(
      NoteEditorSheet(
        verseKeys: [verseKey],
        existingNoteId: noteId,
        initialText: note['notes'],
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildCopyrightText() {
    final version =
        VersionService.byAbbrev(Get.find<AppController>().bibleVersion.value);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        '${version.name} — ${version.copyright}',
        style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 11),
        textAlign: TextAlign.center,
      ),
    );
  }

  bool _hasNotes(String verseKey) {
    return Get.isRegistered<NotesController>() &&
        Get.find<NotesController>().hasNoteFor(verseKey);
  }
}
