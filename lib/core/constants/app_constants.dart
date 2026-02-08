class AppConstants {
  static const String appName = 'Offline Bible';
  static const String defaultBibleVersion = 'kjv';
  static const String defaultBook = 'Genesis';
  static const int defaultChapter = 1;
  static const double defaultFontSize = 2.0;
  static const String defaultFont = 'Raleway';
  static const String defaultColorTheme = 'Blue';
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
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Raleway',
    'Oswald',
    'Merriweather',
    'Lora',
    'Nunito',
    'Playfair Display',
    'Rubik',
    'Ubuntu',
    'Kanit',
    'Lobster',
    'Pacifico',
    'Dancing Script',
    'Indie Flower',
    'Quattrocento',
    'Slabo 27px',
    'Inconsolata',
    'Source Code Pro',
    'PT Serif',
    'Josefin Sans',
    'Abril Fatface',
    'Anton',
    'Bebas Neue',
    'Bitter',
    'Cabin',
    'Comfortaa',
    'Exo 2',
    'Fjalla One',
    'Francois One',
    'Great Vibes',
    'Hind',
    'Inria Serif',
    'Karla',
    'Maven Pro',
    'Mukta',
    'Oxygen',
    'Pathway Gothic One',
    'Poiret One',
    'Questrial',
    'Righteous',
    'Sacramento',
    'Satisfy',
    'Shadows Into Light',
    'Teko',
    'Varela Round',
    'Yanone Kaffeesatz',
    'Zilla Slab',
  ];

  // Bible rights text
  static const String bibleRights =
      'Rights in the Authorized (King James) Version in the United Kingdom are vested in the Crown. '
      'Published by permission of the Crown\'s patentee, Cambridge University Press';
}
