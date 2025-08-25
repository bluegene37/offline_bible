import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../bible/pages/bible_page.dart';
import '../../bible/pages/books_page.dart';
import '../../bible/pages/chapter_page.dart';
import '../../search/pages/search_page.dart';
import '../../notes/pages/notes_page.dart';
import '../../settings/pages/settings_page.dart';

class BottomNavigation extends StatelessWidget {
  final Function(int) onTabSelected;

  const BottomNavigation({
    Key? key,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();

    return GetBuilder<AppController>(
      builder: (controller) {
        return NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: AppColors.themeColorShades[controller.colorSliderIdx.value],
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ),
          child: NavigationBar(
            height: 60,
            selectedIndex: controller.globalIndex.value,
            onDestinationSelected: (index) => _handleNavigation(index, controller),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                label: 'Books',
              ),
              NavigationDestination(
                icon: Icon(Icons.library_books_outlined),
                label: 'Chapters',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_stories_outlined),
                label: 'Bible',
              ),
              NavigationDestination(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.edit_note_sharp),
                label: 'Notes',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleNavigation(int index, AppController controller) {
    onTabSelected(index);
    controller.navigateToPage(index);
    
    switch (index) {
      case AppConstants.booksPageIndex:
        controller.barTitle.value = "Books (66)";
        Get.to(() => const BooksPage());
        break;
      case AppConstants.chaptersPageIndex:
        controller.barTitle.value = "Chapters";
        Get.to(() => const ChapterPage());
        break;
      case AppConstants.biblePageIndex:
        controller.barTitle.value = 
            '${controller.bookSelected.value} ${controller.selectedChapter.value}';
        Get.to(() => BiblePage(
          bookTitle: controller.bookSelected.value,
          chapter: controller.selectedChapter.value,
        ));
        break;
      case AppConstants.searchPageIndex:
        controller.barTitle.value = "Search";
        Get.to(() => const SearchPage());
        break;
      case AppConstants.notesPageIndex:
        controller.barTitle.value = "Notes | Highlights";
        Get.to(() => const NotesPage());
        break;
      case AppConstants.settingsPageIndex:
        controller.barTitle.value = "Settings";
        Get.to(() => const SettingsPage());
        break;
    }
  }
}