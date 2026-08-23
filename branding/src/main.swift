import Foundation
import CoreGraphics

// Monochrome, as chosen: a barely-there diagonal lift off pure black, so the
// icon carries some depth without ceasing to be black and white.
let ground: [Stop] = [Stop(c: hex(0x1C1F24), loc: 0), Stop(c: hex(0x000000), loc: 1)]
let white  = hex(0xFFFFFF)

let dir = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : repoRoot.appendingPathComponent("branding").path

/// Full-bleed. iOS, Android's legacy icon and the web all mask this themselves.
let iconScale: CGFloat = 1.12
/// Android adaptive layers are 108dp with only the inner 72dp guaranteed
/// visible, and Pixel masks to a circle. The mark's bounding-box corners are
/// fitted to that circle, so nothing clips on any launcher.
let adaptiveScale: CGFloat = 0.83

func png(_ name: String, px: Int, scale: CGFloat, bgAlpha: CGFloat = 1,
         markAlpha: CGFloat = 1, inset: CGFloat = 0) {
    emitPNG(px: px, scale: scale, bg: ground, bgAlpha: bgAlpha, ink: white,
            markAlpha: markAlpha, gradientInset: inset, to: "\(dir)/\(name)")
}

png("app_logo.png",             px: 1024, scale: iconScale)
png("app_logo_transparent.png", px: 1024, scale: iconScale, bgAlpha: 0)
png("app_logo_foreground.png",  px: 1024, scale: adaptiveScale, bgAlpha: 0)
png("app_logo_monochrome.png",  px: 1024, scale: adaptiveScale, bgAlpha: 0)
// Stops pulled inward so the slice a launcher actually shows still spans the
// whole ramp rather than a flat middle section.
png("app_logo_background.png",  px: 1024, scale: adaptiveScale, markAlpha: 0, inset: 0.167)

// flutter_native_splash treats its source as 4x, so 512 keeps the splash mark
// the same on-screen size it is today.
png("app_logo_splash.png",           px: 512, scale: 1.0,           bgAlpha: 0)
// Android 12+ masks the splash icon to a circle with only the inner two thirds
// showing, same constraint as an adaptive icon.
png("app_logo_splash_android12.png", px: 512, scale: adaptiveScale, bgAlpha: 0)

emitMacOS(px: 1024, scale: iconScale, bg: ground, ink: white, to: "\(dir)/app_logo_macos.png")
emitSVG(scale: iconScale, to: "\(dir)/app_logo.svg")

print("wrote 8 icon sources + app_logo.svg to \(dir)")
