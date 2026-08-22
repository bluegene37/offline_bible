# Comprehensive Modern UI/UX Redesign Specification

**Date:** 2026-08-22  
**Status:** Approved  
**Target Platforms:** iOS & Android (Flutter)

---

## 1. Overview & Goals

This specification details the comprehensive UI/UX overhaul of the **Offline Bible** app. The objective is to elevate the visual aesthetic, usability, typography, and tactile responsiveness to match modern standards (inspired by Apple Books, YouVersion, and Material 3 Expressive) while preserving all existing offline functionality, GetX controllers, and Hive storage persistence.

---

## 2. Design System & Theming Tokens

### 2.1 Theme & Surface Palette
- **Light Theme**:
  - Background: Clean off-white canvas (`#F8F9FA` / `#FCFCFD`).
  - Cards & Containers: Crisp white surfaces (`#FFFFFF`) with subtle border lines (`0.5px` border with 6% opacity) and soft ambient drop shadows.
  - Header/AppBar: Clean translucent/tinted surface without harsh solid color blocks.
- **Dark Theme / OLED Mode**:
  - Background: Deep obsidian/slate canvas (`#121316` / `#0E0F12`).
  - Cards & Containers: Elevated dark slate surfaces (`#1A1C22` / `#22242B`) with subtle border delineation (`#2D3039`).
  - Highlight markers in dark mode use dimmed alpha (30%) to maintain high text contrast without visual glare.

### 2.2 Curated Color Palette
A refined collection of 12+ aesthetic seed colors with complementary container shades:
- **Sapphire Blue** (`#1E88E5`)
- **Emerald Green** (`#2E7D32`)
- **Forest Teal** (`#00897B`)
- **Royal Amethyst** (`#7B1FA2`)
- **Sunset Amber** (`#F57C00`)
- **Crimson Rose** (`#D32F2F`)
- **Warm Terracotta** (`#E64A19`)
- **Ocean Cyan** (`#0097A7`)
- **Midnight Slate** (`#455A64`)
- **Deep Indigo** (`#3949AB`)
- **Warm Coral** (`#F06292`)
- **Obsidian Black** (`#212121`)

### 2.3 Typography Tokens
- Dynamic Google Fonts integration (Open Sans, Lato, Merriweather, Roboto Serif, Georgia/Literata, etc.).
- Proportional line heights (`1.2` to `2.4`) and scalable font size (`12px` to `34px`).
- Distinct verse number styling: subtle muted superscript/accent text with primary color tint.

---

## 3. Navigation & Header Experience

### 3.1 Translucent Bottom Navigation Bar
- Frosted glass effect / clean elevation container.
- Active pill indicator with subtle glow and accent color.
- Tactile haptic feedback (`HapticFeedback.selectionClick()`) on tab switch.
- Destinations:
  1. `Books` (Icon: `library_books`)
  2. `Chapters` (Icon: `grid_view_rounded` / `format_list_numbered`)
  3. `Bible` (Icon: `menu_book_rounded`)
  4. `Search` (Icon: `search_rounded`)
  5. `Settings` (Icon: `settings_rounded`)

### 3.2 Interactive Reader Header Capsule
- **Center Capsule**: Interactive pill showing `[ Book Chapter ▾ ]` and `[ Version ▾ ]`.
  - Tapping opens the **Quick Book & Chapter Switcher Bottom Sheet** with instant testament filtering, search, and chapter grid.
  - Tapping the version pill allows instant translation switching.
- **Header Actions**:
  - `Aa` Quick Display Settings sheet (font size slider, line spacing, font family selector).
  - Search shortcut and Audio Listen button.

---

## 4. Screen-by-Screen Specifications

### 4.1 Books Page (`BooksPage`)
- **Continue Reading Hero Card**:
  - Rounded card (`16px`), gradient border, last-read timestamp, book/chapter badge, and a primary "Resume Reading" action button.
- **Segmented Testament Filter**:
  - Smooth pill tabs for `All (66)`, `Old Testament (39)`, and `New Testament (27)`.
- **Instant Search Input**:
  - Filter books in real-time by typing (e.g., "Mat" -> Matthew).
- **Book Grid / List View**:
  - Modern responsive cards with book abbreviation, full title, testament badge, and chapter count pill.

### 4.2 Chapter Selection Grid (`ChapterPage`)
- Clean, responsive grid of rounded chapter numbers.
- Active chapter highlighted with vibrant accent background and high-contrast text.
- Header with selected book name, testament badge, and total chapters.

