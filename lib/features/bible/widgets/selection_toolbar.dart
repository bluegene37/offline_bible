import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/bible_controller.dart';
import '../../notes/widgets/note_editor_sheet.dart';

class SelectionToolbar extends StatelessWidget {
  const SelectionToolbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bibleController = Get.find<BibleController>();

    final appController = Get.find<AppController>();

    return Obx(() {
      if (appController.textUnderline.isEmpty) return const SizedBox.shrink();

      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Positioned(
        bottom: 20,
        left: 20,
        right: 20,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: isDark
                  ? Colors.white10
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildColorRow(context, appController, bibleController),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              _buildActionsRow(context, appController, bibleController),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildColorRow(BuildContext context, AppController controller,
      BibleController bibleController) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Clear Highlight Button
          _buildColorCircle(
            context,
            color: Colors.transparent,
            icon: Icons.format_color_reset_outlined,
            onTap: () => _applyHighlight(-1, controller, bibleController),
            borderColor: Theme.of(context).dividerColor,
          ),
          const SizedBox(width: 8),

          // Color Palette
          ...List.generate(AppColors.highlightColors.length, (index) {
            final color = AppColors.highlightColors[index];
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: _buildColorCircle(
                context,
                color: color,
                onTap: () =>
                    _applyHighlight(index, controller, bibleController),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildColorCircle(
    BuildContext context, {
    required Color color,
    VoidCallback? onTap,
    IconData? icon,
    Color? borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? Colors.black12,
            width: 1,
          ),
        ),
        child: icon != null
            ? Icon(icon,
                size: 20,
                color:
                    Theme.of(context).iconTheme.color?.withValues(alpha: 0.7))
            : null,
      ),
    );
  }

  Widget _buildActionsRow(BuildContext context, AppController controller,
      BibleController bibleController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          context,
          icon: Icons.copy_rounded,
          label: 'Copy',
          onTap: () =>
              bibleController.copyVerses(controller.textUnderline.toList()),
        ),
        _buildActionButton(
          context,
          icon: Icons.edit_note_rounded,
          label: 'Note',
          onTap: () =>
              _openNoteEditor(context, controller.textUnderline.toList()),
        ),
        _buildActionButton(
          context,
          icon: Icons.share_rounded,
          label: 'Share',
          onTap: () {
            bibleController.shareVerses(controller.textUnderline.toList());
          },
        ),
        Container(
          height: 24,
          width: 1,
          color: Theme.of(context).dividerColor,
        ),
        _buildActionButton(
          context,
          icon: Icons.close_rounded,
          label: 'Close',
          isDestructive: true,
          onTap: () => controller.clearTextSelection(),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? Colors.red
        : Theme.of(context).textTheme.bodyMedium?.color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyHighlight(int colorIndex, AppController controller,
      BibleController bibleController) {
    final selected = controller.textUnderline.toList();
    if (colorIndex == -1) {
      for (final key in selected) {
        bibleController.deleteHighlight(key);
      }
    } else {
      bibleController.saveHighlight(selected, colorIndex);
    }
  }

  void _openNoteEditor(BuildContext context, List<String> selectedVerses) {
    if (selectedVerses.isEmpty) return;
    Get.bottomSheet(
      NoteEditorSheet(verseKeys: selectedVerses),
      isScrollControlled: true,
    );
  }
}
