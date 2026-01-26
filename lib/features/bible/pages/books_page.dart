import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/bible_controller.dart';
import '../models/book_model.dart';
import '../services/bible_service.dart';

class BooksPage extends StatelessWidget {
  const BooksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    final bibleController = Get.find<BibleController>();

    return Scaffold(
      body: FutureBuilder<List<BookTitle>>(
        future: BibleService().getBookTitles('all'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading books'));
          }

          final books = snapshot.data ?? [];
          final oldTestament =
              books.where((book) => book.testament == 'old').toList();
          final newTestament =
              books.where((book) => book.testament == 'new').toList();

          return _buildBooksGrid(oldTestament, newTestament, appController);
        },
      ),
    );
  }

  Widget _buildBooksGrid(List<BookTitle> oldTestament,
      List<BookTitle> newTestament, AppController controller) {
    return Column(
      children: [
        _buildTestamentHeaders(),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildTestamentList(oldTestament, controller)),
              Expanded(child: _buildTestamentList(newTestament, controller)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestamentHeaders() {
    return GetBuilder<AppController>(
      builder: (controller) {
        return Card(
          margin: EdgeInsets.zero,
          child: SizedBox(
            height: 35,
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  color: AppColors
                      .themeColorShades[controller.colorThemeName.value],
                  child: Text(
                    'Old Testament',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.raleway(fontSize: 17.0),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: AppColors
                      .themeColorShades[controller.colorThemeName.value],
                  child: Text(
                    'New Testament',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.raleway(fontSize: 17.0),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTestamentList(List<BookTitle> books, AppController controller) {
    return GetBuilder<AppController>(
      builder: (ctrl) {
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            final isSelected = ctrl.bookSelected.value == book.key;

            return InkWell(
              onTap: () => _selectBook(book.key, ctrl),
              child: Container(
                margin: const EdgeInsets.all(4.0),
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: isSelected
                      ? AppColors.themeColorShades[ctrl.colorThemeName.value]
                      : null,
                  borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                ),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      book.key,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      book.val,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _selectBook(String bookKey, AppController controller) {
    controller.updateBookSelection(bookKey, 1);
    Get.find<BibleController>()
        .loadChapters(bookKey); // Load chapters for the selected book
    controller.navigateToPage(1); // Navigate to chapters page
  }
}
