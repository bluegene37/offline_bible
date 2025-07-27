import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:simple_bible/api/books_api.dart';
import 'package:simple_bible/model/books.dart';
import 'package:simple_bible/main.dart';

import '../methods/methods.dart';
import 'notes_hl_page.dart';

final ItemScrollController itemScrollController = ItemScrollController();
final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
var notesController = TextEditingController();

var shadeIdx = 8;
var colorFade = const Color(0xfffbc02d).obs;
var highlightSelected = [];
var highlightClear = [];
var bottomPadding = 0.0.obs;
var copyTextClipboard = '';
var copyTextByVerse = [];
var scrollChecker = 0;
var sheetHeight = 0.0.obs;
var btnHeight = 30.0;
var hilighterHeight = 70.0;
var btnClose = 0.0;
var bibleRights = [
    'Rights in the Authorized (King James) Version in the United Kingdom are vested in the Crown. Published by permission of the Crown’s patentee, Cambridge University Press'
];

var notesValues = [].obs;
var vID = '';

var highLightColors = [
  Colors.red.shade100,
  Colors.pink.shade100,
  Colors.purple.shade100,
  Colors.indigo.shade100,
  Colors.blue.shade100,
  Colors.lightBlue.shade100,
  Colors.cyan.shade100,
  Colors.teal.shade100,
  Colors.green.shade100,
  Colors.lightGreen.shade100,
  Colors.lime.shade100,
  Colors.yellow.shade100,
  Colors.amber.shade100,
  Colors.orange.shade100,
  Colors.deepOrange.shade100,
  Colors.brown.shade100,
  Colors.blueGrey.shade100,
];

class BooksLocalPage extends StatelessWidget {
  final String jsonName;
  final String bookTitle;
  final int bookChapter;
  final int jumpTo;

  const BooksLocalPage(this.jsonName,this.bookTitle, this.bookChapter, this.jumpTo, {Key? key} ) : super(key: key);

  void jumpToFunc() =>  itemScrollController.jumpTo(index: jumpTo > 0 ? jumpTo : 0);

