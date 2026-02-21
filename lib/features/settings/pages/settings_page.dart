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
    return Scaffold(
      body: GetBuilder<AppController>(
        builder: (controller) => SettingsList(
          sections: [
            _buildVersionSection(controller),
            _buildFontSection(controller),
            _buildThemeSection(),
            _buildAppInfoSection(),
          ],
        ),
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
          title: Text(
              'Font Size: ${(controller.fontSize.value + 15).toStringAsFixed(2)}'),
          value: Slider(
            min: 0.0,
            max: 15.0,
            value: controller.fontSize.value,
            onChanged: (value) => controller.updateFontSize(value),
          ),
        ),
        CustomSettingsTile(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Text Preview:'),
                const SizedBox(height: 10),
                FontPreview(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  SettingsSection _buildThemeSection() {
    return SettingsSection(
      title: const Text('Appearance'),
      tiles: [
        CustomSettingsTile(
          child: GetBuilder<AppController>(
            builder: (controller) => SwitchListTile(
              title: const Text('Keep Screen On'),
              value: controller.keepScreenOn.value,
              onChanged: (value) => controller.toggleKeepScreenOn(value),
            ),
          ),
        ),
        CustomSettingsTile(
          child: GetBuilder<AppController>(
            builder: (controller) => SwitchListTile(
              title: const Text('Dark Mode'),
              value: controller.themeMode.value,
              onChanged: (value) =>
                  controller.toggleThemeMode(value, Get.context!),
            ),
          ),
        ),
        CustomSettingsTile(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const Text('Font'),
                const Spacer(),
                SizedBox(
                  width: 160,
                  child: FontPicker(),
                ),
              ],
            ),
          ),
        ),
        CustomSettingsTile(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Theme Colors'),
                const SizedBox(height: 10),
                ColorPicker(),
              ],
            ),
          ),
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
