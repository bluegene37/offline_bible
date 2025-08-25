import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/bible_controller.dart';

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
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Obx(() => SizedBox(
            height: 120 + bibleController.sheetHeight.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (bibleController.sheetHeight.value > 0) _buildNotesField(controller),
                _buildActionButtons(controller, bibleController),
                const SizedBox(height: 5),
                _buildCopyButtons(controller),
                _buildHighlightColors(controller, bibleController),
              ],
            ),
          )),
        );
      },
    );
  }

  Widget _buildNotesField(AppController controller) {
    return SizedBox(
      height: Get.find<BibleController>().sheetHeight.value,
      child: TextFormField(
        controller: Get.find<BibleController>().notesController,
        textAlignVertical: TextAlignVertical.top,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        expands: true,
        decoration: InputDecoration(
          labelText: "Enter Notes",
          fillColor: Colors.white,
          labelStyle: TextStyle(
            color: AppColors.themeColorShades[controller.colorSliderIdx.value],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppController controller, BibleController bibleController) {
    return Row(
      children: [
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.themeColors[controller.colorSliderIdx.value],
          ),
          onPressed: () => _saveNotes(bibleController),
          child: Text(
            'Save',
            style: TextStyle(color: controller.textColorDynamic.value),
          ),
        ),
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.themeColors[controller.colorSliderIdx.value],
          ),
          onPressed: () => _toggleNotesField(bibleController),
          child: Text(
            'Close',
            style: TextStyle(color: controller.textColorDynamic.value),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildCopyButtons(AppController controller) {
    return Row(
      children: [
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.themeColors[controller.colorSliderIdx.value],
          ),
          onPressed: () => _copyText(false),
          child: Text(
            'Copy texts',
            style: TextStyle(color: controller.textColorDynamic.value),
          ),
        ),
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.themeColors[controller.colorSliderIdx.value],
          ),
          onPressed: () => _copyText(true),
          child: Text(
            'Copy w/ verse no.',
            style: TextStyle(color: controller.textColorDynamic.value),
          ),
        ),
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.themeColors[controller.colorSliderIdx.value],
          ),
          onPressed: () => _toggleNotesField(Get.find<BibleController>()),
          child: Text(
            'Notes',
            style: TextStyle(color: controller.textColorDynamic.value),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildHighlightColors(AppController controller, BibleController bibleController) {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        scrollDirection: Axis.horizontal,
        itemCount: AppColors.highlightColors.length,
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => _applyHighlight(index, bibleController),
            child: CircleAvatar(
              radius: 22.5,
              backgroundColor: AppColors.highlightColors[index],
              child: _isColorSelected(index) 
                  ? const Icon(Icons.close, color: Colors.black)
                  : null,
            ),
          );
        },
      ),
    );
  }

  bool _isColorSelected(int colorIndex) {
    // This would need to be implemented based on current selection logic
    return false;
  }

  void _copyText(bool includeVerseNumbers) {
    final bibleController = Get.find<BibleController>();
    String copyText = '';
    
    for (final verse in bibleController.currentVerses) {
      if (selectedVerses.any((key) => key.endsWith(':${verse.verse}'))) {
        if (includeVerseNumbers) {
          copyText += '${verse.verse}. ${verse.text} ';
        } else {
          copyText += '${verse.text} ';
        }
      }
    }
    
    Clipboard.setData(ClipboardData(text: copyText.trim()));
    Get.snackbar('Copied', 'Text copied to clipboard');
  }

  void _saveNotes(BibleController bibleController) {
    final notes = bibleController.notesController.text.trim();
    if (notes.isNotEmpty) {
      bibleController.saveNotes(selectedVerses, notes);
      Get.back();
    }
  }

  void _toggleNotesField(BibleController bibleController) {
    if (bibleController.sheetHeight.value == 300.0) {
      bibleController.sheetHeight.value = 0.0;
      bibleController.notesController.clear();
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    } else {
      bibleController.sheetHeight.value = 300.0;
    }
  }

  void _applyHighlight(int colorIndex, BibleController bibleController) {
    bibleController.saveHighlight(selectedVerses, colorIndex);
    Get.back();
  }
}