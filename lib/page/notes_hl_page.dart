import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:outline_search_bar/outline_search_bar.dart';
import '../main.dart';
import '../methods/methods.dart';
import 'bible_page.dart';

var hiLightText = hiLightBox.values.toList();
var hiLightKeys = hiLightBox.keys.toList();
var jsonTexts = textsBox.values.toList();
var jsonKeys = textsBox.keys.toList();
var notesText = [].obs;
var queryText = ''.obs;
var hiLightVerses = textsBox.values.toList();
var notesHiLights = 1.obs;
var notesController = TextEditingController();

class NotesHLScreen extends StatelessWidget {
  const NotesHLScreen( {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Future.delayed(Duration.zero, () => {
      barTitle.value = 'Notes | Highlights',
      if(searchTexts.text.isNotEmpty){
        notesHiLights.value = 2
      }
    });

    return Column(
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: themeColorShades[colorSliderIdx.value],
          ),
          // ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Obx(() => Row(
                // alignment: WrapAlignment.spaceAround,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly ,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: textColorDynamic.value,
                      backgroundColor: notesHiLights.value == 2 ? themeColors[colorSliderIdx.value] : themeColorShades[colorSliderIdx.value],
                      textStyle: const TextStyle(fontSize: 20,),
                    ),
                    onPressed: () {
                      notesHiLights.value = 2;
                    },
                    child: const Text('Notes'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: textColorDynamic.value,
                      backgroundColor: notesHiLights.value == 1 ? themeColors[colorSliderIdx.value] : themeColorShades[colorSliderIdx.value],
                      textStyle: const TextStyle(fontSize: 20,),
                    ),
                    onPressed: () {
                      notesHiLights.value = 1;
                    },
                    child: const Text('Highlights'),
                  ),
                ],
                ),
              ),
            ],
          ),
        ),
        Obx(() => Expanded(
            child: notesHiLights.value == 0 ? const RefreshPage() : (notesHiLights.value == 1 ? const HiLightPage() : const NotesPage())
        )
        )
      ],
    );
  }
}

class HiLightPage extends StatelessWidget {
  const HiLightPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
    // key: const PageStorageKey<String>('page'),
    body: FutureBuilder(
        future: null,
        builder: (context, snapshot) {
          hiLightText = hiLightBox.values.toList();
          hiLightKeys = hiLightBox.keys.toList();
          jsonTexts = textsBox.values.toList();
          jsonKeys = textsBox.keys.toList();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: hiLightKeys.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text.rich(
                            TextSpan(
                                children: <TextSpan>[
                                  TextSpan(text:  " ${jsonKeys[index]} - ${jsonTexts[index]['version']} ", style: const TextStyle(color: Colors.black54, fontSize: 13, fontStyle: FontStyle.italic)),
                                  const TextSpan(text: '\n'),
                                  TextSpan(text: jsonTexts[index]['text'], style: TextStyle(color: brightness == Brightness.dark ?  Colors.black54 : Colors.black)),
                                  const TextSpan(text: '\n' ),
                                  TextSpan(text: jsonTexts[index]['datetime'], style: const TextStyle(color: Colors.black54, fontSize: 13, fontStyle: FontStyle.italic)),
                                ]
                            )
                        ),
                        tileColor: highLightColors[jsonTexts[index]['color']],
                        onTap: (){

                        },
                        trailing: PopupMenuButton(
                          itemBuilder: (context){
                            return [
                              const PopupMenuItem(
                                  value: 'gotoVerse',
                                  child: Text('Go to verse')
                              ),
                              const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit')
                              ),
                              const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete')
                              )
                            ];
                          },
                          onSelected: (String value){
                            if(value == 'gotoVerse'){
                              final bookTitle = jsonKeys[index].split(':')[0];
                              final bookChapter = int.parse(jsonKeys[index].split(':')[1]);
                              final bookVerse = int.parse(jsonKeys[index].split(':')[2]);

                              bookSelected = bookTitle;
                              box.put('bookSelected', bookTitle);
                              selectedChapter = bookChapter;
                              if(bookSelected != bookSelectedHist){
                                refreshChapter = true;
                              }
                              globalIndex.value = 2;
                              pages[0] = BooksLocalPage(bibleVersions, bookTitle ,bookChapter, bookVerse - 1);
                              barTitle.value = bookTitle +' '+bookChapter.toString();
                            }else if(value == 'delete'){
                              showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => CupertinoAlertDialog(
                                  title: const Text('Delete?'),
                                  content: const Text('This will delete the Highlight'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, 'Cancel'),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => {
                                        notesHiLights.value = 0,
                                        hiLightBox.delete(hiLightKeys[index]),
                                        textsBox.delete(jsonKeys[index]),
                                        Navigator.pop(context, 'OK'),
                                        Future.delayed(const Duration(milliseconds: 100), () {
                                          notesHiLights.value = 1;
                                        })
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }
                        )
                      ),
                    );
                  },
                ),
              )
            ],
          );
        }
    ),
  );
}

