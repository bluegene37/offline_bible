# Offline Bible

A fast, fully offline King James Version (KJV) Bible app built with Flutter.
No internet connection required — the complete Bible text ships with the app.

## Features

- **Complete offline KJV Bible** — all 66 books, no network needed
- **Reading experience** — adjustable font, font size, light/dark mode, and color themes
- **Audio Bible** — listen to any chapter with text-to-speech, adjustable playback speed, and verse-by-verse highlighting
- **Highlights, notes, and bookmarks** — long-press or tap verses to highlight in multiple colors, attach notes, or bookmark
- **Search** — full-text search across the whole Bible or scoped to Old/New Testament, with search history
- **Reading plans** — built-in plans (Proverbs, Psalms, Gospel of John, Epistles) with per-day progress tracking
- **Verse of the Day** — a daily verse with copy/share
- **Continue reading** — the app reopens to the chapter you were last reading
- **Share and copy verses** — formatted with book, chapter, and version

## Getting started

```sh
flutter pub get
flutter run
```

### Release builds

Release targets are **Android** and **iOS** — see [RELEASING.md](RELEASING.md)
for versioning rules, signing setup, and the tag-push release flow.

```sh
# Android (needs android/key.properties — see android/key.properties.example)
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols/android

# iOS (needs your Apple team selected in Xcode automatic signing)
flutter build ipa --release --obfuscate --split-debug-info=build/symbols/ios
```

Pushing a `v*` tag builds both platforms in CI and attaches the artifacts to
a GitHub Release.

## Project structure

```
lib/
  core/          # app-wide controllers, services (storage, TTS, plans), theme, utils
  features/
    bible/       # books, chapters, verses, audio player, verse actions
    search/      # full-text search and history
    notes/       # notes, highlights, bookmarks
    plans/       # reading plans
    settings/    # appearance and app settings
    home/        # home shell and continue-reading card
    navigation/  # bottom navigation
assets/          # KJV text (kjv.json), book titles, app images
```

## Scripture rights

Rights in the Authorized (King James) Version in the United Kingdom are vested
in the Crown. Published by permission of the Crown's patentee, Cambridge
University Press.
