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
    final appController = Get.find<AppController>();
    final searchController = Get.put(SearchController());

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GetBuilder<AppController>(
        builder: (controller) {
          return Stack(
            children: [
              Obx(() => searchController.hideHistory.value
                  ? SearchResultsList(query: searchController.searchQuery.value)
                  : const SearchHistoryList()),
              _buildSearchBar(controller, searchController, context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(AppController appController, SearchController searchController, 
                        BuildContext context) {
    return Obx(() => OutlineSearchBar(
      focusNode: FocusNode(),
      clearButtonColor: _getClearButtonColor(appController),
      cursorColor: _getCursorColor(appController),
      searchButtonIconColor: _getSearchIconColor(appController),
      borderColor: _getBorderColor(appController),
      margin: const EdgeInsets.all(8.0),
      textEditingController: searchController.textController,
      initText: searchController.searchQuery.value,
      hintText: 'Search here...',
      onSearchButtonPressed: (query) => searchController.performSearch(query),
      onClearButtonPressed: (query) => searchController.clearSearch(context),
      onKeywordChanged: (query) => searchController.updateQuery(query),
    ));
  }

  Color _getClearButtonColor(AppController controller) {
    return controller.colorSliderIdx.value == 0
        ? AppColors.textColors[controller.textColorIdx.value]
        : AppColors.themeColors[controller.colorSliderIdx.value];
  }

  Color _getCursorColor(AppController controller) {
    return controller.colorSliderIdx.value == 0 || controller.colorSliderIdx.value == 1
        ? AppColors.textColors[controller.textColorIdx.value]
        : AppColors.themeColors[controller.colorSliderIdx.value];
  }

  Color _getSearchIconColor(AppController controller) {
    return controller.colorSliderIdx.value == 0 || controller.colorSliderIdx.value == 1
        ? AppColors.textColors[controller.textColorIdx.value]
        : AppColors.themeColors[controller.colorSliderIdx.value];
  }

  Color _getBorderColor(AppController controller) {
    return controller.colorSliderIdx.value == 0 || controller.colorSliderIdx.value == 1
        ? AppColors.textColors[controller.textColorIdx.value]
        : AppColors.themeColors[controller.colorSliderIdx.value];
  }
}