import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/bible_controller.dart';
import '../../notes/widgets/note_editor_sheet.dart';
import 'cross_reference_sheet.dart';

class SelectionToolbar extends StatelessWidget {
  const SelectionToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final bibleController = Get.find<BibleController>();
    final appController = Get.find<AppController>();

    return Obx(() {
      if (appController.textUnderline.isEmpty) return const SizedBox.shrink();

      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Positioned(
        bottom: 24,
        left: 16,
        right: 16,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF222222).withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.black12,
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
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
          ),
        ),
      );
    });
  }

  Widget _buildColorRow(BuildContext context, AppController controller,
      BibleController bibleController) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Clear Highlight Button
          _buildColorCircle(
            context,
            color: Colors.transparent,
            label: 'Remove highlight',
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
                // Colour alone carries no meaning for a screen reader.
                label: '${AppColors.highlightColorNames[index]} highlight',
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
    required String label,
    VoidCallback? onTap,
    IconData? icon,
    Color? borderColor,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
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
      ),
    );
  }

  Widget _buildActionsRow(BuildContext context, AppController controller,
      BibleController bibleController) {
    // Scrollable: seven actions do not fit across a narrow phone, and clipping
    // one silently is worse than letting the row scroll.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            context,
            icon: Icons.hub_outlined,
            label: 'Refs',
            onTap: () {
              HapticFeedback.selectionClick();
              final keys = controller.textUnderline.toList();
              if (keys.isEmpty) return;
              // Cross-references are per verse; use the first of a selection.
              CrossReferenceSheet.show(context, keys.first);
            },
          ),
          _buildActionButton(
            context,
            icon: Icons.copy_rounded,
            label: 'Copy',
            onTap: () {
              HapticFeedback.selectionClick();
              bibleController.copyVerses(controller.textUnderline.toList());
            },
          ),
          _buildActionButton(
            context,
            icon: Icons.edit_note_rounded,
            label: 'Note',
            onTap: () {
              HapticFeedback.selectionClick();
              _openNoteEditor(context, controller.textUnderline.toList());
            },
          ),
          _buildActionButton(
            context,
            icon: Icons.share_rounded,
            label: 'Share',
            onTap: () {
              HapticFeedback.selectionClick();
              bibleController.shareVerses(controller.textUnderline.toList());
            },
          ),
          _buildActionButton(
            context,
            icon: Icons.bookmark_add_rounded,
            label: 'Bookmark',
            onTap: () {
              HapticFeedback.selectionClick();
              bibleController
                  .toggleBookmarks(controller.textUnderline.toList());
            },
          ),
          _buildActionButton(
            context,
            icon: Icons.record_voice_over_rounded,
            label: 'Speak',
            onTap: () {
              HapticFeedback.selectionClick();
              final keys = controller.textUnderline.toList();
              if (keys.isNotEmpty) {
                final firstKey = keys.first;
                final index = bibleController.currentVerses.indexWhere(
                    (v) => '${v.book}:${v.chapter}:${v.verse}' == firstKey);
                if (index != -1) {
                  bibleController.startChapterAudio(startIndex: index);
                }
              }
              controller.clearTextSelection();
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
            onTap: () {
              HapticFeedback.selectionClick();
              controller.clearTextSelection();
            },
          ),
        ],
      ),
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
    HapticFeedback.selectionClick();
    final selected = controller.textUnderline.toList();
    if (colorIndex == -1) {
      bibleController.deleteHighlights(selected);
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
