# Branding

Icon and splash sources for Offline Bible. Nothing here ships inside the app —
these files are read at build time by `flutter_launcher_icons` and
`flutter_native_splash`, which is why they live outside `assets/` (everything
under `assets/` is bundled into the APK/IPA).

## The mark

A book whose cover, pages and body form a **B**, with the wordmark set
vertically alongside it. The silhouette is the one the app has always had; it
was traced off the original 512px PNG and rebuilt as vector geometry so it stays
sharp from a 16px favicon to a 1024px App Store icon.

The wordmark is **Open Sans Bold** converted to outlines, so nothing here
depends on a font being installed. It is bundled in `assets/fonts` already and
is SIL OFL 1.1 licensed.

Colours are deliberately monochrome: a near-black diagonal ramp
(`#1C1F24` → `#000000`) behind a pure white mark.

## Files

| File | Used by |
| --- | --- |
| `app_logo.svg` | Vector source of truth. Not consumed by the build. |
| `app_logo.png` | iOS light icon, Android legacy icon, web icons |
| `app_logo_transparent.png` | iOS 18 dark and tinted appearances |
| `app_logo_foreground.png` | Android adaptive icon foreground |
| `app_logo_background.png` | Android adaptive icon background |
| `app_logo_monochrome.png` | Android 13+ themed icons |
| `app_logo_macos.png` | macOS icon (rounded body, transparent margin) |
| `app_logo_splash.png` | Splash screen, all platforms |
| `app_logo_splash_android12.png` | Android 12+ splash icon |

## Regenerating

```bash
./branding/src/build.sh          # rebuild the PNGs and SVG from the geometry
dart run flutter_launcher_icons  # push icons into ios/ android/ macos/ web/
dart run flutter_native_splash:create
```

Edit `src/Geometry.swift` to change the mark itself, or `src/main.swift` to
change colours and output sizes. Do not hand-edit the PNGs — they are outputs.

## Sizing constraints worth knowing

Three separate crops apply, and the generator accounts for each:

- **Android adaptive icons** are 108dp canvases with only the inner 72dp
  guaranteed visible, and Pixel launchers mask to a *circle*. The foreground is
  pre-scaled so the mark's bounding-box corners fit inside that circle, and
  `adaptive_icon_foreground_inset` is set to `0` in `pubspec.yaml` so the
  package does not inset it a second time.
- **Android 12+ splash icons** get the same two-thirds circular crop.
- **The adaptive background** has its gradient stops pulled inward, so the
  slice a launcher actually shows still spans the full ramp instead of a flat
  middle section.

`flutter_native_splash` treats its source image as 4x, so the splash PNGs are
512px rather than 1024px — that keeps the splash mark the same on-screen size
it has always been.
