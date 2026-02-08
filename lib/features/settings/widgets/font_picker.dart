import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class FontPicker extends StatelessWidget {
  const FontPicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    return Obx(() {
      final currentFont = appController.globalFont.value;

      return InkWell(
        onTap: () => _showFontSelectionSheet(context, appController),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  currentFont,
                  style: GoogleFonts.getFont(
                    currentFont,
                    fontSize: 18,
                    color: appController.themeMode.value
                        ? Colors.white
                        : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      );
    });
  }

  void _showFontSelectionSheet(BuildContext context, AppController controller) {
    final ItemScrollController itemScrollController = ItemScrollController();
    final initialIndex =
        AppConstants.fontOptions.indexOf(controller.globalFont.value);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (itemScrollController.isAttached) {
        itemScrollController.jumpTo(index: initialIndex, alignment: 0.5);
      }
    });

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Select Font',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors
                          .themeColors[controller.colorThemeName.value],
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ScrollablePositionedList.builder(
                    itemScrollController: itemScrollController,
                    itemCount: AppConstants.fontOptions.length,
                    itemBuilder: (context, index) {
                      final font = AppConstants.fontOptions[index];
                      return Obx(() {
                        final isSelected = controller.globalFont.value == font;
                        return ListTile(
                          title: Text(
                            font,
                            style: GoogleFonts.getFont(
                              font,
                              fontSize: 18,
                              color: isSelected
                                  ? AppColors.themeColors[
                                      controller.colorThemeName.value]
                                  : (controller.themeMode.value
                                      ? Colors.white
                                      : Colors.black87),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check,
                                  color: AppColors.themeColors[
                                      controller.colorThemeName.value])
                              : null,
                          onTap: () {
                            controller.updateFont(font);
                            Navigator.pop(context);
                          },
                        );
                      });
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
