import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outline_search_bar/outline_search_bar.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/search_controller.dart';
import '../widgets/search_results_list.dart';
import '../widgets/search_history_list.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchController = Get.put(BibleSearchController());

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GetBuilder<AppController>(
        builder: (controller) {
          return Column(
            children: [
              _buildSearchBar(controller, searchController, context),
              _buildFilterChips(controller, searchController),
              Expanded(
                child: Obx(() => searchController.hideHistory.value
                    ? SearchResultsList(
                        query: searchController.searchQuery.value)
                    : const SearchHistoryList()),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(AppController appController,
      BibleSearchController searchController, BuildContext context) {
    return Obx(() => OutlineSearchBar(
          focusNode: FocusNode(),
          clearButtonColor: _getClearButtonColor(appController),
          cursorColor: _getCursorColor(appController),
          searchButtonIconColor: _getSearchIconColor(appController),
          borderColor: _getBorderColor(appController),
          margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          textEditingController: searchController.textController,
          initText: searchController.searchQuery.value,
          hintText: 'Search here...',
          onSearchButtonPressed: (query) =>
              searchController.performSearch(query),
          onClearButtonPressed: (query) =>
              searchController.clearSearch(context),
          onKeywordChanged: (query) => searchController.updateQuery(query),
        ));
  }

  Widget _buildFilterChips(
      AppController appController, BibleSearchController searchController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('All', searchController, appController),
          const SizedBox(width: 8),
          _buildFilterChip('Old Testament', searchController, appController),
          const SizedBox(width: 8),
          _buildFilterChip('New Testament', searchController, appController),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, BibleSearchController searchController,
      AppController appController) {
    return Obx(() {
      final isSelected = searchController.searchScope.value == label;
      final themeColor =
          AppColors.themeColors[appController.colorThemeName.value]!;

      return FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) searchController.setSearchScope(label);
        },
        backgroundColor: Colors.transparent,
        selectedColor: themeColor.withValues(alpha: 0.2),
        checkmarkColor: themeColor,
        labelStyle: TextStyle(
          color: isSelected ? themeColor : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? themeColor : Colors.grey.withValues(alpha: 0.5),
          ),
        ),
      );
    });
  }

  Color _getClearButtonColor(AppController controller) {
    return AppColors.themeColors[controller.colorThemeName.value]!;
  }

  Color _getCursorColor(AppController controller) {
    return controller.colorThemeName.value == 'Black'
        ? AppColors.textColors[controller.textColorIdx.value]
        : AppColors.themeColors[controller.colorThemeName.value]!;
  }

  Color _getSearchIconColor(AppController controller) {
    return controller.colorThemeName.value == 'Black'
        ? AppColors.textColors[controller.textColorIdx.value]
        : AppColors.themeColors[controller.colorThemeName.value]!;
  }

  Color _getBorderColor(AppController controller) {
    return controller.colorThemeName.value == 'Black'
        ? AppColors.textColors[controller.textColorIdx.value]
        : AppColors.themeColors[controller.colorThemeName.value]!;
  }
}
