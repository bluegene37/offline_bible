# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-08-26

### Added
- **Complete Offline Scripture**: Built-in 66 books of the Authorized King James Version (KJV) bundled as zero-network local JSON.
- **Audio Bible (TTS) with Background Playback**:
  - Full chapter text-to-speech with adjustable playback rate (0.5x to 2.0x).
  - Synchronized real-time verse-by-verse highlighting during recitation.
  - Background audio mode on iOS and foreground media service on Android for continuous lock-screen listening.
- **Study Tools**:
  - Multi-color verse highlights (yellow, green, blue, pink, orange) persisted locally in Hive CE.
  - Personal note-taking system attached to single verses or multi-verse selections.
  - Instant bookmarks with jump-to-chapter navigation.
  - Red-Letter edition formatting highlighting the spoken words of Christ.
  - Scripture cross-reference index linking related passages across Old and New Testaments.
- **High-Performance Search**:
  - Instant local full-text search across all 31,102 verses.
  - Scoped filtering for Old Testament, New Testament, or entire Bible.
  - Persistent search history with quick-clear functionality.
- **Guided Reading Plans & Verse of the Day**:
  - Curated plans for Proverbs, Psalms, Gospel of John, and Epistles.
  - Interactive daily check-off progress tracking stored locally.
  - Daily Verse of the Day with one-tap copy and social share.
- **Customizable Reading Experience & Typography**:
  - 10 bundled reading typefaces: Atkinson Hyperlegible, EB Garamond, Lato, Literata, Lora, Merriweather, OpenDyslexic, Open Sans, Quattrocento, and Raleway.
  - Adjustable font size, line height, and margin spacing.
  - Multiple color themes including Pure Black (OLED), Dark, Light, Warm Sepia, and Midnight.
  - Automatic last-read position persistence across app restarts.
- **Multi-Translation Manager**:
  - Optional translation downloader supporting public domain translations from getbible API.
- **Production Asset Pipeline**:
  - Vector SVG logo generator with adaptive icons for Android 13+ themed icons, iOS 18 dark/tinted icons, macOS rounded icons, and web favicons.
  - Splash screen integration with Android 12+ circular masking compatibility.
- **CI/CD & Release Automation**:
  - Multi-platform GitHub Actions CI matrix (Ubuntu, macOS, Windows).
  - Automated release workflow building Android App Bundle (`.aab`), Universal APK (`.apk`), iOS archive (`.xcarchive`), macOS bundle, and Web distribution.
