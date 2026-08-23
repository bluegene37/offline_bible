import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/controllers/app_controller.dart';
import '../../bible/services/bible_service.dart';
import '../../bible/services/version_service.dart';
import '../widgets/font_picker.dart';
import '../../../core/widgets/color_picker.dart';
import '../widgets/font_preview.dart';
import '../widgets/version_manager_sheet.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<AppController>(
        builder: (controller) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _buildVerseOfTheDayCard(controller, isDark),
              _buildSectionHeader(context, 'Library', controller),
              _buildLibrarySection(controller),
              _buildSectionHeader(context, 'Bible', controller),
              _buildVersionSection(controller),
              _buildSectionHeader(context, 'Reading', controller),
              _buildReadingSection(controller),
              _buildSectionHeader(context, 'Appearance', controller),
              _buildAppearanceSection(controller, context),
              _buildSectionHeader(context, 'General', controller),
              _buildGeneralSection(controller),
              _buildSectionHeader(context, 'About', controller),
              _buildAppInfoSection(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, AppController controller) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: controller.activeThemeColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  /// A fixed rotation of well-known references. Only the reference is fixed —
  /// the wording is read from whichever translation is active, so the card no
  /// longer shows KJV text under a WEB or ASV header.
  static const List<Map<String, Object>> _votdReferences = [
    {'book': 'John', 'chapter': 3, 'verse': 16},
    {'book': 'Philippians', 'chapter': 4, 'verse': 13},
    {'book': 'Psalms', 'chapter': 23, 'verse': 1},
    {'book': 'Proverbs', 'chapter': 3, 'verse': 5},
    {'book': 'Romans', 'chapter': 8, 'verse': 28},
    {'book': 'Jeremiah', 'chapter': 29, 'verse': 11},
    {'book': 'Isaiah', 'chapter': 41, 'verse': 10},
    {'book': 'Matthew', 'chapter': 11, 'verse': 28},
    {'book': '2 Timothy', 'chapter': 1, 'verse': 7},
    {'book': 'Joshua', 'chapter': 1, 'verse': 9},
  ];

  Widget _buildVerseOfTheDayCard(AppController appController, bool isDark) {
    final now = DateTime.now();
    final dayStamp = int.parse('${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}');
    final reference = _votdReferences[dayStamp % _votdReferences.length];
    final book = reference['book'] as String;
    final chapter = reference['chapter'] as int;
    final verseNumber = reference['verse'] as int;
    final label = '$book $chapter:$verseNumber';

    return Obx(() {
      final isDarkMode = appController.themeMode.value;
      final accentColor = appController.activeThemeColor;

      // Depend on the active version so switching translations re-reads the
      // text rather than leaving the previous translation's wording on screen.
      appController.bibleVersion.value;
      final verse = BibleService.verseOrNull(book, chapter, verseNumber);
      final verseText = verse?.text;

      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        color: isDark ? Colors.grey.shade900 : Colors.white,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [Colors.grey.shade800, Colors.grey.shade900]
                  : [
                      accentColor.withValues(alpha: 0.1),
                      accentColor.withValues(alpha: 0.03),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.wb_sunny_rounded, size: 20, color: accentColor),
                  const SizedBox(width: 8),
                  Text(
                    'VERSE OF THE DAY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                verseText == null ? label : '"$verseText"',
                style: TextStyle(
                  fontFamily: appController.globalFont.value,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 20),
                    tooltip: 'Copy verse',
                    onPressed: verseText == null
                        ? null
                        : () {
                            Clipboard.setData(
                                ClipboardData(text: '"$verseText" - $label'));
                            Get.snackbar('Copied', 'Verse of the Day copied');
                          },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_rounded, size: 20),
                    tooltip: 'Share verse',
                    onPressed: verseText == null
                        ? null
                        : () => SharePlus.instance
                            .share(ShareParams(text: '"$verseText" - $label')),
                  ),
                  TextButton.icon(
                    onPressed: () => appController.navigateToVerse(
                        book, chapter, verseNumber),
                    icon: const Icon(Icons.read_more_rounded, size: 18),
                    label: const Text('Read chapter'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildLibrarySection(AppController controller) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.collections_bookmark_outlined),
          title: const Text('Saved Items'),
          subtitle: const Text('Notes, highlights and bookmarks'),
          onTap: () => controller.navigateToPage(AppConstants.notesPageIndex),
        ),
        ListTile(
          leading: const Icon(Icons.calendar_month_outlined),
          title: const Text('Reading Plans'),
          onTap: () => controller.navigateToPage(AppConstants.plansPageIndex),
        ),
      ],
    );
  }

  Widget _buildVersionSection(AppController controller) {
    final activeVersion =
        VersionService.byAbbrev(controller.bibleVersion.value);
    return ListTile(
      leading: const Icon(Icons.menu_book_rounded),
      title: const Text('Bible Version'),
      trailing: Text(activeVersion.name),
      onTap: () {
        Get.bottomSheet(
          const VersionManagerSheet(),
          isScrollControlled: true,
        );
      },
    );
  }

  Widget _buildReadingSection(AppController controller) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
        // Preview sits above the sliders: below them it scrolled out of view
        // exactly when you were dragging to see its effect. Its box is a fixed
        // height so growing the text cannot push the slider out from under
        // your finger either — it scrolls inside instead.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Text Preview:'),
              const SizedBox(height: 10),
              SizedBox(
                height: 130,
                width: double.infinity,
                child: SingleChildScrollView(child: FontPreview()),
              ),
            ],
          ),
        ),
        ListTile(
          title: Text('Font Size: ${controller.fontSize.value.round()}'),
          subtitle: Slider(
            min: AppConstants.minFontSize,
            max: AppConstants.maxFontSize,
            divisions:
                (AppConstants.maxFontSize - AppConstants.minFontSize).round(),
            value: controller.fontSize.value,
            activeColor: controller.activeThemeColor,
            onChanged: (value) => controller.updateFontSize(value),
          ),
        ),
        ListTile(
          title: Text(
              'Line Spacing: ${controller.lineHeight.value.toStringAsFixed(1)}'),
          subtitle: Slider(
            min: AppConstants.minLineHeight,
            max: AppConstants.maxLineHeight,
            divisions: 8,
            value: controller.lineHeight.value,
            activeColor: controller.activeThemeColor,
            onChanged: (value) => controller.updateLineHeight(value),
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(
      AppController controller, BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              const Text('Theme'),
              const Spacer(),
              GetBuilder<AppController>(
                builder: (controller) => SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'system',
                      label: Text('Auto'),
                      icon: Icon(Icons.brightness_auto, size: 18),
                    ),
                    ButtonSegment(
                      value: 'light',
                      label: Text('Light'),
                      icon: Icon(Icons.light_mode, size: 18),
                    ),
                    ButtonSegment(
                      value: 'dark',
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode, size: 18),
                    ),
                  ],
                  selected: {controller.themePref.value},
                  showSelectedIcon: false,
                  onSelectionChanged: (selection) =>
                      controller.setThemePref(selection.first, context),
                ),
              ),
            ],
          ),
        ),
        Padding(
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
      ],
    );
  }

  Widget _buildGeneralSection(AppController controller) {
    return GetBuilder<AppController>(
      builder: (controller) {
        final isKjv =
            controller.bibleVersion.value == AppConstants.defaultBibleVersion;
        return Column(
          children: [
            SwitchListTile(
              title: const Text('Words of Christ in red'),
              subtitle: Text(isKjv
                  ? 'Colours the words of Jesus while reading'
                  : 'Available in the King James Version only'),
              value: controller.redLetterEnabled.value && isKjv,
              activeThumbColor: controller.activeThemeColor,
              onChanged: isKjv ? controller.toggleRedLetter : null,
            ),
            SwitchListTile(
              title: const Text('Keep Screen On'),
              value: controller.keepScreenOn.value,
              activeThumbColor: controller.activeThemeColor,
              onChanged: (value) => controller.toggleKeepScreenOn(value),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppInfoSection() {
    return ListTile(
      title: const Text('App Version'),
      trailing: FutureBuilder<String>(
        future: _getVersionInfo(),
        builder: (context, snapshot) {
          return Text(snapshot.data ?? 'Loading...');
        },
      ),
    );
  }

  Future<String> _getVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (e) {
      return '1.0.0+1';
    }
  }
}
