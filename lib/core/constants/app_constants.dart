class AppConstants {
  static const String appName = 'Offline Bible';
  static const String defaultBibleVersion = 'kjv';
  static const String defaultBook = 'Genesis';
  static const int defaultChapter = 1;
  static const double defaultFontSize = 17.0;
  static const double minFontSize = 13.0;
  static const double maxFontSize = 30.0;
  static const double defaultLineHeight = 1.5;
  static const double minLineHeight = 1.2;
  static const double maxLineHeight = 2.0;
  static const String defaultFont = 'Raleway';
  static const String defaultColorTheme = 'Black';

  // Database box names
  static const String settingsBox = 'settingsDB';
  static const String highlightBox = 'hiLightDB';
  static const String historyBox = 'searchHistoryDB';
  static const String notesBox = 'notesBoxDB';
  static const String textsBox = 'textsBoxDB';
  static const String bookmarksBox = 'bookmarksBoxDB';
  static const String readingPlansBox = 'readingPlansDB';
  static const String votdBox = 'votdDB';

  // Navigation indices
  static const int booksPageIndex = 0;
  static const int chaptersPageIndex = 1;
  static const int biblePageIndex = 2;
  static const int plansPageIndex = 3;
  static const int searchPageIndex = 4;
  static const int notesPageIndex = 5;
  static const int settingsPageIndex = 6;

  // Curated reading fonts. Every font here is bundled in google_fonts/ so
  // the app never needs the network to render text — do not add fonts
  // without also adding their .ttf files.
  static const List<String> fontOptions = [
    'Lato',
    'Raleway',
    'Oswald',
    'Merriweather',
    'Quattrocento',
    'Slabo 27px',
    'Inconsolata',
    'Indie Flower',
    'Lobster',
  ];
}
