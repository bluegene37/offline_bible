import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/storage_service.dart';

import '../controllers/bible_controller.dart';
import '../models/book_model.dart';
import '../services/red_letter_service.dart';
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
        final notesCtrl = Get.isRegistered<NotesController>()
            ? Get.find<NotesController>()
            : null;
        final highlightIndex = notesCtrl?.highlightColorFor(verseKey);
        final hasNotes = notesCtrl?.hasNoteFor(verseKey) ?? false;
        final hasBookmark = notesCtrl?.hasBookmarkFor(verseKey) ?? false;

        final bibleCtrl = Get.isRegistered<BibleController>()
            ? Get.find<BibleController>()
            : null;
        final isAudioActive =
            bibleCtrl != null && bibleCtrl.activeAudioVerseIndex.value == index;

        return ListTile(
          tileColor: isAudioActive
              ? (controller.activeThemeColor.withValues(alpha: 0.25))
              : null,
          trailing: hasNotes || hasBookmark || isAudioActive
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isAudioActive)
                      Semantics(
                        label: 'Now reading',
                        excludeSemantics: true,
                        child: const Icon(Icons.volume_up_rounded,
                            color: Colors.amber, size: 20),
                      ),
                    if (hasBookmark)
                      Semantics(
                        label: 'Bookmarked',
                        excludeSemantics: true,
                        child: Icon(Icons.bookmark,
                            color: controller.activeThemeColor, size: 20),
                      ),
                    if (hasNotes)
                      _buildNotesIcon(context, verseKey, controller),
                  ],
                )
              : null,
          title: _buildVerseText(
              context, controller, highlightIndex, isSelected, isAudioActive),
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
      int? highlightIndex, bool isSelected, bool isAudioActive) {
    final hasHighlight = highlightIndex != null;
    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.top,
            child: Padding(
              padding: const EdgeInsets.only(right: 6.0, top: 2.0),
              child: Text(
                '${verse.verse}',
                style: TextStyle(
                  fontFamily: controller.globalFont.value,
                  fontSize: controller.fontSize.value * 0.65,
                  color: _getTextColor(context, hasHighlight)
                      .withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          ..._buildBodySpans(
            context,
            controller,
            hasHighlight: hasHighlight,
            baseStyle: TextStyle(
              fontFamily: controller.globalFont.value,
              fontSize: controller.fontSize.value,
              height: controller.lineHeight.value,
              color: _getTextColor(context, hasHighlight),
              fontWeight: isAudioActive ? FontWeight.w500 : FontWeight.normal,
              decoration: isSelected ? TextDecoration.underline : null,
              decorationStyle: isSelected ? TextDecorationStyle.dashed : null,
              backgroundColor: isAudioActive
                  ? (controller.activeThemeColor.withValues(alpha: 0.15))
                  : _getBackgroundColor(context, highlightIndex),
            ),
          ),
        ],
      ),
    );
  }

  /// Splits the verse so the words of Christ can be coloured. Returns a single
  /// span when red letter is off or the verse has none — the common case.
  List<InlineSpan> _buildBodySpans(
    BuildContext context,
    AppController controller, {
    required TextStyle baseStyle,
    required bool hasHighlight,
  }) {
    final text = verse.text;
    if (!controller.showRedLetter) {
      return [TextSpan(text: text, style: baseStyle)];
    }
    final ranges = RedLetterService.spansFor(verse.verseKey, text.length);
    if (ranges.isEmpty) {
      return [TextSpan(text: text, style: baseStyle)];
    }

    // In light mode, and on a pastel highlight, the darker red holds contrast;
    // on a dark ground it goes muddy, so use the lighter tone there.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final redStyle = baseStyle.copyWith(
      color: (isDark && !hasHighlight)
          ? AppColors.redLetterDark
          : AppColors.redLetterLight,
    );

    final out = <InlineSpan>[];
    var cursor = 0;
    for (final range in ranges) {
      final start = range[0], end = range[1];
      if (start < cursor) continue; // defensive: ignore overlaps
      if (start > cursor) {
        out.add(
            TextSpan(text: text.substring(cursor, start), style: baseStyle));
      }
      out.add(TextSpan(text: text.substring(start, end), style: redStyle));
      cursor = end;
    }
    if (cursor < text.length) {
      out.add(TextSpan(text: text.substring(cursor), style: baseStyle));
    }
    return out;
  }

  Color _getTextColor(BuildContext context, bool hasHighlight) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (hasHighlight && !isDark) {
      // Light mode paints the full pastel marker, so text must be dark.
      return Colors.black;
    }
    return isDark ? Colors.white : Colors.black;
  }

  Color? _getBackgroundColor(BuildContext context, int? highlightIndex) {
    if (highlightIndex == null) return null;

    final color = AppColors.highlightColors[highlightIndex];

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
      tooltip: 'Open note',
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
        initialText: note['notes']?.toString(),
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
}
