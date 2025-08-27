import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../widgets/font_picker.dart';
import '../widgets/color_picker.dart';
import '../widgets/font_preview.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();

    return Scaffold(
      body: GetBuilder<AppController>(
        builder: (controller) {
          return SettingsList(
            sections: [
              _buildVersionSection(controller),
              _buildFontSection(controller),
              _buildThemeSection(),
              _buildAppInfoSection(),
            ],
          );
        },
      ),
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
          title: Text('Font Size: ${(controller.fontSize.value + 15).toStringAsFixed(2)}'),
          value: Slider(
            min: 0.0,
            max: 15.0,
            value: controller.fontSize.value,
            onChanged: (value) => controller.updateFontSize(value),
          ),
        ),
        const SettingsTile(
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
        const SettingsTile(
          title: Text('Font'),
          value: FontPicker(),
        ),
        const SettingsTile(
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