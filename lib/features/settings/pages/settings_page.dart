import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/controllers/app_controller.dart';
import '../../bible/services/version_service.dart';
import '../widgets/font_picker.dart';
import '../widgets/color_picker.dart';
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
  
  Widget _buildSectionHeader(BuildContext context, String title, AppController controller) {
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

  Widget _buildVerseOfTheDayCard(AppController appController, bool isDark) {
    // Deterministic verse selection based on day
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
      {'book': 'Matthew', 'chapter': 11, 'verse': 28, 'text': 'Come unto me, all ye that labour and are heavy laden, and I will give you rest.'},
      {'book': '2 Timothy', 'chapter': 1, 'verse': 7, 'text': 'For God hath not given us the spirit of fear; but of power, and of love, and of a sound mind.'},
      {'book': 'Joshua', 'chapter': 1, 'verse': 9, 'text': 'Have not I commanded thee? Be strong and of a good courage; be not afraid, neither be thou dismayed: for the LORD thy God is with thee whithersoever thou goest.'},
    ];
    
    final seed = dayOfYear % verses.length;
    final votd = verses[seed];

    return Obx(() {
      final isDarkMode = appController.themeMode.value;
      final accentColor = appController.activeThemeColor;

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
                  : [accentColor.withValues(alpha: 0.1), accentColor.withValues(alpha: 0.03)],
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
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 20),
                    tooltip: 'Copy Verse',
                    onPressed: () {
                      final str = '"${votd['text']}" - ${votd['book']} ${votd['chapter']}:${votd['verse']}';
                      Clipboard.setData(ClipboardData(text: str));
                      Get.snackbar('Copied', 'Verse of the Day copied');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_rounded, size: 20),
                    tooltip: 'Share Verse',
                    onPressed: () {
                      final str = '"${votd['text']}" - ${votd['book']} ${votd['chapter']}:${votd['verse']}';
                      SharePlus.instance.share(ShareParams(text: str));
                    },
                  ),
                  TextButton.icon(
                    onPressed: () {
                      appController.navigateToVerse(votd['book'] as String, votd['chapter'] as int, votd['verse'] as int);
                    },
                    icon: const Icon(Icons.read_more_rounded, size: 18),
                    label: const Text('Read Chapter'),
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
          onTap: () =>
              controller.navigateToPage(AppConstants.notesPageIndex),
        ),
        ListTile(
          leading: const Icon(Icons.calendar_month_outlined),
          title: const Text('Reading Plans'),
          onTap: () =>
              controller.navigateToPage(AppConstants.plansPageIndex),
        ),
      ],
    );
  }

  Widget _buildVersionSection(AppController controller) {
    final activeVersion = VersionService.byAbbrev(controller.bibleVersion.value);
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
        Padding(
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
      ],
    );
  }

  Widget _buildAppearanceSection(AppController controller, BuildContext context) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                  onSelectionChanged: (selection) => controller.setThemePref(
                      selection.first, context),
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
      builder: (controller) => SwitchListTile(
        title: const Text('Keep Screen On'),
        value: controller.keepScreenOn.value,
        activeColor: controller.activeThemeColor,
        onChanged: (value) => controller.toggleKeepScreenOn(value),
      ),
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
      return '2.0.0+6';
    }
  }
}
