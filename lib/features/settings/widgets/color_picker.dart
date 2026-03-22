import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';

class ColorPicker extends StatelessWidget {
  const ColorPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final ItemScrollController itemScrollController = ItemScrollController();
    final themeKeys = AppColors.themeColors.keys.toList();

    // Auto-scroll to current color on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialIndex =
          themeKeys.indexOf(appController.colorThemeName.value);
      if (initialIndex != -1) {
        itemScrollController.jumpTo(index: initialIndex);
      }
    });

    return SizedBox(
      height: 50,
      child: ScrollablePositionedList.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppColors.themeColors.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final themeName = themeKeys[index];
          final color = AppColors.themeColors[themeName]!;

          return Obx(() {
            final isSelected = appController.colorThemeName.value == themeName;
            return InkWell(
              onTap: () => _selectColor(themeName, appController, context),
              child: CircleAvatar(
                radius: 25,
                backgroundColor: color,
                child: isSelected
                    ? Icon(Icons.check,
                        color: appController.textColorDynamic.value)
                    : null,
              ),
            );
          });
        },
        itemScrollController: itemScrollController,
      ),
    );
  }

  void _selectColor(
      String themeName, AppController controller, BuildContext context) {
    controller.updateColorTheme(themeName);
  }
}
