import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';
import '../../../core/controllers/app_controller.dart';
import '../widgets/font_picker.dart';
import '../widgets/color_picker.dart';
import '../widgets/font_preview.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find<AppController>();

    return Scaffold(
      body: Obx(() => SettingsList(
            sections: [
              _buildVersionSection(appController),
              _buildFontSection(appController),
              _buildThemeSection(),
              _buildAppInfoSection(),
            ],
          )),
    );
  }

  SettingsSection _buildVersionSection(AppController controller) {
    return SettingsSection(
      tiles: [
        SettingsTile.navigation(
          title: const Text('Bible Version: (more to come)'),
          value: Text(controller.bibleVersion),
        ),
      ],
    );
  }

  SettingsSection _buildFontSection(AppController controller) {
    return SettingsSection(
      tiles: [
        SettingsTile(
          title: Obx(() => Text(
              'Font Size: ${(controller.fontSize.value + 15).toStringAsFixed(2)}')),
          value: Obx(() => Slider(
                min: 0.0,
                max: 15.0,
                value: controller.fontSize.value,
                onChanged: (value) => controller.updateFontSize(value),
              )),
        ),
        SettingsTile(
          title: Text('Text Preview:'),
          value: FontPreview(),
        ),
      ],
    );
  }

  SettingsSection _buildThemeSection() {
    return SettingsSection(
      title: const Text('Appearance'),
      tiles: [
        SettingsTile.switchTile(
          title: const Text('Dark Mode'),
          initialValue: Get.find<AppController>().themeMode.value,
          onToggle: (value) =>
              Get.find<AppController>().toggleThemeMode(value, Get.context!),
        ),
        SettingsTile(
          title: Text('Font'),
          value: FontPicker(),
        ),
        SettingsTile(
          title: Text('Theme Colors'),
          value: ColorPicker(),
        ),
      ],
    );
  }

  SettingsSection _buildAppInfoSection() {
    return SettingsSection(
      title: const Text('About'),
      tiles: [
        SettingsTile(
          title: const Text('App Version'),
          value: FutureBuilder<String>(
            future: _getVersionInfo(),
            builder: (context, snapshot) {
              return Text(snapshot.data ?? 'Loading...');
            },
          ),
        ),
      ],
    );
  }

  Future<String> _getVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (e) {
      return '2.0.0+6';
    }
  }
}
