import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'core/controllers/app_controller.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'features/bible/controllers/bible_controller.dart';
import 'features/home/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage
  await StorageService.init();
  
  // Initialize controllers
  Get.put(AppController());
  Get.put(BibleController());

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    
    return AdaptiveTheme(
      light: GetBuilder<AppController>(
        builder: (controller) => ThemeData(
          useMaterial3: false,
          brightness: Brightness.light,
          primaryColor: AppColors.themeColors[controller.colorSliderIdx.value],
          fontFamily: controller.globalFont.value,
        ),
      ),
      dark: GetBuilder<AppController>(
        builder: (controller) => ThemeData(
          useMaterial3: false,
          brightness: Brightness.dark,
          primaryColor: AppColors.themeColors[controller.colorSliderIdx.value],
          fontFamily: controller.globalFont.value,
        ),
      ),
      initial: appController.themeMode.value 
          ? AdaptiveThemeMode.dark 
          : AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        home: const HomePage(),
      ),
    );
  }
}

          ),
        )
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  BannerAd? _bannerAd;

  @override
  void initState(){
    super.initState();
    // _createBannerAd();
    init();
  }

  // void _createBannerAd(){
  //   _bannerAd = BannerAd(
  //       size: AdSize.fullBanner,
  //       adUnitId: AdmobService.bannerAddUnitID!,
  //       listener: AdmobService.bannerAdListener,
  //       request: const AdRequest()
  //   )..load();
  // }

  Future init() async {
    barTitle.value = '$bookSelected $selectedChapter';
    Timer.periodic(const Duration(seconds: 2), (timer) {
      showAddsTime.value--;
      if (showAddsTime.value == 0) {
        timer.cancel();
      }
    });
  }

  void onTabTapped(index) {
    setState(() {
      globalIndex.value = index;
      loginpage.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      appBar:
      // AppBar(
      //     flexibleSpace: SizedBox(
      //       height: 100,
      //       child: AdWidget(ad: _bannerAd!),
      //     ),
      //     toolbarHeight: 100,
      //     centerTitle: true,
      //     backgroundColor: themeColors[colorSliderIdx.value],
      //     title: Text(barTitle.value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: textColorDynamic.value,),),
      //   ),
      PreferredSize(
        preferredSize: const Size.fromHeight(35.0),
        child: Obx(() => AppBar(
              centerTitle: true,
              backgroundColor: themeColors[colorSliderIdx.value],
              title: Text(barTitle.value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: textColorDynamic.value,),),
          )
        )
      ),
      key: _key,
      body: SafeArea(child: pages[0]),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: globalIndex.value == 2 && !hideFloatingBtn.value && textUnderline.isEmpty ? floatingNextPage() : null,
      bottomNavigationBar:
        // navigationBar(),
        SizedBox(
          // height: (_bannerAd != null && showAdds.value) ? Platform.isAndroid ? 120 : 160 : Platform.isAndroid ? 60 : 94,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // navigationBar(),
              // Obx(() => Visibility(
              //   visible: _bannerAd != null && showAdds.value,
              //     child:  SizedBox(
              //       height: 60,
              //       child: Row(
              //         children: [
              //           Flexible(
              //             child: _bannerAd != null ? AdWidget(ad: _bannerAd!) : const Text('No Ads'),
              //           ),
              //           ElevatedButton(
              //             onPressed: () {
              //               if(showAddsTime.value == 0){
              //                 showAdds.value = false;
              //               }
              //             },
              //             style: ElevatedButton.styleFrom(
              //               shape: const CircleBorder(),
              //               padding: const EdgeInsets.all(10),
              //               backgroundColor: themeColorShades[colorSliderIdx.value]
              //             ),
              //             child: showAddsTime.value == 0
              //                 ?
              //             Icon(Icons.close_rounded, color: textColorDynamic.value)
              //                 :
              //             Obx(() => Text('${showAddsTime.value}', style: TextStyle(color: textColorDynamic.value),)),
              //           )
              //         ]
              //       )
              //     ),
              //   ),
              // ),
              navigationBar(),
            ],
          )
        )
      )
    );
  }

  Widget navigationBar(){
    return NavigationBarTheme(
      data: NavigationBarThemeData(
          indicatorColor: themeColorShades[colorSliderIdx.value],
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          )
      ),
      child: NavigationBar(
        height: 60,
        selectedIndex: globalIndex.value,
        onDestinationSelected: (globalIndex) => {
          onTabTapped(globalIndex),
          if (globalIndex == 0) {
            barTitle.value = "Books (66)",
            if(pages.toString().contains('BooksSelectionPage')){
            }else {
              pages[0] = const BooksSelectionPage()
            },
          } else if (globalIndex == 1) {
            barTitle.value = "Chapters",
            if(pages.toString().contains('ChapterSelectionPage')){
            }else {
              pages[0] = const ChapterSelectionPage()
            }
          } else if (globalIndex == 2) {
            if(pages.toString().contains('BooksLocalPage')){
            }else{
              pages[0] = BooksLocalPage(bibleVersions, bookSelected, selectedChapter, 0),
            },
            barTitle.value = '$bookSelected $selectedChapter',
            colorIndex = 999
          } else if (globalIndex == 3) {
            barTitle.value = "Search",
            if(pages.toString().contains('SearchLocalPage')){
            }else {
              pages[0] = const SearchLocalPage()
            }
          } else if (globalIndex == 4) {

            barTitle.value = "Notes | Highlights",
            if(pages.toString().contains('NotesHLScreen')){
            }else {
              searchTexts.text = '',
              pages[0] = const NotesHLScreen()
            }
          } else if (globalIndex == 5) {
            barTitle.value = "Settings",
            statusBarChanged = false,
            if(pages.toString().contains('SettingsLocalPage')){
            }else {
              pages[0] = const SettingsLocalPage()
            }
          } else {
            pages[0] = BooksLocalPage(bibleVersions, bookSelected, selectedChapter,0),
          },
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              label: 'Books'
          ),
          NavigationDestination(
              icon: Icon(Icons.library_books_outlined),
              label: 'Chapters'
          ),
          NavigationDestination(
              icon: Icon(Icons.auto_stories_outlined),
              label: 'Bible'
          ),
          NavigationDestination(
              icon: Icon(Icons.search),
              label: 'Search'
          ),
          NavigationDestination(
              icon: Icon(Icons.edit_note_sharp),
              label: 'Notes'
          ),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              label: 'Settings'
          ),
        ],
      ),
    );
  }
}

