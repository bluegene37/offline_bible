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
import '../../bible/widgets/floating_navigation.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find<AppController>();

    return Obx(() {
      final int currentIndex = appController.globalIndex.value;

      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: appController.activeThemeColor,
          title: Obx(() => Text(
            appController.barTitle.value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          )),
        ),
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
