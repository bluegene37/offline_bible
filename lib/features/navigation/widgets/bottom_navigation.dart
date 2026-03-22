import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/constants/app_constants.dart';

class BottomNavigation extends StatelessWidget {
  final Function(int) onTabSelected;

  const BottomNavigation({
    super.key,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        return NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: controller.themeMode.value
                ? Colors.grey.shade800
                : controller.activeThemeShade,
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: controller.themeMode.value ? Colors.white : Colors.black,
                );
              }
              return const TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return IconThemeData(
                  color: controller.themeMode.value ? Colors.white : Colors.black,
                );
              }
              return null;
            }),
          ),
          child: NavigationBar(
            height: 60,
            selectedIndex: controller.globalIndex.value,
            onDestinationSelected: (index) {
              _handleNavigation(index, controller);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.library_books_outlined),
                selectedIcon: Icon(Icons.library_books),
                label: 'Books',
              ),
              NavigationDestination(
                icon: Icon(Icons.format_list_numbered),
                label: 'Chapters',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Bible',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.collections_bookmark_outlined),
                selectedIcon: Icon(Icons.collections_bookmark),
                label: 'Saved',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
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
        break;
      case AppConstants.chaptersPageIndex:
        controller.barTitle.value = "Chapters";
        break;
      case AppConstants.biblePageIndex:
        controller.barTitle.value =
            '${controller.bookSelected.value} ${controller.selectedChapter.value}';
        break;
      case AppConstants.searchPageIndex:
        controller.barTitle.value = "Search";
        break;
      case AppConstants.notesPageIndex:
        controller.barTitle.value = "Saved Items";
        break;
      case AppConstants.settingsPageIndex:
        controller.barTitle.value = "Settings";
        break;
    }
  }
}