  @override
  Widget build(BuildContext context) => Scaffold(
    body: FutureBuilder<List<Book>>(
      future: bibleScreen.isEmpty || bookSelectedHist != bookSelected || selectedChapterHist != selectedChapter || refreshChapter ? BooksApi.getBooksLocally(context, jsonName, bookTitle, bookChapter) : null,
      builder: (context, snapshot) {
        final book = bibleScreen.isEmpty || bookSelectedHist != bookSelected || selectedChapterHist != selectedChapter || refreshChapter ? snapshot.data : bibleScreen;
        if(selectedChapterHist != selectedChapter){selectedChapterHist = selectedChapter;}
        if(bookSelectedHist != bookSelected){bookSelectedHist = bookSelected;}
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        Future.delayed(Duration.zero, () => {
              Navigator.of(context).maybePop(),
              barTitle.value = '$bookTitle $bookChapter',
              textUnderline.value = [],
              itemPositionsListener.itemPositions.addListener(() {
                if(itemPositionsListener.itemPositions.value.first.index > scrollChecker){
                  // print('Up')
                  hideFloatingBtn.value = true;
                }
                if(itemPositionsListener.itemPositions.value.first.index < scrollChecker){
                  // print('Down')
                  hideFloatingBtn.value = false;
                }
                scrollChecker = itemPositionsListener.itemPositions.value.first.index;
              }),
              jumpToFunc(),
          }
        );

        shouldShowRight = true;
        shouldShowLeft = true;
        if(selectedChapter == lastChapter){
          shouldShowRight = false;
        }else if(selectedChapter == 1){
          shouldShowLeft = false;
        }else{

        }

        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          default:
            if(snapshot.hasError) {
              return const Center(child: Text('Some error occurred!'));
            } else {
              return Obx(() =>buildBooks(book!) );
            }
        }
      },
    ),
  );

  Widget buildBooks(books) => ScrollablePositionedList.builder(
    physics: const BouncingScrollPhysics(),
    padding: EdgeInsets.only(top: 10.0, bottom: bottomPadding.value ),
    itemCount: books.length,
    itemBuilder: (context, index) {
      final book = books[index];
      var globalKey = book.book+':'+book.chapter.toString()+':'+book.verse.toString();
      Future.delayed(Duration.zero, () async => {
        // jumpToFunc(),
      });

        return Obx(() => ListTile(
          tileColor: colorIndex == index ? themeColorShades[colorSliderIdx.value] : null,
          trailing: Obx(() => Visibility(
            visible: notesJson().contains(globalKey),
            child: IconButton(
              onPressed: (){
                globalIndex.value = 4;
                barTitle.value = "Notes | Highlights";
                searchTexts.text = globalKey;
                pages[0] = const NotesHLScreen();
                // notesController.text = notesBox.get(globalKey)['notes'] ;
                // var resBody = {};
                // showDialog(
                //   context: context,
                //   builder: (_) => AlertDialog(
                //     shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all( Radius.circular(5.0))),
                //     content: Builder(
                //       builder: (context) {
                //         return TextFormField(
                //           controller: notesController,
                //           textAlignVertical: TextAlignVertical.top,
                //           keyboardType: TextInputType.multiline,
                //           maxLines: null,
                //           expands: true,
                //           decoration: InputDecoration(
                //             labelText: "Enter Notes",
                //             fillColor: Colors.white,
                //             labelStyle: TextStyle(
                //               color: themeColorShades[colorSliderIdx.value],
                //             ),
                //             border: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(5.0),
                //               borderSide: const BorderSide(),
                //             ),
                //           ),
                //         );
                //       },
                //     ),
                //     actions: <Widget>[
                //       TextButton(
                //         onPressed: () => {
                //           notesController.text,
                //           Navigator.pop(context, 'Cancel'),
                //       },
                //         child: const Text('Cancel'),
                //       ),
                //       TextButton(
                //         onPressed: () => {
                //           resBody["book"] = notesBox.get(globalKey)['book'].toString(),
                //           resBody["stamp"] =  DateFormat.yMMMMEEEEd().add_jms().format(DateTime.now()),
                //           resBody["notes"] = notesController.text,
                //           notesBox.put(globalKey,resBody),
                //           Navigator.pop(context, 'Save'),
                //           notesController.text = '',
                //         },
                //         child: const Text('Save'),
                //       ),
                //     ],
                //   ),
                //   barrierDismissible: false,
                // );
              },
              icon: FaIcon(FontAwesomeIcons.noteSticky, color: themeColors[colorSliderIdx.value],)
            )
            )
          ),
          title: Text.rich(
            TextSpan(
              // text: 'Test',
              // style: DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                TextSpan(text: '${book.verse}. ',
                  style: GoogleFonts.getFont(globalFont.value, fontSize: 11+fontSize.value,
                      color: globalTextColors[textColorIdx.value] ,
                      fontWeight: FontWeight.w300, fontStyle: FontStyle.italic ),
                ),
                TextSpan(
                  text: book.text ,
                  recognizer: TapGestureRecognizer()..onTap = () {
                    if(textUnderline.contains(globalKey)){
                      textUnderline.remove(globalKey);
                      highlightSelected.remove(hiLightBox.get(globalKey));
                      highlightClear.remove(globalKey+hiLightBox.get(globalKey).toString());
                      copyTextByVerse.remove(book.verse);
                    }else{
                      textUnderline.add(globalKey);
                      highlightSelected.add(hiLightBox.get(globalKey));
                      highlightClear.add(globalKey+hiLightBox.get(globalKey).toString());
                      copyTextByVerse.add(book.verse);
                    }

                    if(textUnderline.isNotEmpty){
                      bottomPadding.value = 120.0;
                      final PersistentBottomSheetController bottomSheetController = Scaffold.of(context).showBottomSheet(
                            (BuildContext context) {
                          return  Padding(
                            padding: const EdgeInsets.only(
                              // bottom: MediaQuery.of(context).viewInsets.bottom
                                left: 10.0, right: 10.0
                            ),
                            child: Obx(()=> SizedBox(
                                height: 120 + sheetHeight.value,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                        SizedBox(
                                          height: sheetHeight.value,
                                          child: TextFormField(
                                            controller: notesController,
                                            textAlignVertical: TextAlignVertical.top,
                                            keyboardType: TextInputType.multiline,
                                            maxLines: null,
                                            expands: true,
                                            decoration: InputDecoration(
                                              labelText: "Enter Notes",
                                              fillColor: Colors.white,
                                              labelStyle: TextStyle(
                                                  color: themeColorShades[colorSliderIdx.value],
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(25.0),
                                                borderSide: const BorderSide(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      SizedBox(
                                        height: btnClose,
                                        child: const Text(''),
                                      ),
                                      Row(
                                        children: [
                                          const Spacer(),
                                          SizedBox(
                                            height: btnClose,
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: themeColors[colorSliderIdx.value],
                                                ),
                                                child: Text('Save' , style: TextStyle( color: textColorDynamic.value),),
                                                onPressed: () async {
                                                  var datetime = DateFormat.yMMMMEEEEd().add_jms().format(DateTime.now());
                                                  var resBody = {};
                                                  vID = getUniqueID().toString();
                                                  resBody["book"] = textUnderline.value.toString();
                                                  resBody["stamp"] = datetime;
                                                  resBody["notes"] = notesController.text;
                                                  notesBox.put(vID,resBody);
                                                  // for(var i = 0; i < textUnderline.length; i++){
                                                  //   notesBox.put(textUnderline[i],resBody);
                                                  // }
                                                  if(sheetHeight.value == 300.0){
                                                    sheetHeight.value = 0.0;
                                                    btnHeight = 30.0;
                                                    hilighterHeight = 70.0;
                                                    btnClose = 0.0;
                                                    notesController.clear();
                                                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                                                    FocusScope.of(context).unfocus();
                                                  }else{
                                                    sheetHeight.value = 300.0;
                                                    btnHeight = 0.0;
                                                    hilighterHeight = 0.0;
                                                    btnClose = 30.0;
                                                  }

                                                },
                                            ),
                                          ),
                                          const Spacer(),
                                          SizedBox(
                                            height: btnClose,
                                            child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: themeColors[colorSliderIdx.value],
                                                ),
                                                child: Text('Close' , style: TextStyle( color: textColorDynamic.value),),
                                                onPressed: () {
                                                  if(sheetHeight.value == 300.0){
                                                    sheetHeight.value = 0.0;
                                                    btnHeight = 30.0;
                                                    hilighterHeight = 70.0;
                                                    btnClose = 0.0;
                                                    notesController.clear();
                                                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                                                    FocusScope.of(context).unfocus();
                                                  }else{
                                                    sheetHeight.value = 300.0;
                                                    btnHeight = 0.0;
                                                    hilighterHeight = 0.0;
                                                    btnClose = 30.0;
                                                  }
                                                }
                                            ),
                                          ),
                                          const Spacer(),
                                        ],
                                      ),

                                      const SizedBox(height: 5),
                                      SizedBox(
                                        height: btnHeight,
                                        child: copyBtn(),
                                      ),
                                      SizedBox(
                                        height: hilighterHeight,
                                        child: highLighter(),
                                      )
                                    ],
                                  ),
                                )
                              )
                            ),
                          );
                        },
                      );
                      bottomSheetController.closed.then((value) {
                        bottomPadding.value = 0.0;
                        textUnderline.value = [];
                        highlightSelected = [];
                        highlightClear = [];
                        copyTextClipboard = '';
                        sheetHeight.value = 0.0;
                        btnHeight = 30.0;
                        hilighterHeight = 70.0;
                        btnClose = 0.0;
                      });
                    }else{
                      sheetHeight.value = 0.0;
                      btnHeight = 30.0;
                      hilighterHeight = 70.0;
                      btnClose = 0.0;
                      bottomPadding.value = 0.0;
                      Navigator.pop(context);
                    }
                  },
                  style: GoogleFonts.getFont(globalFont.value, fontSize: 15+fontSize.value,
                    color: !hiLightBox.containsKey(globalKey) && brightness == Brightness.dark ?  globalTextColors[textColorIdx.value] : Colors.black ,
                    decoration: textUnderline.value.contains(globalKey) ? TextDecoration.underline : null,
                    decorationStyle: textUnderline.value.contains(globalKey) ? TextDecorationStyle.dashed : null,
                    backgroundColor: !hiLightBox.containsKey(globalKey)
                        ? null
                        : highLightColors[hiLightBox.get(globalKey,defaultValue: 0)],
                  ),
                ),
              ],
            ),
          ),
          subtitle: index+1 == books.length ?  Padding(
              padding: const EdgeInsets.all(20),
              child: Text( bibleRights[0] , style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 11), textAlign: TextAlign.center, ),
          ) : null ,
          onTap: (){

          },
          onLongPress: (){

          },
        ),
      );
  },
  itemScrollController: itemScrollController,
  itemPositionsListener: itemPositionsListener,
  );
}

