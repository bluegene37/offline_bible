import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:simple_bible/main.dart';
import 'package:flutter/material.dart';
import 'package:simple_bible/api/books_api.dart';
import 'package:simple_bible/model/books.dart';
import 'chapter_page.dart';

var alreadyJump = false;

final ItemScrollController itemScrollController = ItemScrollController();
final ItemScrollController itemScrollController2 = ItemScrollController();

class BooksSelectionPage extends StatelessWidget {
  const BooksSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: FutureBuilder<List<BookTitle>>(
          future: BooksTitleApi.getBooksLocally(context, 'booktitle'),
          builder: (context, snapshot) {
            alreadyJump = false;
            // final book = snapshot.data[index].testament == 'old';
            final oldTestament =
            snapshot.data?.where((i) => i.testament == 'old').toList();
            final newTestament =
            snapshot.data?.where((i) => i.testament == 'new').toList();

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError) {
                  return const Center(child: Text('Some error occurred!'));
                } else {
                  return buildListViewRow(oldTestament!, newTestament!);
                }
            }
          },
        ),
      );
}

  Widget buildListViewRow(oldT,newT) => Scaffold(
    body: FutureBuilder(
        // future: null,
        builder: (context, snapshot) {
          return Column(
            children: <Widget>[
              Card(
                margin: EdgeInsets.zero,
                child: SizedBox(
                  height: 35,
                  child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: themeColorShades[colorSliderIdx.value],
                        child: Text('Old Testament',textAlign: TextAlign.center, style: GoogleFonts.raleway(fontSize: 17.0,)),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: themeColorShades[colorSliderIdx.value],
                        child: Text('New Testament' ,textAlign: TextAlign.center, style: GoogleFonts.raleway(fontSize: 17.0,)),
                      ),
                    ]
                  )
                ),
              ),
              Expanded( child: Row(
                    children: [
                      Expanded(
                          child: ScrollablePositionedList.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: oldT.length,
                            itemBuilder: (context, index) {
                              final bookTitle = oldT[index];
                              if(bookSelected == bookTitle.key){
                                Future.delayed(Duration.zero, () => {
                                  if(!alreadyJump){
                                    itemScrollController.jumpTo(index: index)
                                  },
                                  alreadyJump = true,
                                });
                              }
                              return InkWell(
                                child: Container(
                                  margin: const EdgeInsets.all(4.0),
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: bookSelected == bookTitle.key ? themeColorShades[colorSliderIdx.value] : null,
                                    borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                                  ),
                                  alignment: Alignment.center,
                                  child: Column(
                                    children: [
                                      Text( bookTitle.key, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w300,),),
                                      Text(bookTitle.val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic),)
                                    ],
                                  ),
                                ),
                                onTap: () => {
                                  bookSelected = bookTitle.key,
                                  box.put('bookSelected', bookTitle.key),
                                  box.put('selectedChapter',1),
                                  selectedChapter = 1,
                                  globalIndex.value = 1,
                                  pages[0] = const ChapterSelectionPage(),
                                  barTitle.value = "Chapters",
                                  colorIndex = 999,
                                },
                              );
                            },
                            itemScrollController: itemScrollController,
                          )
                      ),
                      Expanded(
                          child: ScrollablePositionedList.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: newT.length,
                            itemBuilder: (context, index) {
                              final bookTitle = newT[index];
                              if(bookSelected == bookTitle.key){
                                Future.delayed(Duration.zero, () => {
                                  if(!alreadyJump){
                                    itemScrollController2.jumpTo(index: index)
                                  },
                                  alreadyJump = true,
                                });
                              }
                              return InkWell(
                                child: Container(
                                  margin: const EdgeInsets.all(4.0),
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: bookSelected == bookTitle.key ? themeColorShades[colorSliderIdx.value] : null,
                                    borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                                  ),
                                  alignment: Alignment.center,
                                  child: Column(
                                    children: [
                                      Text(bookTitle.key, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w300,),),
                                      Text(bookTitle.val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic),)
                                    ],
                                  ),
                                ),
                                onTap: () => {
                                  bookSelected = bookTitle.key,
                                  box.put('bookSelected', bookTitle.key),
                                  selectedChapter = 1,
                                  globalIndex.value = 1,
                                  pages[0] = const ChapterSelectionPage(),
                                  barTitle.value = "Chapters",
                                  colorIndex = 999,
                                },
                              );
                            },
                            itemScrollController: itemScrollController2,
                          )
                      ),
                    ],
                 )
              ),
             ]
          );
        }, future: null,
    ),
  );