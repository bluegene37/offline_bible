import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

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
            indicatorColor:
                AppColors.themeColorShades[controller.colorThemeName.value],
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black, // Dark text on light indicator
                );
              }
              return const TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(
                  color: Colors.black, // Dark icon on light indicator
                );
              }
              return null; // Default theme color (White in dark mode, Black in light mode)
            }),
          ),
          child: NavigationBar(
            height: 60,
            selectedIndex: controller.globalIndex.value,
            onDestinationSelected: (index) =>
                _handleNavigation(index, controller),
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
        controller.barTitle.value = "Notes | Highlights";
        break;
      case AppConstants.settingsPageIndex:
        controller.barTitle.value = "Settings";
        break;
    }
  }
}
