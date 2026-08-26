<div align="center">

<img src="branding/app_logo.png" alt="Offline Bible Logo" width="128" height="128" />

# Offline Bible

**A fast, elegant, and 100% offline Holy Bible app built with Flutter.**  
*Read, listen, search, and study Scripture anywhere — no internet required.*

[![CI Status](https://github.com/bluegene37/offline_bible/actions/workflows/ci.yml/badge.svg)](https://github.com/bluegene37/offline_bible/actions/workflows/ci.yml)
[![Release](https://github.com/bluegene37/offline_bible/actions/workflows/release.yml/badge.svg)](https://github.com/bluegene37/offline_bible/actions/workflows/release.yml)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.24%2B-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.5%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform Compatibility](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20macOS%20%7C%20Web-lightgrey.svg)](#-platform-support--download-matrix)

</div>

---

## 📖 Overview

**Offline Bible** is an open-source, zero-telemetry Bible application crafted for a distraction-free, privacy-first reading and devotional experience. The entire King James Version (all 66 books, 1,189 chapters, and 31,102 verses) is bundled directly within the app, allowing you to study anywhere — during commutes, in flight mode, or in remote regions.

---

## ✨ Features & Highlights

### ⚡ 100% Offline by Design
- **Complete KJV Canon**: All 66 books of the Old and New Testaments bundled directly in local JSON.
- **Zero Internet Required**: Read, search, take notes, and listen without cellular data or Wi-Fi.

### 🎧 Audio Bible (Text-to-Speech)
- **Verse-by-Verse Recitation**: High-quality natural text-to-speech with real-time synchronized highlighting.
- **Background & Lock-Screen Playback**: Seamless playback controls via Android foreground media service and iOS audio session.
- **Adjustable Speed**: Fine-tune reading speed from `0.5x` up to `2.0x`.

### 📝 Deep Study & Annotation Suite
- **Multi-Color Highlights**: Mark verses in vivid colors (Yellow, Green, Blue, Pink, Orange) stored persistently.
- **Verse Notes**: Create rich, formatted study notes linked to single verses or multi-verse passages.
- **Instant Bookmarks**: Pin passages to quickly return to your study point.
- **Red-Letter Edition**: Spoken words of Jesus Christ rendered in distinguished red text.
- **Cross-Reference Navigation**: Integrated scripture cross-reference index connecting related passages.

### 🔍 Lightning-Fast Search
- **Instant Keyword Search**: Search across 31,102 verses in milliseconds.
- **Scope Filters**: Narrow queries to the Old Testament, New Testament, or the entire Bible.
- **Search History**: Instant access to recent queries with one-tap clearing.

### 📅 Reading Plans & Verse of the Day
- **Structured Devotional Plans**: Built-in reading schedules for Proverbs, Psalms, Gospel of John, and Epistles.
- **Daily Progress Tracking**: Visual check-offs and completion metrics.
- **Verse of the Day**: Curated daily inspiration with one-tap copy and social share.

### 🎨 Typography & OLED Theming
- **10 Bundled Fonts**: Carefully selected reading typefaces (Atkinson Hyperlegible, EB Garamond, Lato, Literata, Lora, Merriweather, OpenDyslexic, Open Sans, Quattrocento, Raleway).
- **Themes**: Pure Black (OLED battery saver), Dark, Light, Warm Sepia, and Midnight.
- **Reading Controls**: Adjustable font scale, line spacing, and continuous scroll or chapter pagination.

### 🌐 Optional Translation Manager
- Download additional public-domain translations on-demand via the getbible API.

---

## 📦 Platform Support & Download Matrix

| Platform | Distribution Channel | Format | Status |
| :--- | :--- | :--- | :--- |
| **Android** | [Google Play Store](#) / [GitHub Releases](https://github.com/bluegene37/offline_bible/releases) | `.aab` / `.apk` | [![Android](https://img.shields.io/badge/Android-SDK%2026%2B-green.svg?logo=android)]() |
| **iOS** | [Apple App Store](#) / TestFlight | `.ipa` / `.xcarchive` | [![iOS](https://img.shields.io/badge/iOS-12.0%2B-black.svg?logo=apple)]() |
| **macOS** | [GitHub Releases](https://github.com/bluegene37/offline_bible/releases) | `.zip` | [![macOS](https://img.shields.io/badge/macOS-10.15%2B-lightgrey.svg?logo=apple)]() |
| **Web** | [Static PWA Hosting](#) | Web Bundle | [![Web](https://img.shields.io/badge/Web-PWA%20Ready-orange.svg?logo=googlechrome)]() |

---

## ⌨️ CLI & Developer Command Cheat Sheet

| Task | Command |
| :--- | :--- |
| **Install Dependencies** | `flutter pub get` |
| **Code Formatting** | `dart format .` (or check with `dart format --output=none --set-exit-if-changed .`) |
| **Static Analysis** | `flutter analyze --fatal-infos` |
| **Run Unit & Widget Tests** | `flutter test` |
| **Generate Icons & Splash** | `dart run flutter_launcher_icons && dart run flutter_native_splash:create` |
| **Build Android App Bundle** | `flutter build appbundle --release --obfuscate --split-debug-info=build/symbols/android` |
| **Build Android APK** | `flutter build apk --release --obfuscate --split-debug-info=build/symbols/android` |
| **Build iOS Archive** | `flutter build ipa --release --obfuscate --split-debug-info=build/symbols/ios` |
| **Build macOS App** | `flutter build macos --release --obfuscate --split-debug-info=build/symbols/macos` |
| **Build Web Bundle** | `flutter build web --release` |

---

## 🛠️ Local Development & Setup

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.24.0`)
- [Dart SDK](https://dart.dev/get-dart) (`>= 3.5.0`)
- OpenJDK 21 (for Android compilation)
- Xcode 15+ (for iOS/macOS compilation)

### Getting Started
```bash
# 1. Clone the repository
git clone https://github.com/bluegene37/offline_bible.git
cd offline_bible

# 2. Fetch packages
flutter pub get

# 3. Verify toolchain health
flutter doctor

# 4. Run test suite
flutter test

# 5. Launch the application
flutter run
```

---

## 📁 Repository Structure

```
offline_bible/
├── .github/
│   ├── workflows/             # CI (ci.yml) & Release (release.yml) Actions
│   └── ISSUE_TEMPLATE/        # GitHub issue & PR templates
├── android/                   # Android native wrapper & Gradle configuration
├── assets/                    # Bundled Scripture JSON, cross references, and OFL fonts
│   ├── fonts/                 # 10 bundled offline reading typefaces
│   ├── kjv.json               # Complete 66-book King James Version index
│   └── red_letter.json        # Words of Christ ranges
├── branding/                  # Vector SVG logo sources and icon generators
├── ios/                       # iOS native wrapper, Info.plist, and Xcode project
├── lib/
│   ├── core/                  # Global controllers, themes, TTS service, Hive storage
│   ├── features/
│   │   ├── bible/             # Bible reading pages, verse selection, audio toolbar
│   │   ├── home/              # Main dashboard and continue-reading tile
│   │   ├── navigation/        # Bottom navigation bar
│   │   ├── notes/             # Highlights, bookmarks, and note editor
│   │   ├── plans/             # Reading plans and progress trackers
│   │   ├── search/            # Full-text Scripture search engine
│   │   └── settings/          # Font scaling, themes, and version manager
│   └── main.dart              # Application entry point & Hive initialization
├── macos/                     # macOS desktop platform wrapper
├── store/                     # Store listings, metadata, and description copy
├── test/                      # Unit, widget, and service test suite
└── web/                       # Web platform shell & PWA manifest
```

---

## 🛡️ Privacy & Security

Offline Bible is **100% offline-first**:
- 🔒 **Zero Data Collection**: No telemetry, analytics, tracking, or crash logging SDKs.
- 📱 **Local-Only Storage**: All user notes, highlights, and reading stats are stored locally in Hive CE.
- 🌐 **Minimal Network Footprint**: Network access is only used if you explicitly trigger an additional translation download from `api.getbible.net`.

See [SECURITY.md](SECURITY.md) for vulnerability reporting and our privacy disclosure.

---

## 🤝 Contributing

Contributions are welcome! Please check out [CONTRIBUTING.md](CONTRIBUTING.md) for development setup, branching guidelines, commit conventions, and pull request procedures.

---

## 📜 License & Acknowledgements

- **Code & Application**: Released under the [MIT License](LICENSE).
- **Scripture Text**: Rights in the Authorized (King James) Version in the United Kingdom are vested in the Crown. Published by permission of the Crown's patentee, Cambridge University Press.
- **Typography**: Bundled fonts are licensed under the [SIL Open Font License 1.1](assets/fonts/OFL.txt).
