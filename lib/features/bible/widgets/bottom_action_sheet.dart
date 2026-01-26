import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/bible_controller.dart';
import '../../notes/widgets/note_editor_sheet.dart';

class BottomActionSheet extends StatelessWidget {
  final List<String> selectedVerses;

  const BottomActionSheet({
    Key? key,
    required this.selectedVerses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final bibleController = Get.find<BibleController>();

    return GetBuilder<AppController>(
      builder: (controller) {
        return Container(
          padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 20.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Actions Row (Copy, Note, Share)
              _buildActionRow(context, controller, bibleController),
              const SizedBox(height: 25),

              // 2. Divider or Label (Optional, keeping it clean for now)

              // 3. Highlight Colors
              _buildHighlightColors(controller, bibleController),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionRow(BuildContext context, AppController controller,
      BibleController bibleController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute evenly
      children: [
        _buildActionButton(
          context,
          icon: Icons.copy_all_rounded,
          label: 'Copy',
          onTap: () => bibleController.copyVerses(selectedVerses),
        ),
        _buildActionButton(
          context,
          icon: Icons.edit_note_rounded,
          label: 'Note',
          onTap: () => _openNoteEditor(context),
        ),
        _buildActionButton(
          context,
          icon: Icons.share_rounded,
          label: 'Share',
          onTap: () {
            bibleController.copyVerses(selectedVerses);
            Get.snackbar('Share', 'Verses copied for sharing');
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    // Use the primary theme color for actions to make them pop
    final primaryColor =
        AppColors.themeColors[Get.find<AppController>().colorThemeName.value];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: primaryColor!
              .withOpacity(0.1), // Value 0.1 opacity for subtle background
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: primaryColor),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightColors(
      AppController controller, BibleController bibleController) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          // Clear Button
          InkWell(
            onTap: () => _applyHighlight(-1, bibleController),
            borderRadius: BorderRadius.circular(25),
            child: Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.grey.withOpacity(0.4), width: 1.5),
              ),
              child: const Icon(Icons.format_color_reset_rounded,
                  size: 22, color: Colors.grey),
            ),
          ),
          ...List.generate(AppColors.highlightColors.length, (index) {
            return Container(
              margin: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: () => _applyHighlight(index, bibleController),
                borderRadius: BorderRadius.circular(25),
                child: CircleAvatar(
                  radius: 25, // Slightly larger for easier tapping
                  backgroundColor: AppColors.highlightColors[index],
                  child: _isColorSelected(index)
                      ? const Icon(Icons.check, color: Colors.black, size: 22)
                      : null,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  bool _isColorSelected(int colorIndex) {
    // Note: Implementing true selection logic would require checking the BibleController state.
    // For now, stateless return false is acceptable as the action is immediate.
    return false;
  }

  void _applyHighlight(int colorIndex, BibleController bibleController) {
    if (colorIndex == -1) {
      for (final key in selectedVerses) {
        bibleController.deleteHighlight(key);
      }
    } else {
      bibleController.saveHighlight(selectedVerses, colorIndex);
    }
    Get.back();
  }

  void _openNoteEditor(BuildContext context) {
    if (selectedVerses.isEmpty) return;
    Get.bottomSheet(
      NoteEditorSheet(verseKeys: selectedVerses),
      isScrollControlled: true,
    );
  }
}
