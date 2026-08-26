# Releasing Offline Bible

Targets: **Android** (Google Play) and **iOS** (App Store). The `macos/` and
`web/` folders exist for development convenience but are not release targets.

## Versioning

`pubspec.yaml` `version:` is the **single source of truth**:

```yaml
version: 1.0.0+1   # <semantic version>+<build number>
```

- The semantic version (`1.0.0`) becomes Android `versionName` and iOS
  `CFBundleShortVersionString`.
- The build number (`+1`) becomes Android `versionCode` and iOS
  `CFBundleVersion`. Both platforms read it from pubspec automatically at
  build time — **nothing else needs to be bumped by hand**.
- The build number must **increase monotonically forever**. Both stores
  reject an upload that reuses a build number, even across different
  semantic versions. Never reset it.

Bump checklist for a release:

1. Edit `version:` in `pubspec.yaml` (bump the semver, always increment the
   build number).
2. That's it — Android and iOS pick it up from pubspec. No other file
   carries the version.

## Release flow (tag push)

```bash
# after bumping pubspec version and committing:
git tag v1.0.0
git push origin master v1.0.0
```

Pushing a `v*` tag triggers `.github/workflows/release.yml`, which runs
`flutter analyze` + `flutter test`, builds both platforms, and attaches the
artifacts to a GitHub Release:

- `offline-bible-<version>.aab` — Android App Bundle (Play-signed if the
  keystore secrets are configured, otherwise debug-signed)
- `android-symbols-<version>.zip` — obfuscation symbol files (archive these;
  they are required to symbolicate crash stacks for that exact build)
- `ios-xcarchive-<version>.zip` — unsigned iOS archive (CI has no Apple
  signing; produce the store `.ipa` locally, see below)
- `ios-symbols-<version>.zip` — iOS obfuscation symbols

## Local release builds

### Android

```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols/android
```

Output: `build/app/outputs/bundle/release/app-release.aab`. Upload the
`.aab` to Play Console; archive `build/symbols/android/` with the release.

### iOS

```bash
flutter build ipa --release --obfuscate --split-debug-info=build/symbols/ios
```

Output: `build/ios/ipa/*.ipa`. Upload via Transporter or
`xcrun altool`/App Store Connect. Archive `build/symbols/ios/`.

## Signing status

| Platform | Status |
|---|---|
| Android | `android/key.properties` (gitignored) + upload keystore. Copy `android/key.properties.example`, create the keystore with the keytool command in it. **Back up the keystore** — losing it means losing the ability to update the app on Play. Without `key.properties` the build falls back to debug signing (installable, not uploadable). |
| iOS | Xcode automatic signing. You must select your Apple team once in Xcode (Runner target → Signing & Capabilities). CI builds are unsigned archives only. |

CI Android signing (optional): set repo secrets
`ANDROID_KEYSTORE_BASE64` (`base64 -i upload.jks`), `ANDROID_KEYSTORE_PASSWORD`,
`ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`. Without them CI produces a
debug-signed `.aab` suitable only for verification.

## Pre-release checklist

- [ ] `version:` bumped in pubspec; build number never used before
- [ ] `flutter analyze` and `flutter test` clean
- [ ] Android SDK licenses accepted (`flutter doctor --android-licenses`)
- [ ] Release build tested on a real Android device (not only emulator)
- [ ] iOS build tested on a device via TestFlight
- [ ] Symbol files (`build/symbols/`) archived for this exact build
- [ ] No new debug output or dev endpoints (the only network calls should be
      `https://api.getbible.net` for optional translation downloads)
- [ ] Play Data Safety form and App Store privacy answers still accurate
      (see `store/store_listing.md`)
- [ ] Play: start with a staged rollout (e.g. 10%); App Store releases
      cannot be pulled back, only superseded

## Known gaps

- **No crash reporter is wired.** `lib/core/services/error_reporter.dart`
  logs via `debugPrint` and has a `TODO(release)` to forward to
  Crashlytics/Sentry. Until one is added, production crashes are only
  visible in device logs.