Widget copyBtn(){
  return Row(
    children: [
      const Spacer(),
      ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: themeColors[colorSliderIdx.value],
          ),
          child: Text('Copy texts' , style: TextStyle( color: textColorDynamic.value),),
          onPressed: () {
            copyTextClipboard = '';
            for (var i in bibleScreen) {
              if(copyTextByVerse.contains(i.verse) ){
                copyTextClipboard = '$copyTextClipboard ${i.text}';

              }
            }

            Clipboard.setData(
              ClipboardData(text: copyTextClipboard ),
            );
          }),
      const Spacer(),
      ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: themeColors[colorSliderIdx.value],
          ),
          child: Text('Copy w/ verse no.' , style: TextStyle( color: textColorDynamic.value),),
          onPressed: () {
            copyTextClipboard = '';
            for (var i in bibleScreen) {
              if(copyTextByVerse.contains(i.verse) ){
                copyTextClipboard = '$copyTextClipboard ${i.verse}${'.'} ${i.text}';
              }
            }
            Clipboard.setData(
              ClipboardData(text: copyTextClipboard ),
            );
          }),
      const Spacer(),
      ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: themeColors[colorSliderIdx.value],
          ),
          child: Text('Notes' , style: TextStyle( color: textColorDynamic.value),),
          onPressed: () {
            notesController.text = '';
            if(sheetHeight.value == 300.0){
              sheetHeight.value = 0.0;
              btnHeight = 30.0;
              hilighterHeight = 70.0;
              btnClose = 0.0;
            }else{
              sheetHeight.value = 300.0;
              btnHeight = 0.0;
              hilighterHeight = 0.0;
              btnClose = 30.0;
            }
          }
        ),
      const Spacer(),
    ],
  );
}

