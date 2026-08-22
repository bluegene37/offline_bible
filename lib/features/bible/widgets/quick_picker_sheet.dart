import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../services/bible_service.dart';
import '../models/book_model.dart';
import '../controllers/bible_controller.dart';

class QuickPickerSheet extends StatefulWidget {
  const QuickPickerSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuickPickerSheet(),
    );
  }

  @override
  State<QuickPickerSheet> createState() => _QuickPickerSheetState();
}

class _QuickPickerSheetState extends State<QuickPickerSheet> {
  final AppController appController = Get.find<AppController>();
  late String currentBook;

  @override
  void initState() {
    super.initState();
    currentBook = appController.bookSelected.value;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Material(
      color: bgColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Select Chapter',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: _buildChaptersGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChaptersGrid() {
    final bibleController = Get.find<BibleController>();

    return FutureBuilder<List<Book>>(
      future: BibleService().getChapters(currentBook),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final chapters = snapshot.data!;
        
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: chapters.length,
          itemBuilder: (context, index) {
            final chapterNumber = index + 1;
            final isCurrentSelection = chapterNumber == appController.selectedChapter.value;

            return InkWell(
              onTap: () {
                appController.updateBookSelection(currentBook, chapterNumber);
                bibleController.loadChapter(currentBook, chapterNumber);
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: isCurrentSelection 
                      ? Theme.of(context).primaryColor 
                      : Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$chapterNumber',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isCurrentSelection 
                        ? Colors.white 
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            );
          },
        );
      }
    );
  }
}
