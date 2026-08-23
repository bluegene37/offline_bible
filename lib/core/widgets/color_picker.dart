import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../controllers/app_controller.dart';
import '../theme/app_colors.dart';

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

          // Contrast is judged against the swatch itself, not the active accent.
          // The two differ: the swatch shows the raw seed, while the accent is
          // the tonal primary derived from it, so the pale seeds (Sunset Amber,
          // Ocean Cyan…) were drawing a white tick on a near-white circle.
          final tick =
              ThemeData.estimateBrightnessForColor(color) == Brightness.light
                  ? Colors.black
                  : Colors.white;

          return Obx(() {
            final isSelected = appController.colorThemeName.value == themeName;
            return Semantics(
              label: themeName,
              button: true,
              selected: isSelected,
              child: InkWell(
                onTap: () => _selectColor(themeName, appController, context),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: color,
                  child: isSelected ? Icon(Icons.check, color: tick) : null,
                ),
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
