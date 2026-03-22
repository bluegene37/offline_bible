import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/font_picker.dart';
import '../widgets/color_picker.dart';
import '../widgets/font_preview.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<AppController>(
        builder: (controller) => SettingsList(
          sections: [
            SettingsSection(
              margin: const EdgeInsetsDirectional.only(top: 8),
              tiles: [
                CustomSettingsTile(
                  child: _buildVerseOfTheDayCard(controller),
                ),
              ],
            ),
            _buildVersionSection(controller),
            _buildFontSection(controller),
            _buildThemeSection(controller),
            _buildAppInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseOfTheDayCard(AppController appController) {
    // A simple deterministic selection based on the current day of the year
    final now = DateTime.now();
    final dayOfYear = int.parse('${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}');
    
    final verses = [
      {'book': 'John', 'chapter': 3, 'verse': 16, 'text': 'For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.'},
      {'book': 'Philippians', 'chapter': 4, 'verse': 13, 'text': 'I can do all things through Christ which strengtheneth me.'},
      {'book': 'Psalms', 'chapter': 23, 'verse': 1, 'text': 'The LORD is my shepherd; I shall not want.'},
      {'book': 'Proverbs', 'chapter': 3, 'verse': 5, 'text': 'Trust in the LORD with all thine heart; and lean not unto thine own understanding.'},
      {'book': 'Romans', 'chapter': 8, 'verse': 28, 'text': 'And we know that all things work together for good to them that love God, to them who are the called according to his purpose.'},
      {'book': 'Jeremiah', 'chapter': 29, 'verse': 11, 'text': 'For I know the thoughts that I think toward you, saith the LORD, thoughts of peace, and not of evil, to give you an expected end.'},
      {'book': 'Isaiah', 'chapter': 41, 'verse': 10, 'text': 'Fear thou not; for I am with thee: be not dismayed; for I am thy God: I will strengthen thee; yea, I will help thee; yea, I will uphold thee with the right hand of my righteousness.'},
    ];
    
    final seed = dayOfYear % verses.length;
    final votd = verses[seed];

    return Obx(() {
      final isDarkMode = appController.themeMode.value;
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: InkWell(
          onTap: () {
            appController.navigateToVerse(votd['book'] as String, votd['chapter'] as int, votd['verse'] as int);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: isDarkMode 
                    ? [Colors.grey.shade800, Colors.grey.shade900]
                    : [appController.activeThemeColor?.withValues(alpha: 0.1) ?? Colors.grey.shade100, appController.activeThemeColor?.withValues(alpha: 0.05) ?? Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.wb_sunny_rounded, size: 20, color: appController.activeThemeColor),
                    const SizedBox(width: 8),
                    Text(
                      'VERSE OF THE DAY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: appController.activeThemeColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '"${votd['text']}"',
                  style: GoogleFonts.getFont(
                    appController.globalFont.value,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${votd['book']} ${votd['chapter']}:${votd['verse']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
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
            activeColor: controller.activeThemeColor,
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

  SettingsSection _buildThemeSection(AppController controller) {
    return SettingsSection(
      title: const Text('Appearance'),
      tiles: [
        CustomSettingsTile(
          child: GetBuilder<AppController>(
            builder: (controller) => SwitchListTile(
              title: const Text('Keep Screen On'),
              value: controller.keepScreenOn.value,
              activeThumbColor: controller.activeThemeColor,
              onChanged: (value) => controller.toggleKeepScreenOn(value),
            ),
          ),
        ),
        CustomSettingsTile(
          child: GetBuilder<AppController>(
            builder: (controller) {
              final themeColor = AppColors.themeColors[controller.colorThemeName.value];
              return SwitchListTile(
                title: const Text('Dark Mode'),
                value: controller.themeMode.value,
                activeThumbColor: null,
                inactiveThumbColor: themeColor,
                inactiveTrackColor: themeColor?.withValues(alpha: 0.3),
                onChanged: (value) =>
                    controller.toggleThemeMode(value, Get.context!),
              );
            },
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
        if (!controller.themeMode.value)
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
