class AppConstants {
  static const String appName = 'Simple Bible';
  static const String defaultBibleVersion = 'kjv';
  static const String defaultBook = 'Genesis';
  static const int defaultChapter = 1;
  static const double defaultFontSize = 2.0;
  static const String defaultFont = 'Raleway';
  static const int defaultColorIndex = 8;
  static const int defaultTextColorIndex = 1;
  
  // Database box names
  static const String settingsBox = 'settingsDB';
  static const String highlightBox = 'hiLightDB';
  static const String historyBox = 'searchHistoryDB';
  static const String notesBox = 'notesBoxDB';
  static const String textsBox = 'textsBoxDB';
  
  // Navigation indices
  static const int booksPageIndex = 0;
  static const int chaptersPageIndex = 1;
  static const int biblePageIndex = 2;
  static const int searchPageIndex = 3;
  static const int notesPageIndex = 4;
  static const int settingsPageIndex = 5;
  
  // Font options
  static const List<String> fontOptions = [
    'Inconsolata',
    'Indie Flower',
    'Lato',
    'Lobster',
    'Merriweather',
    'Open Sans',
    'Oswald',
    'Quattrocento',
    'Raleway',
    'Roboto',
    'Slabo 27px',
  ];
  
  // Bible rights text
  static const String bibleRights = 
    'Rights in the Authorized (King James) Version in the United Kingdom are vested in the Crown. '
    'Published by permission of the Crown\'s patentee, Cambridge University Press';
}