class NotesPage extends StatelessWidget {
  const NotesPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) => Scaffold(
    // key: const PageStorageKey<String>('page'),
    body: FutureBuilder(
        future: filterNotes(searchTexts.text),
        builder: (context, snapshot) {
          Future.delayed(Duration.zero, () async => {
            notesText.value = await filterNotes(searchTexts.text)
          });

          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            default:
              if(snapshot.hasError) {
                return const Center(child: Text('Some error occurred!'));
              } else {
                return buildNotes(notesText,context);
              }
          }
        }
      ),
  );
}

Widget buildNotes(pNotesJson,context){
  final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
  return Column(
    children: [
  //   FloatingSearchBar(
  //   hint: 'Search...',
  //   scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
  //   transitionDuration: const Duration(milliseconds: 800),
  //   transitionCurve: Curves.easeInOut,
  //   physics: const BouncingScrollPhysics(),
  //   axisAlignment: isPortrait ? 0.0 : -1.0,
  //   openAxisAlignment: 0.0,
  //   width: isPortrait ? 600 : 500,
  //   debounceDelay: const Duration(milliseconds: 500),
  //   onQueryChanged: (query) {
  //     // Call your model, bloc, controller here.
  //   },
  //   // Specify a custom transition to be used for
  //   // animating between opened and closed stated.
  //   transition: CircularFloatingSearchBarTransition(),
  //   actions: [
  //     FloatingSearchBarAction(
  //       showIfOpened: false,
  //       child: CircularButton(
  //         icon: const Icon(Icons.place),
  //         onPressed: () {},
  //       ),
  //     ),
  //     FloatingSearchBarAction.searchToClear(
  //       showIfClosed: false,
  //     ),
  //   ],
  //   builder: (context, transition) {
  //     return ClipRRect(
  //       borderRadius: BorderRadius.circular(8),
  //       child: Material(
  //         color: Colors.white,
  //         elevation: 4.0,
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: Colors.accents.map((color) {
  //             return Container(height: 112, color: color);
  //           }).toList(),
  //         ),
  //       ),
  //     );
  //   },
  // ),

      // OutlineSearchBar(
      //   focusNode: FocusNode() ,
      //   clearButtonColor: colorSliderIdx.value == 0 ? globalTextColors[textColorIdx.value] : themeColors[colorSliderIdx.value],
      //   cursorColor: colorSliderIdx.value == 0 || colorSliderIdx.value == 1 ? globalTextColors[textColorIdx.value] : themeColors[colorSliderIdx.value],
      //   searchButtonIconColor: colorSliderIdx.value == 0 || colorSliderIdx.value == 1 ? globalTextColors[textColorIdx.value] : themeColors[colorSliderIdx.value],
      //   borderColor: colorSliderIdx.value == 0 || colorSliderIdx.value == 1 ? globalTextColors[textColorIdx.value] : themeColors[colorSliderIdx.value],
      //   margin: const EdgeInsets.all(8.0),
      //   textEditingController: searchTexts,
      //   initText: searchTexts.text,
      //   hintText: 'Search here...',
      //   onSearchButtonPressed: (query) async => {
      //     notesText.value = await filterNotes(query),
      //   },
      //   onClearButtonPressed: (query) async => {
      //     searchTexts.text = '',
      //     notesText.value = await filterNotes(''),
      //     SystemChannels.textInput.invokeMethod('TextInput.hide'),
      //     FocusScope.of(context).unfocus(),
      //   },
      //   onKeywordChanged: (query) => {
      //
      //   },
      // ),
      Obx(() => Expanded(
        child: ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: pNotesJson.length,
          itemBuilder: (context, index) {
            var vNotesJson = pNotesJson[index];

              var finalText = vNotesJson['book'].replaceAll('[','').replaceAll(']','').split(",");
              var finalVerse = '';
              var removeTexts = [];
              finalText.asMap().forEach((index, verse) => {
                removeTexts = verse.split(':'),
                finalVerse = index == 0 ? finalText[0] : '$finalVerse, ${removeTexts.last}' ,
              });

            return Card(
              child: ListTile(
                title: Text.rich(
                    TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: '$finalVerse - $bibleVersions', style: TextStyle(color: globalTextColors[textColorIdx.value], fontSize: 13, fontStyle: FontStyle.italic)),
                          const TextSpan(text: '\n\n'),
                          TextSpan(text: "  ${vNotesJson['notes']}", style: TextStyle(color: globalTextColors[textColorIdx.value])),
                          const TextSpan(text: '\n\n'),
                          TextSpan(text: vNotesJson['stamp'], style: TextStyle(color: globalTextColors[textColorIdx.value], fontSize: 13, fontStyle: FontStyle.italic)),
                        ]
                    )
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context){
                    return [
                      // const PopupMenuItem(
                      //     value: 'gotoVerse',
                      //     child: Text('Go to verse')
                      // ),
                      const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit')
                      ),
                      const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete')
                      )
                    ];
                  },
                  onSelected: (String value){
                    if(value == 'gotoVerse'){
                      // final bookTitle = notesKeys[index].split(':')[0];
                      // final bookChapter = int.parse(notesKeys[index].split(':')[1]);
                      // final bookVerse = int.parse(notesKeys[index].split(':')[2]);

                      // bookSelected = bookTitle;
                      // box.put('bookSelected', bookTitle);
                      // selectedChapter = bookChapter;
                      // if(bookSelected != bookSelectedHist){
                      //   refreshChapter = true;
                      // }
                      // globalIndex.value = 2;
                      // pages[0] = BooksLocalPage(bibleVersions, bookTitle ,bookChapter, bookVerse - 1);
                      // barTitle.value = bookTitle +' '+bookChapter.toString();
                    }else if(value == 'delete'){
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => CupertinoAlertDialog(
                          title: const Text('Delete?'),
                          content: const Text('This will delete note'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => {
                                notesHiLights.value = 0,
                                notesBox.delete(vNotesJson[index]),
                                Navigator.pop(context, 'OK'),
                                Future.delayed(const Duration(milliseconds: 100), () {
                                  notesHiLights.value = 2;
                                })
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }else if(value == 'edit'){
                      notesController.text = vNotesJson['notes'] ;
                      var resBody = {};
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all( Radius.circular(5.0))),
                          content: Builder(
                            builder: (context) {
                              // var height = MediaQuery.of(context).size.height;
                              // var width = MediaQuery.of(context).size.width;
                              return TextFormField(
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
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: const BorderSide(),
                                  ),
                                ),
                              );
                            },
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => {
                                notesHiLights.value = 0,
                                resBody["book"] = vNotesJson['book'].toString(),
                                resBody["stamp"] =  DateFormat.yMMMMEEEEd().add_jms().format(DateTime.now()),
                                resBody["notes"] = notesController.text,
                                notesBox.put(vNotesJson[index],resBody),
                                Navigator.pop(context, 'Save'),
                                Future.delayed(const Duration(milliseconds: 100), () {
                                  notesHiLights.value = 2;
                                })
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                        barrierDismissible: false,
                      );
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
      ),
    ],
  );
}

class RefreshPage extends StatelessWidget{
  const RefreshPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }}

