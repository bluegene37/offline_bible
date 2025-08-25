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
              ? AppColors.themeColorShades[controller.colorSliderIdx.value] 
              : null,
          trailing: hasNotes ? _buildNotesIcon(controller) : null,
          title: _buildVerseText(controller, verseKey, isSelected, hasHighlight),
          subtitle: isLastVerse ? _buildCopyrightText() : null,
          onTap: onTap,
        );
      },
    );
  }

  Widget _buildVerseText(AppController controller, String verseKey, 
                        bool isSelected, bool hasHighlight) {
    final brightness = ThemeData.estimateBrightnessForColor(
      AppColors.themeColors[controller.colorSliderIdx.value]
    );
    
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${verse.verse}. ',
            style: GoogleFonts.getFont(
              controller.globalFont.value,
              fontSize: 11 + controller.fontSize.value,
              color: AppColors.textColors[controller.textColorIdx.value],
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
              color: _getTextColor(controller, hasHighlight, brightness),
              decoration: isSelected ? TextDecoration.underline : null,
              decorationStyle: isSelected ? TextDecorationStyle.dashed : null,
              backgroundColor: _getBackgroundColor(verseKey, hasHighlight),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTextColor(AppController controller, bool hasHighlight, Brightness brightness) {
    if (!hasHighlight && brightness == Brightness.dark) {
      return AppColors.textColors[controller.textColorIdx.value];
    }
    return Colors.black;
  }

  Color? _getBackgroundColor(String verseKey, bool hasHighlight) {
    if (!hasHighlight) return null;
    
    final colorIndex = StorageService.highlightBox.get(verseKey, defaultValue: 0);
    return AppColors.highlightColors[colorIndex];
  }

  Widget _buildNotesIcon(AppController controller) {
    return Icon(
      Icons.note,
      color: AppColors.themeColors[controller.colorSliderIdx.value],
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
    return notesValues.any((note) => 
      note['book'].toString().contains(verseKey)
    );
  }

  void _handleVerseTap(String verseKey) {
    final bibleController = Get.find<BibleController>();
    bibleController.toggleVerseSelection(verseKey);
    
    if (onTap != null) {
      onTap!();
    }
  }
}