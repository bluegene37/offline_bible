import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../home/widgets/continue_reading_card.dart';
import '../models/book_model.dart';
import '../services/bible_service.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  final AppController appController = Get.find<AppController>();

  List<BookTitle> _oldTestamentBooks = [];
  List<BookTitle> _newTestamentBooks = [];

  String _searchQuery = '';

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
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _oldTestamentBooks.isEmpty && _newTestamentBooks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const ContinueReadingCard(),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search books...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Old Testament',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'New Testament',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildBookColumn(_oldTestamentBooks, true),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(
                        child: _buildBookColumn(_newTestamentBooks, false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBookColumn(List<BookTitle> books, bool isOT) {
    List<BookTitle> displayBooks = books;

    if (_searchQuery.isNotEmpty) {
      displayBooks = displayBooks
          .where((b) => b.key.toLowerCase().contains(_searchQuery))
          .toList();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      itemCount: displayBooks.length,
      itemBuilder: (context, index) {
        final book = displayBooks[index];
        
        return Obx(() {
          final isSelected = appController.bookSelected.value == book.key;
          
          return InkWell(
            onTap: () => _selectBook(book.key),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              margin: const EdgeInsets.only(bottom: 2.0),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).primaryColor.withOpacity(0.1) 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.key,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Theme.of(context).primaryColor : null,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          book.val
                              .replaceAll(' Chapters', 'C')
                              .replaceAll(' Chapter', 'C')
                              .replaceAll(' Verses', 'V')
                              .replaceAll(' Verse', 'V'),
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected 
                                ? Theme.of(context).primaryColor.withOpacity(0.7)
                                : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check, size: 16, color: Theme.of(context).primaryColor),
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
    appController.navigateToPage(AppConstants.chaptersPageIndex);
  }
}
