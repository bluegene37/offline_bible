import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../core/controllers/app_controller.dart';
import '../models/book_model.dart';
import '../services/bible_service.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  final ItemScrollController _oldTestamentScrollController =
      ItemScrollController();
  final ItemScrollController _newTestamentScrollController =
      ItemScrollController();
  final AppController appController = Get.find<AppController>();

  List<BookTitle> _oldTestamentBooks = [];
  List<BookTitle> _newTestamentBooks = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  void _loadBooks() async {
    final allBooks = await BibleService().getBookTitles('all');
    setState(() {
      _oldTestamentBooks = allBooks.where((b) => b.testament == 'old').toList();
      _newTestamentBooks = allBooks.where((b) => b.testament == 'new').toList();
    });
    _scrollToSelectedBook();
  }

  void _scrollToSelectedBook() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedBookKey = appController.bookSelected.value;

      int oldTestamentIndex =
          _oldTestamentBooks.indexWhere((b) => b.key == selectedBookKey);
      if (oldTestamentIndex != -1 && _oldTestamentScrollController.isAttached) {
        _oldTestamentScrollController.jumpTo(
          index: oldTestamentIndex,
          alignment: 0.5,
        );
      }

      int newTestamentIndex =
          _newTestamentBooks.indexWhere((b) => b.key == selectedBookKey);
      if (newTestamentIndex != -1 && _newTestamentScrollController.isAttached) {
        _newTestamentScrollController.jumpTo(
          index: newTestamentIndex,
          alignment: 0.5,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _oldTestamentBooks.isEmpty && _newTestamentBooks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _buildBooksGrid(),
    );
  }

  Widget _buildBooksGrid() {
    return Column(
      children: [
        const SizedBox(height: 8),
        _buildTestamentHeaders(),
        Expanded(
          child: Row(
            children: [
              Expanded(
                  child: _buildTestamentList(
                      _oldTestamentBooks, _oldTestamentScrollController)),
              Expanded(
                  child: _buildTestamentList(
                      _newTestamentBooks, _newTestamentScrollController)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestamentHeaders() {
    return Obx(() => Card(
          margin: EdgeInsets.zero,
          child: SizedBox(
            height: 35,
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  color: appController.themeMode.value
                      ? Colors.grey.shade800
                      : appController.activeThemeShade,
                  child: Text(
                    'Old Testament',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.raleway(
                      fontSize: 17.0,
                      color: appController.themeMode.value ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: appController.themeMode.value
                      ? Colors.grey.shade800
                      : appController.activeThemeShade,
                  child: Text(
                    'New Testament',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.raleway(
                      fontSize: 17.0,
                      color: appController.themeMode.value ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildTestamentList(
      List<BookTitle> books, ItemScrollController scrollController) {
    return ScrollablePositionedList.builder(
      itemScrollController: scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Obx(() {
          final isSelected = appController.bookSelected.value == book.key;
          return InkWell(
            onTap: () => _selectBook(book.key),
            child: Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: isSelected
                    ? (appController.themeMode.value
                        ? Colors.grey.shade700
                        : appController.activeThemeShade)
                    : null,
                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
              ),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    book.key,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w300,
                      color: isSelected
                          ? (appController.themeMode.value ? Colors.white : Colors.black)
                          : null,
                    ),
                  ),
                  Text(
                    book.val,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      color: isSelected
                          ? (appController.themeMode.value ? Colors.white : Colors.black)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _selectBook(String bookKey) {
    appController.updateBookSelection(bookKey, 1);
    appController.navigateToPage(1); // Navigate to chapters page
  }

}