Widget floatingNextPage(){
  return Stack(
    fit: StackFit.expand,
    children: [
      Positioned(
        left: 30,
        bottom: 20,
        width: 40,
        height: 40,
        child: FloatingActionButton(
          backgroundColor:  themeColors[colorSliderIdx.value],
          heroTag: 'back',
          onPressed: () {
            if( selectedChapter != 1){
              selectedChapter =  selectedChapter > 1 ? selectedChapter - 1 : 1;
              pages[0] = BooksLocalPage(bibleVersions, bookSelected, selectedChapter,0);
              colorIndex = 999;
            }
          },
          child: Icon(Icons.navigate_before_rounded, size: 40, color:  selectedChapter == 1 ? Colors.black12 : textColorDynamic.value,),
        ),
      ),
      Positioned(
        right: 30,
        bottom: 20,
        width: 40,
        height: 40,
        child: FloatingActionButton(
          backgroundColor: themeColors[colorSliderIdx.value],
          heroTag: 'next',
          onPressed: () {
            if(selectedChapter != lastChapter){
              selectedChapter =  selectedChapter < lastChapter ? selectedChapter + 1 : lastChapter;
              pages[0] = BooksLocalPage(bibleVersions, bookSelected, selectedChapter,0);
              colorIndex = 999;
            }
          },
          child: Icon(Icons.navigate_next_rounded, size: 40, color:  selectedChapter == lastChapter ? Colors.black12 : textColorDynamic.value,),
        ),
      ),
    ],
  );
}
