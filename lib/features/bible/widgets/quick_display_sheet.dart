import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/color_picker.dart';

class QuickDisplaySheet extends StatelessWidget {
  const QuickDisplaySheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuickDisplaySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find<AppController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Material(
      color: bgColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Padding(
        padding:
            const EdgeInsets.only(bottom: 32, left: 24, right: 24, top: 12),
        // Scrollable because the sheet is now tall enough to overrun a short
        // screen once the system text scale is turned up.
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Display',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Theme Toggle
              Obx(() => SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                          value: 'light',
                          icon: Icon(Icons.light_mode),
                          label: Text('Light')),
                      ButtonSegment(
                          value: 'dark',
                          icon: Icon(Icons.dark_mode),
                          label: Text('Dark')),
                      ButtonSegment(
                          value: 'system',
                          icon: Icon(Icons.settings_system_daydream),
                          label: Text('System')),
                    ],
                    selected: {appController.themePref.value},
                    onSelectionChanged: (Set<String> newSelection) {
                      appController.setThemePref(newSelection.first, context);
                    },
                  )),
              const SizedBox(height: 24),

              // Font Size
              Row(
                children: [
                  const Icon(Icons.text_decrease, size: 20),
                  Expanded(
                    child: Obx(() => Slider(
                          value: appController.fontSize.value,
                          min: AppConstants.minFontSize,
                          max: AppConstants.maxFontSize,
                          divisions: ((AppConstants.maxFontSize -
                                      AppConstants.minFontSize) /
                                  2)
                              .round(),
                          label: '${appController.fontSize.value.round()}',
                          onChanged: (value) =>
                              appController.updateFontSize(value),
                        )),
                  ),
                  const Icon(Icons.text_increase, size: 28),
                ],
              ),

              // Line Spacing
              Row(
                children: [
                  const Icon(Icons.format_line_spacing, size: 20),
                  Expanded(
                    child: Obx(() => Slider(
                          value: appController.lineHeight.value,
                          min: AppConstants.minLineHeight,
                          max: AppConstants.maxLineHeight,
                          divisions: 10,
                          label:
                              appController.lineHeight.value.toStringAsFixed(1),
                          onChanged: (value) =>
                              appController.updateLineHeight(value),
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Theme Colors — the same picker Settings uses, so a colour chosen
              // here and one chosen there are visibly the same control.
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Theme Colors',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 10),
              const ColorPicker(),
            ],
          ),
        ),
      ),
    );
  }
}
