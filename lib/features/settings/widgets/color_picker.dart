import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';

class ColorPicker extends StatelessWidget {
  const ColorPicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final ItemScrollController itemScrollController = ItemScrollController();

    return GetBuilder<AppController>(
      builder: (controller) {
        // Auto-scroll to current color on first build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          itemScrollController.jumpTo(index: controller.colorSliderIdx.value);
        });

        return ScrollablePositionedList.separated(
          scrollDirection: Axis.horizontal,
          itemCount: AppColors.themeColors.length,
          separatorBuilder: (context, index) => const SizedBox(width: 5),
          itemBuilder: (context, index) {
            final isSelected = controller.colorSliderIdx.value == index;
            
            return InkWell(
              onTap: () => _selectColor(index, controller, context),
              child: CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.themeColors[index],
                child: isSelected 
                    ? Icon(Icons.check, color: controller.textColorDynamic.value)
                    : null,
              ),
            );
          },
          itemScrollController: itemScrollController,
        );
      },
    );
  }

  void _selectColor(int index, AppController controller, BuildContext context) {
    controller.updateColorTheme(index);
    
    // Update theme mode based on color selection
    if (index == 0) {
      AdaptiveTheme.of(context).setLight();
      controller.updateTextColor(1);
    } else if (index == 1) {
      AdaptiveTheme.of(context).setDark();
      controller.updateTextColor(0);
    } else {
      AdaptiveTheme.of(context).setLight();
      controller.updateTextColor(1);
    }
  }
}