### 4.3 Bible Reader (`BiblePage`, `VerseList`, `VerseTile`)
- Immersive, breathable text layout with customizable margins and line heights.
- Smooth horizontal swipe navigation between adjacent chapters.
- Verse markers: elegant numbering with primary/muted accent styling.
- Highlight styling: soft pastel markers (Yellow, Green, Sky Blue, Pink, Purple, Orange, Teal, etc.).
- Audio indicator: soft animated glow and speaker badge on active speaking verse.

### 4.4 Floating Selection Toolbar (`SelectionToolbar`)
- Floating capsule above bottom navigation triggered on verse selection.
- **Row 1**: Pastel color highlighter swatches with Clear Highlight button.
- **Row 2**: Action icons with labels:
  - Copy verses (formatted reference + text)
  - Add / Edit Note (opens `NoteEditorSheet`)
  - Share verses (via system share sheet)
  - Bookmark verses
  - Listen / Speak selected verses
  - Dismiss / Clear selection

### 4.5 Audio Player Mini-Bar (`AudioPlayerBar`)
- Floating media bar when TTS reading is active.
- Current verse indicator (`Verse X of Y`).
- Playback speed dropdown / pill (`0.75x`, `1.0x`, `1.25x`, `1.5x`).
- Play / Pause / Stop controls with animated pulsing icon.

### 4.6 Saved Items (`NotesPage`, `NotesList`, `HighlightsList`, `BookmarksList`)
- Modern sliding segmented control: `Notes`, `Highlights`, `Bookmarks`.
- **Notes List**: Search bar, rich card with verse reference badge, note body, timestamp, and edit/delete popup.
- **Highlights List**: Color-coded cards reflecting marker color, verse reference, quote snippet, and 1-tap "Go to Verse".
- **Bookmarks List**: Clean card with reference badge, verse excerpt, date, and delete action.
- Empty states with custom modern icons, friendly messaging, and action hints.

### 4.7 Note Editor Sheet (`NoteEditorSheet`)
- Frosted top-rounded bottom sheet (`Radius.circular(24)`).
- Verse reference badge chip.
- Clean distraction-free multiline text area with subtle character/timestamp footer.
- Action buttons: Outlined "Delete" (for existing notes) and Elevated "Save Note".

### 4.8 Search Page (`SearchPage`, `SearchResultsList`, `SearchHistoryList`)
- Modern rounded search bar with clear button and real-time query handling.
- Filter chips: `All`, `Old Testament`, `New Testament`.
- Search Results: Card-based list with highlighted search terms in book reference and verse text, plus direct verse navigation.
- Search History: Interactive recent search tags with 1-tap re-search and "Clear All" action.

### 4.9 Reading Plans Page (`ReadingPlansPage`)
- Hero header with plan overview.
- Plan cards featuring category badge, completion badge (`X / Y Days`), title, description, and linear progress bar.
- Plan Detail page: Day-by-day checklist with circular status avatar, verse reference, and checkbox toggle.

### 4.10 Settings Page (`SettingsPage`, `ColorPicker`, `FontPicker`, `FontPreview`, `VersionManagerSheet`)
- **Verse of the Day**: Modern inspirational card with subtle gradient, quote styling, copy, share, and "Read Chapter" buttons.
- **Grouped Inset Sections** (Library, Bible Translation, Appearance, Reading, General, About).
- **Appearance**: Theme mode segmented button (`Auto`, `Light`, `Dark`) and circular color palette swatches with active selection ring.
- **Reading**: Font selector, Font Size slider, Line Spacing slider, and live interactive text preview card.
- **Version Manager**: Sheet showing bundled and downloaded translations with download progress and offline status badges.

---

## 5. Cross-Platform Polish & Micro-Interactions

- **Haptics**: Subtle haptic feedback (`HapticFeedback.lightImpact()` and `selectionClick()`) on tab changes, color selection, verse selection, and bookmark toggles.
- **Scroll Physics**: Platform-appropriate `BouncingScrollPhysics` for iOS and smooth clamping with overscroll stretch on Android.
- **Safe Area & Edge-to-Edge**: Full support for iOS dynamic island, home bar, and Android gesture navigation bar.

---

## 6. Architecture & Implementation Integrity

- **Controllers**: Maintain full backward compatibility with `AppController`, `BibleController`, `NotesController`, and `SearchController`.
- **Storage**: Retain all Hive boxes (`settings`, `notes`, `highlights`, `bookmarks`, `reading_plans`) without schema breaking changes.
- **Zero Asset Breakage**: Public domain Bible versions and local Google Fonts assets remain completely functional offline.
