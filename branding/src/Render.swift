import Foundation
import CoreGraphics
import CoreText
import ImageIO
import UniformTypeIdentifiers
import AppKit

/// Resolved from this file's location so the generator works from any cwd.
let repoRoot = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()   // src/
    .deletingLastPathComponent()   // branding/
    .deletingLastPathComponent()   // repo root
let repoFonts = repoRoot.appendingPathComponent("assets/fonts").path

func loadFont(_ file: String, size: CGFloat) -> CTFont {
    let url = URL(fileURLWithPath: "\(repoFonts)/\(file)") as CFURL
    guard let descs = CTFontManagerCreateFontDescriptorsFromURL(url) as? [CTFontDescriptor],
          let d = descs.first else { fatalError("no font at \(file)") }
    return CTFontCreateWithFontDescriptor(d, size, nil)
}

/// "SIMPLE" as outlines, in glyph space (y-up, origin on the baseline at x=0).
func wordPath(font: CTFont, text: String) -> CGPath {
    let attr = NSAttributedString(string: text, attributes: [
        .font: font as Any, .kern: 0
    ])
    let line = CTLineCreateWithAttributedString(attr)
    let out = CGMutablePath()
    for run in (CTLineGetGlyphRuns(line) as! [CTRun]) {
        let n = CTRunGetGlyphCount(run)
        var glyphs = [CGGlyph](repeating: 0, count: n)
        var pos = [CGPoint](repeating: .zero, count: n)
        CTRunGetGlyphs(run, CFRangeMake(0, n), &glyphs)
        CTRunGetPositions(run, CFRangeMake(0, n), &pos)
        let rf = (CTRunGetAttributes(run) as NSDictionary)[kCTFontAttributeName] as! CTFont
        for i in 0..<n {
            guard let gp = CTFontCreatePathForGlyph(rf, glyphs[i], nil) else { continue }
            out.addPath(gp, transform: CGAffineTransform(translationX: pos[i].x,
                                                         y: pos[i].y))
        }
    }
    return out
}

// --- palettes -------------------------------------------------------------

struct Stop { let c: (CGFloat, CGFloat, CGFloat); let loc: CGFloat }
struct Variant {
    let name: String
    let bg: [Stop]              // diagonal gradient; a single stop means flat
    let ink: (CGFloat, CGFloat, CGFloat)
    let accent: (CGFloat, CGFloat, CGFloat)?   // page-lines, nil = same as ink
    let diagonal: Bool
}
func hex(_ v: UInt32) -> (CGFloat, CGFloat, CGFloat) {
    (CGFloat((v >> 16) & 255)/255, CGFloat((v >> 8) & 255)/255, CGFloat(v & 255)/255)
}

let variants: [String: Variant] = [
    "mono":     Variant(name: "mono", bg: [Stop(c: hex(0x1C1F24), loc: 0), Stop(c: hex(0x000000), loc: 1)],
                        ink: hex(0xFFFFFF), accent: nil, diagonal: true),
    "sapphire": Variant(name: "sapphire", bg: [Stop(c: hex(0x2C6BF0), loc: 0), Stop(c: hex(0x0A337F), loc: 1)],
                        ink: hex(0xFFFFFF), accent: nil, diagonal: true),
    "ink":      Variant(name: "ink", bg: [Stop(c: hex(0x1B4FD8), loc: 0), Stop(c: hex(0x060B18), loc: 1)],
                        ink: hex(0xFFFFFF), accent: nil, diagonal: true),
    "flat":     Variant(name: "flat", bg: [Stop(c: hex(0x0F52BA), loc: 0)],
                        ink: hex(0xFFFFFF), accent: nil, diagonal: false),
    "gold":     Variant(name: "gold", bg: [Stop(c: hex(0x22262E), loc: 0), Stop(c: hex(0x05070A), loc: 1)],
                        ink: hex(0xFFFFFF), accent: hex(0xE9B44C), diagonal: true),
    "goldblue": Variant(name: "goldblue", bg: [Stop(c: hex(0x1B4FD8), loc: 0), Stop(c: hex(0x060B18), loc: 1)],
                        ink: hex(0xFFFFFF), accent: hex(0xF2C260), diagonal: true),
]

// --- composition ----------------------------------------------------------

let FONT = ProcessInfo.processInfo.environment["LOGO_FONT"] ?? "OpenSans-Bold.ttf"
let WORD = ProcessInfo.processInfo.environment["LOGO_WORD"] ?? "OFFLINE"

