import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../navigation/widgets/bottom_navigation.dart';
import '../../bible/pages/bible_page.dart';
import '../../bible/pages/books_page.dart';
import '../../bible/pages/chapter_page.dart';
import '../../search/pages/search_page.dart';
import '../../notes/pages/notes_page.dart';
import '../../settings/pages/settings_page.dart';
import '../../bible/widgets/floating_navigation.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppController appController = Get.find<AppController>();
  Widget currentPage = Container();

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  void _initializePage() {
    // Initialize with Bible page
    currentPage = BiblePage(
      bookTitle: appController.bookSelected.value,
      chapter: appController.selectedChapter.value,
    );
    appController.barTitle.value = 
        '${appController.bookSelected.value} ${appController.selectedChapter.value}';
  }

  void _onTabTapped(int index) {
    setState(() {
      appController.globalIndex.value = index;
      _updateCurrentPage(index);
    });
  }

  void _updateCurrentPage(int index) {
    switch (index) {
      case AppConstants.booksPageIndex:
        currentPage = const BooksPage();
        break;
      case AppConstants.chaptersPageIndex:
        currentPage = const ChapterPage();
        break;
      case AppConstants.biblePageIndex:
        currentPage = BiblePage(
          bookTitle: appController.bookSelected.value,
          chapter: appController.selectedChapter.value,
        );
        break;
      case AppConstants.searchPageIndex:
        currentPage = const SearchPage();
        break;
      case AppConstants.notesPageIndex:
        currentPage = const NotesPage();
        break;
      case AppConstants.settingsPageIndex:
        currentPage = const SettingsPage();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(35.0),
            child: AppBar(
              centerTitle: true,
              backgroundColor: AppColors.themeColors[controller.colorSliderIdx.value],
              title: Text(
                controller.barTitle.value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: controller.textColorDynamic.value,
                ),
              ),
            ),
          ),
          body: SafeArea(child: currentPage),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _shouldShowFloatingButton(controller)
              ? const FloatingNavigation()
              : null,
          bottomNavigationBar: BottomNavigation(onTabSelected: _onTabTapped),
        );
      },
    );
  }

  bool _shouldShowFloatingButton(AppController controller) {
    return controller.globalIndex.value == AppConstants.biblePageIndex &&
           !controller.hideFloatingBtn.value &&
           controller.textUnderline.isEmpty;
  }
}