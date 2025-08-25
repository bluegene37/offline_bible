import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:substring_highlight/substring_highlight.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../bible/controllers/bible_controller.dart';
import '../../bible/pages/bible_page.dart';

class SearchResultsList extends StatelessWidget {
  final String query;

  const SearchResultsList({
    Key? key,
    required this.query,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final bibleController = Get.find<BibleController>();

    return GetBuilder<BibleController>(
      builder: (controller) {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.searchResults.isEmpty && query.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'No Result for: $query',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          );
        }

        if (controller.searchResults.isEmpty) {
          return const Center(child: Text(' '));
        }

        return Container(
          margin: const EdgeInsets.only(top: 59.0),
          child: ScrollablePositionedList.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: controller.searchResults.length,
            padding: const EdgeInsets.only(top: 10.0),
            itemBuilder: (context, index) {
              final verse = controller.searchResults[index];
              
              return Card(
                child: GetBuilder<AppController>(
                  builder: (appCtrl) {
                    return ListTile(
                      title: SubstringHighlight(
                        text: '${verse.book} ${verse.chapter}:${verse.verse}',
                        term: query,
                        textStyle: TextStyle(
                          fontSize: 15,
                          color: AppColors.textColors[appCtrl.textColorIdx.value],
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                        ),
                        textStyleHighlight: TextStyle(
                          color: _getHighlightColor(appCtrl),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      subtitle: SubstringHighlight(
                        text: verse.text,
                        term: query,
                        textStyle: TextStyle(
                          fontSize: 17,
                          color: AppColors.textColors[appCtrl.textColorIdx.value],
                          fontWeight: FontWeight.w300,
                        ),
                        textStyleHighlight: TextStyle(
                          color: _getHighlightColor(appCtrl),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      onTap: () => _navigateToVerse(verse, appCtrl),
                    );
                  },
                ),
              );
            },
            itemScrollController: controller.itemScrollController,
          ),
        );
      },
    );
  }

  Color _getHighlightColor(AppController controller) {
    return controller.colorSliderIdx.value == 0 || controller.colorSliderIdx.value == 1
        ? AppColors.textColors[controller.textColorIdx.value]
        : AppColors.themeColors[controller.colorSliderIdx.value];
  }

  void _navigateToVerse(verse, AppController controller) {
    controller.updateBookSelection(verse.book, verse.chapter);
    controller.navigateToPage(2); // Navigate to Bible page
    
    Get.to(() => BiblePage(
      bookTitle: verse.book,
      chapter: verse.chapter,
    ));
    
    // Jump to specific verse
    final bibleController = Get.find<BibleController>();
    Future.delayed(const Duration(milliseconds: 500), () {
      bibleController.jumpToVerse(verse.verse - 1);
    });
  }
}