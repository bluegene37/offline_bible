import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/constants/app_constants.dart';

class BottomNavigation extends StatelessWidget {
  final Function(int) onTabSelected;

  static const List<int> _barPageIndices = [
    AppConstants.booksPageIndex,
    AppConstants.chaptersPageIndex,
    AppConstants.biblePageIndex,
    AppConstants.searchPageIndex,
    AppConstants.settingsPageIndex,
  ];

  const BottomNavigation({
    super.key,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        final barPosition =
            _barPageIndices.indexOf(controller.globalIndex.value);
        final selectedIndex =
            barPosition != -1 ? barPosition : _barPageIndices.length - 1;

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final barColor = isDark
            ? const Color(0xFF1E1E1E).withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.92);

        return ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white24 : Colors.black12,
                    width: 0.5,
                  ),
                ),
              ),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  backgroundColor: Colors.transparent,
                  indicatorColor: controller.activeThemeColor.withValues(alpha: isDark ? 0.35 : 0.2),
                  indicatorShape: const StadiumBorder(),
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      );
                    }
                    return TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white60 : Colors.black54);
                  }),
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return IconThemeData(
                        color: isDark ? Colors.white : controller.activeThemeColor,
                      );
                    }
                    return IconThemeData(
                      color: isDark ? Colors.white60 : Colors.black54,
                    );
                  }),
                ),
                child: NavigationBar(
                  height: 64,
                  elevation: 0,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) {
                    HapticFeedback.selectionClick();
                    _handleNavigation(_barPageIndices[index], controller);
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.library_books_outlined),
                      selectedIcon: Icon(Icons.library_books),
                      label: 'Books',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.grid_view_outlined),
                      selectedIcon: Icon(Icons.grid_view_rounded),
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
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: 'Settings',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleNavigation(int pageIndex, AppController controller) {
    // onTabSelected already routes to navigateToPage; calling it again here
    // cleared the verse selection and rewrote the title a second time.
    onTabSelected(pageIndex);
  }
}
