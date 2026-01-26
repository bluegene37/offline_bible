import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/controllers/app_controller.dart';
import '../../bible/controllers/bible_controller.dart';
import '../controllers/notes_controller.dart';

class NoteEditorSheet extends StatefulWidget {
  final List<String> verseKeys;
  final String? existingNoteId;
  final String? initialText;

  const NoteEditorSheet({
    Key? key,
    required this.verseKeys,
    this.existingNoteId,
    this.initialText,
  }) : super(key: key);

  @override
  State<NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<NoteEditorSheet> {
  late TextEditingController _textController;
  final AppController _appController = Get.find<AppController>();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildVerseReference(),
          const SizedBox(height: 20),
          Expanded(child: _buildEditor()),
          const SizedBox(height: 10),
          _buildActions(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.existingNoteId != null ? 'Edit Note' : 'New Note',
          style: GoogleFonts.raleway(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.themeColors[_appController.colorThemeName.value],
          ),
        ),
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildVerseReference() {
    // Format keys like "Genesis 1:1, 1:2"
    String reference = widget.verseKeys.join(', ');
    // Simple improvement: if keys are long, truncate or format better
    if (reference.length > 50) {
      reference = '${reference.substring(0, 47)}...';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.themeColorShades[_appController.colorThemeName.value]!
            .withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              AppColors.themeColorShades[_appController.colorThemeName.value]!,
        ),
      ),
      child: Text(
        reference,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return TextField(
      controller: _textController,
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      autofocus: true,
      style: const TextStyle(fontSize: 16, height: 1.5),
      decoration: const InputDecoration(
        hintText: 'Write your thoughts here...',
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(0),
      ),
    );
  }

  Widget _buildActions() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.themeColors[_appController.colorThemeName.value],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: _saveNote,
        child: Text(
          'Save Note',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _appController.textColorDynamic.value,
          ),
        ),
      ),
    );
  }

  void _saveNote() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    if (widget.existingNoteId != null) {
      // Update existing
      Get.find<NotesController>().updateNote(widget.existingNoteId!, text);
    } else {
      // Create new
      Get.find<BibleController>().saveNotes(widget.verseKeys, text);
    }
    Get.back(); // Close sheet
  }
}
