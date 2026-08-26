import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../navigation/widgets/bottom_navigation.dart';
import '../../bible/pages/bible_page.dart';
import '../../bible/pages/books_page.dart';
import '../../bible/pages/chapter_page.dart';
import '../../search/pages/search_page.dart';
import '../../notes/pages/notes_page.dart';
import '../../settings/pages/settings_page.dart';
import '../../plans/pages/reading_plans_page.dart';
import '../../bible/widgets/floating_navigation.dart';
import '../../bible/widgets/quick_picker_sheet.dart';
import '../../bible/widgets/quick_display_sheet.dart';
import '../../settings/widgets/version_manager_sheet.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find<AppController>();

    return Obx(() {
      final int currentIndex = appController.globalIndex.value;

      return Scaffold(
        appBar: _buildAppBar(appController, context, currentIndex),
        body: SafeArea(child: _getCurrentPage(currentIndex)),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _shouldShowFloatingButton(appController)
            ? const FloatingNavigation()
            : null,
        bottomNavigationBar: BottomNavigation(
          onTabSelected: (index) => appController.navigateToPage(index),
        ),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(
      AppController controller, BuildContext context, int currentIndex) {
    if (currentIndex == AppConstants.biblePageIndex) {
      return AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                QuickPickerSheet.show(context);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() => Text(
                          '${controller.bookSelected.value} ${controller.selectedChapter.value}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        )),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                Get.bottomSheet(
                  const VersionManagerSheet(),
                  isScrollControlled: true,
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() => Text(
                          controller.bibleVersion.value.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        )),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_format),
            onPressed: () {
              QuickDisplaySheet.show(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              controller.navigateToPage(AppConstants.searchPageIndex);
            },
          ),
        ],
      );
    }

    return AppBar(
      centerTitle: true,
      elevation: 0,
      title: Obx(() => Text(
            currentIndex == AppConstants.chaptersPageIndex
                ? controller.bookSelected.value
                : controller.barTitle.value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          )),
    );
  }

  Widget _getCurrentPage(int index) {
    final AppController appController = Get.find<AppController>();
    switch (index) {
      case AppConstants.booksPageIndex:
        return const BooksPage();
      case AppConstants.chaptersPageIndex:
        return const ChapterPage();
      case AppConstants.biblePageIndex:
        return BiblePage(
          bookTitle: appController.bookSelected.value,
          chapter: appController.selectedChapter.value,
        );
      case AppConstants.plansPageIndex:
        return const ReadingPlansPage();
      case AppConstants.searchPageIndex:
        return const SearchPage();
      case AppConstants.notesPageIndex:
        return const NotesPage();
      case AppConstants.settingsPageIndex:
        return const SettingsPage();
      default:
        return BiblePage(
          bookTitle: appController.bookSelected.value,
          chapter: appController.selectedChapter.value,
        );
    }
  }

  bool _shouldShowFloatingButton(AppController controller) {
    return controller.globalIndex.value == AppConstants.biblePageIndex &&
        !controller.hideFloatingBtn.value &&
        controller.textUnderline.isEmpty;
  }
}
