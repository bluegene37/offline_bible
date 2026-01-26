import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/storage_service.dart';
import '../controllers/bible_controller.dart';
import '../models/book_model.dart';

class VerseTile extends StatelessWidget {
  final Book verse;
  final int index;
  final bool isLastVerse;
  final VoidCallback? onTap;

  const VerseTile({
    Key? key,
    required this.verse,
    required this.index,
    this.isLastVerse = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final bibleController = Get.find<BibleController>();
    final verseKey = verse.verseKey;

    return GetBuilder<AppController>(
      builder: (controller) {
        final isSelected = controller.textUnderline.contains(verseKey);
        final hasHighlight = StorageService.highlightBox.containsKey(verseKey);
        final hasNotes = _hasNotes(verseKey);

        return ListTile(
          tileColor: bibleController.colorIndex == index
              ? AppColors.themeColorShades[controller.colorThemeName.value]
              : null,
          trailing: hasNotes ? _buildNotesIcon(controller) : null,
          title: _buildVerseText(
              context, controller, verseKey, isSelected, hasHighlight),
          subtitle: isLastVerse ? _buildCopyrightText() : null,
          onTap: onTap,
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
              color: _getTextColor(context, hasHighlight).withOpacity(0.7),
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.italic,
            ),
          ),
          TextSpan(
            text: verse.text,
            recognizer: TapGestureRecognizer()
              ..onTap = () => _handleVerseTap(verseKey),
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

  Widget _buildNotesIcon(AppController controller) {
    return Icon(
      Icons.note,
      color: AppColors.themeColors[controller.colorThemeName.value],
    );
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

  void _handleVerseTap(String verseKey) {
    final bibleController = Get.find<BibleController>();
    bibleController.toggleVerseSelection(verseKey);

    if (onTap != null) {
      onTap!();
    }
  }
}
