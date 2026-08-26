# Release & Deployment Guide

This document serves as the authoritative guide for versioning, signing, building, and publishing releases of **Offline Bible**.

---

## 🎯 Target Platforms

| Platform | Distribution Channel | Target Asset Format | Signing / Notarization Requirement |
| :--- | :--- | :--- | :--- |
| **Android** | Google Play Store | Android App Bundle (`.aab`) | Java Keystore (Play App Signing / Upload Key) |
| **Android (Direct)** | GitHub Releases / Sideload | Universal APK (`.apk`) | Release Keystore / Self-signed |
| **iOS** | Apple App Store / TestFlight | iOS App Archive (`.ipa` / `.xcarchive`) | Apple Distribution Certificate + Provisioning Profile |
| **macOS** | GitHub Releases / DMG | Compressed App Bundle (`.zip`) | Apple Developer ID Application + `notarytool` (Optional for dev) |
| **Web** | Web Hosting / Static Pages | Static Web Bundle (`build/web.zip`) | HTTPS Hosting (PWA-ready) |

---

## 🔢 Versioning Specification

Offline Bible strictly follows [Semantic Versioning 2.0.0](https://semver.org/) and platform store build number requirements.

`pubspec.yaml` `version:` is the **single source of truth** across all platforms:

```yaml
version: 1.0.0+1
#        ^   ^   ^ ^
#        |   |   | +-- Monotonically increasing build number (Android versionCode, iOS CFBundleVersion)
#        +---+---+---- Semantic version: MAJOR.MINOR.PATCH (Android versionName, iOS CFBundleShortVersionString)
```

### Versioning Rules:
1. **Semantic Version (`MAJOR.MINOR.PATCH`)**:
   - `MAJOR`: Incompatible UI/storage architecture changes or major overhaul.
   - `MINOR`: New features, added reading plans, translations, or study tools (backwards-compatible).
   - `PATCH`: Bug fixes, typography adjustments, performance tuning, and hotfixes.
2. **Build Number (`+N`)**:
   - Must **strictly increase monotonically forever** with every production or internal test release.
   - Both Google Play and Apple App Store reject builds that reuse a previous build number, even if the semantic version changed. **Never reset the build number.**

---

## 🚀 Automated Release Pipeline (Tag-Push Flow)

Releases are fully automated via GitHub Actions (`.github/workflows/release.yml`).

### Step-by-Step Tagging Workflow:

1. **Update Version in `pubspec.yaml`**:
   ```yaml
   version: 1.0.1+2
   ```

2. **Update `CHANGELOG.md`**:
   Move items from `[Unreleased]` to the new version header `[1.0.1] - YYYY-MM-DD`.

3. **Verify Locally**:
   ```bash
   dart format --output=none --set-exit-if-changed .
   flutter analyze --fatal-infos
   flutter test
   ```

4. **Commit and Tag**:
   ```bash
   git commit -am "chore(release): bump version to 1.0.1+2"
   git tag v1.0.1
   git push origin master v1.0.1
   ```

5. **GitHub Release Output**:
   The workflow automatically compiles and attaches the following release assets:
   - `offline-bible-<version>.aab` — Google Play upload bundle
   - `offline-bible-<version>.apk` — Universal standalone Android APK
   - `android-symbols-<version>.zip` — Obfuscation debug symbols for crash symbolication
   - `ios-xcarchive-<version>.zip` — Xcode archive bundle
   - `ios-symbols-<version>.zip` — iOS dSYM obfuscation symbols
   - `macos-app-<version>.zip` — Standalone macOS desktop build
   - `web-build-<version>.zip` — PWA web assets

---

## 🔐 Signing & Credentials Configuration

### 1. Android (Google Play & Direct APK)
- **Local build configuration**:
  Create `android/key.properties` (this file is gitignored):
  ```properties
  storePassword=<your-store-password>
  keyPassword=<your-key-password>
  keyAlias=<your-key-alias>
  storeFile=/absolute/path/to/upload-keystore.jks
  ```
- **Generating a new upload keystore** (if needed):
  ```bash
  keytool -genkey -v -keystore android/app/upload-keystore.jks \
    -keyalg RSA -keysize 2048 -validity 10000 -alias upload
  ```
- **CI Secrets Configuration**:
  Add the following repository secrets in GitHub (`Settings -> Secrets and variables -> Actions`):
  - `ANDROID_KEYSTORE_BASE64`: Base64-encoded keystore (`base64 -i upload-keystore.jks | pbcopy`)
  - `ANDROID_KEYSTORE_PASSWORD`: Keystore password
  - `ANDROID_KEY_ALIAS`: Keystore alias (`upload`)
  - `ANDROID_KEY_PASSWORD`: Key password

### 2. iOS (App Store & TestFlight)
- **Local packaging**:
  Open `ios/Runner.xcworkspace` in Xcode, select your Apple Developer Team under **Runner -> Signing & Capabilities**.
- **CI packaging**:
  CI automatically compiles an unsigned `.xcarchive` with debug symbol obfuscation. Store `.ipa` generation is signed through Xcode / App Store Connect API or Transporter.

---

## 🛠️ Local Build Commands

### Android
```bash
# Build Android App Bundle (Google Play)
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols/android

# Build Universal APK (Direct sideload)
flutter build apk --release --obfuscate --split-debug-info=build/symbols/android
```

### iOS
```bash
# Build iOS Archive (Local Xcode signing)
flutter build ipa --release --obfuscate --split-debug-info=build/symbols/ios
```

### macOS Desktop
```bash
# Build macOS Desktop bundle
flutter build macos --release --obfuscate --split-debug-info=build/symbols/macos
```

### Web
```bash
# Build Web PWA bundle
flutter build web --release --base-href "/"
```

---

## 📋 Pre-Flight Release Checklist

- [ ] `version:` in `pubspec.yaml` bumped and build number incremented.
- [ ] `CHANGELOG.md` updated with release notes and date.
- [ ] `dart format --output=none --set-exit-if-changed .` passes.
- [ ] `flutter analyze --fatal-infos` returns zero issues.
- [ ] `flutter test` passes all tests (39+ unit and widget tests).
- [ ] Obfuscation debug symbols (`build/symbols/`) archived.
- [ ] Tested on physical Android device (min SDK 26+).
- [ ] Tested on physical iOS device / TestFlight.
- [ ] Google Play Data Safety form & App Store privacy declarations match `store/store_listing.md`.
- [ ] No unauthorized network telemetry added (only `api.getbible.net` for optional translations).