Widget highLighter(){
  return ListView.separated(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          scrollDirection: Axis.horizontal,
          itemCount: highLightColors.length,
          separatorBuilder: (context, index){
            return const SizedBox(width: 5);
          },
          itemBuilder: (context, index) {

            return InkWell(
              child: CircleAvatar(
                radius: 45 / 2,
                backgroundColor: highLightColors[index],
                child: highlightSelected.contains(index) ? const Icon(Icons.close, color: Colors.black) : null,
              ),
              onTap: (){
                Navigator.pop(context);

                var hlTexts = bibleScreen.toList();
                var hlDateTime = DateFormat.yMMMMEEEEd().add_jms().format(DateTime.now());
                var hlBody = {};

                for (var uniqueKey in textUnderline) {
                  if(highlightClear.contains(uniqueKey+index.toString())){
                    hiLightBox.delete(uniqueKey);
                    textsBox.delete(uniqueKey);
                  }
                  if(!highlightSelected.contains(index)){
                    hiLightBox.put(uniqueKey, index);
                    hlBody["datetime"] = hlDateTime;
                    hlBody["text"] = hlTexts[int.parse(uniqueKey.split(':')[2])-1].text;
                    hlBody['version'] = bibleVersions;
                    hlBody['color'] = index;
                    textsBox.put(uniqueKey,hlBody);
                  }
                }

                textUnderline.value = [];
                highlightSelected = [];
                highlightClear = [];
                copyTextClipboard = '';
              },
            );
          }
      );
  }
