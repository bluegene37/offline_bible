import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added this import
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/storage_service.dart';

import '../models/book_model.dart';
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

        return ListTile(
          trailing: hasNotes || hasBookmark
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasBookmark)
                      Icon(Icons.bookmark, color: controller.activeThemeColor, size: 20),
                    if (hasNotes) _buildNotesIcon(context, verseKey, controller),
                  ],
                )
              : null,
          title: _buildVerseText(
              context, controller, verseKey, isSelected, hasHighlight),
          subtitle: isLastVerse ? _buildCopyrightText() : null,
          onTap: () {
            HapticFeedback.selectionClick(); // Added haptic feedback
            onTap?.call();
          },
          onLongPress: () {
            HapticFeedback.selectionClick(); // Added haptic feedback
            onTap?.call(); // Assuming long press should also trigger the same action
          },
        );
      },
    );
  }

  Widget _buildVerseText(BuildContext context, AppController controller,
      String verseKey, bool isSelected, bool hasHighlight) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${verse.verse}. ',
            style: GoogleFonts.getFont(
              controller.globalFont.value,
              fontSize: 11 + controller.fontSize.value,
              color:
                  _getTextColor(context, hasHighlight).withValues(alpha: 0.7),
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.italic,
            ),
          ),
          TextSpan(
            text: verse.text,
            style: GoogleFonts.getFont(
              controller.globalFont.value,
              fontSize: 15 + controller.fontSize.value,
              color: _getTextColor(context, hasHighlight),
              decoration: isSelected ? TextDecoration.underline : null,
              decorationStyle: isSelected ? TextDecorationStyle.dashed : null,
              backgroundColor: _getBackgroundColor(verseKey, hasHighlight),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTextColor(BuildContext context, bool hasHighlight) {
    if (hasHighlight) {
      // Highlights are typically light colors, so use black text for contrast
      return Colors.black;
    }

    // For normal text, adapt to the background brightness
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  Color? _getBackgroundColor(String verseKey, bool hasHighlight) {
    if (!hasHighlight) return null;

    final colorIndex =
        StorageService.highlightBox.get(verseKey, defaultValue: 0);
    // Ensure index is within bounds
    if (colorIndex >= 0 && colorIndex < AppColors.highlightColors.length) {
      return AppColors.highlightColors[colorIndex];
    }
    return AppColors.highlightColors[0];
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
    final notesBox = StorageService.notesBox;
    // Find note containing this verseKey
    final noteEntry = notesBox.toMap().entries.firstWhere(
          (e) => e.value['book'].toString().contains(verseKey),
          orElse: () => MapEntry('', {}),
        );

    if (noteEntry.key.toString().isNotEmpty) {
      Get.bottomSheet(
        NoteEditorSheet(
          verseKeys: [verseKey],
          existingNoteId: noteEntry.key.toString(),
          initialText: noteEntry.value['notes'],
        ),
        isScrollControlled: true,
      );
    }
  }

  Widget _buildCopyrightText() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Text(
        'Rights in the Authorized (King James) Version in the United Kingdom are vested in the Crown. '
        'Published by permission of the Crown\'s patentee, Cambridge University Press',
        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11),
        textAlign: TextAlign.center,
      ),
    );
  }

  bool _hasNotes(String verseKey) {
    final notesValues = StorageService.notesBox.values.toList();
    return notesValues
        .any((note) => note['book'].toString().contains(verseKey));
  }
}