/// The mark in two layers so the page-lines can carry their own colour.
/// `body` is even-odd filled: outline minus counter, plus the wordmark.
func artwork() -> (body: CGPath, lines: CGPath) {
    let art = CGMutablePath()
    art.addPath(markOutline())
    art.addPath(markCounter())      // even-odd fill turns this into a hole

    let lines = CGMutablePath()
    for r in pageLines() { lines.addRect(r) }

    // The wordmark, rotated 90deg counter-clockwise so it reads bottom-to-top
    // with the letter tops facing the spine — the original arrangement.
    //
    // Cap height is derived rather than fixed: the word is set to run the exact
    // height of the B, so the mark has one flat top edge and one flat bottom
    // edge. The original left SIMPLE floating 14px short at the top and 4px at
    // the bottom, which is most of why it looked soft.
    let probe = loadFont(FONT, size: 100)
    let probeCap = CTFontGetCapHeight(probe)
    let probeW = wordPath(font: probe, text: WORD).boundingBox.width
    let runLength = G.bottom - G.coverTop
    let size = 100 * runLength / probeW
    let font = loadFont(FONT, size: size)
    let capH = probeCap * size / 100
    let word = wordPath(font: font, text: WORD)
    let wb = word.boundingBox

    // glyph space (y-up) -> design space (y-down), rotated CCW on screen.
    //   glyph +x (reading)  -> design -y (upward)
    //   glyph +y (letter up)-> design -x (leftward)
    var t = CGAffineTransform.identity
    t = t.translatedBy(x: G.spine - G.wordGap, y: G.bottom)   // baseline, first letter
    t = t.rotated(by: -.pi / 2)             // in y-down space this is CCW on screen
    t = t.scaledBy(x: 1, y: -1)             // undo glyph y-up
    t = t.translatedBy(x: -wb.minX, y: 0)
    art.addPath(word, transform: t)
    FileHandle.standardError.write("word=\(WORD) cap=\(capH) size=\(size)\n".data(using: .utf8)!)

    return (art, lines)
}

/// Union bounds of both layers — what gets centred on the canvas.
func artworkBounds() -> CGRect {
    let a = artwork()
    return a.body.boundingBox.union(a.lines.boundingBox)
}

func render(variant v: Variant, px: Int, scale: CGFloat, bgAlpha: CGFloat = 1,
            to path: String) {
    let cs = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(data: nil, width: px, height: px, bitsPerComponent: 8,
                              bytesPerRow: 0, space: cs,
                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
    else { fatalError("ctx") }
    ctx.interpolationQuality = .high
    ctx.setAllowsAntialiasing(true)
    ctx.setShouldAntialias(true)

    let s = CGFloat(px) / G.canvas
    // flip to y-down design space
    ctx.translateBy(x: 0, y: CGFloat(px))
    ctx.scaleBy(x: s, y: -s)

    // background
    if v.bg.count == 1 {
        let c = v.bg[0].c
        ctx.setFillColor(CGColor(red: c.0, green: c.1, blue: c.2, alpha: bgAlpha))
        ctx.fill(CGRect(x: 0, y: 0, width: G.canvas, height: G.canvas))
    } else if bgAlpha > 0 {
        let colors = v.bg.map { CGColor(red: $0.c.0, green: $0.c.1, blue: $0.c.2, alpha: bgAlpha) }
        let locs = v.bg.map { $0.loc }
        let grad = CGGradient(colorsSpace: cs, colors: colors as CFArray, locations: locs)!
        ctx.saveGState()
        ctx.clip(to: CGRect(x: 0, y: 0, width: G.canvas, height: G.canvas))
        let a = v.diagonal ? CGPoint(x: 0, y: 0) : CGPoint(x: 0, y: 0)
        let b = v.diagonal ? CGPoint(x: G.canvas, y: G.canvas) : CGPoint(x: 0, y: G.canvas)
        ctx.drawLinearGradient(grad, start: a, end: b, options: [])
        ctx.restoreGState()
    }

    // artwork, recentred and scaled about the canvas centre
    let art = artwork()
    let bb = artworkBounds()
    var m = CGAffineTransform(translationX: G.canvas/2, y: G.canvas/2)
    m = m.scaledBy(x: scale, y: scale)
    m = m.translatedBy(x: -bb.midX, y: -bb.midY)

    let body = CGMutablePath(); body.addPath(art.body, transform: m)
    ctx.addPath(body)
    ctx.setFillColor(CGColor(red: v.ink.0, green: v.ink.1, blue: v.ink.2, alpha: 1))
    ctx.fillPath(using: .evenOdd)

    let lines = CGMutablePath(); lines.addPath(art.lines, transform: m)
    let lc = v.accent ?? v.ink
    ctx.addPath(lines)
    ctx.setFillColor(CGColor(red: lc.0, green: lc.1, blue: lc.2, alpha: 1))
    ctx.fillPath(using: .winding)

    guard let img = ctx.makeImage() else { fatalError("img") }
    let url = URL(fileURLWithPath: path) as CFURL
    let dest = CGImageDestinationCreateWithURL(url, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, img, nil)
    CGImageDestinationFinalize(dest)
}

