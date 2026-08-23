import Foundation
import CoreGraphics
import CoreText
import ImageIO
import UniformTypeIdentifiers
import AppKit

// --- PNG -------------------------------------------------------------------

/// One renderer for every asset. `bgAlpha: 0` yields a transparent-ground
/// cut-out (splash, adaptive foreground); `markAlpha: 0` yields ground only
/// (adaptive background).

/// Paints the diagonal ground by computing the ramp per pixel.
///
/// CGGradient dithers, which is invisible here but adds enough high-frequency
/// noise to triple the size of the resulting PNG. A plain computed ramp bands
/// at 1/255 steps roughly 36px apart — imperceptible across this little
/// contrast — and compresses an order of magnitude better.
func drawGround(_ ctx: CGContext, px: Int, bg: [Stop], alpha: CGFloat, inset: CGFloat) {
    if bg.count == 1 {
        let c = bg[0].c
        ctx.setFillColor(CGColor(red: c.0, green: c.1, blue: c.2, alpha: alpha))
        ctx.fill(CGRect(x: 0, y: 0, width: G.canvas, height: G.canvas))
        return
    }
    let a = bg.first!.c, b = bg.last!.c
    var buf = [UInt8](repeating: 0, count: px * px * 4)
    let denom = CGFloat(2 * (px - 1))
    let span = max(1 - 2 * inset, 0.0001)
    for y in 0..<px {
        for x in 0..<px {
            var t = (CGFloat(x) + CGFloat(y)) / denom
            t = min(max((t - inset) / span, 0), 1)
            let i = (y * px + x) * 4
            buf[i]   = UInt8((a.0 + (b.0 - a.0) * t) * 255 + 0.5)
            buf[i+1] = UInt8((a.1 + (b.1 - a.1) * t) * 255 + 0.5)
            buf[i+2] = UInt8((a.2 + (b.2 - a.2) * t) * 255 + 0.5)
            buf[i+3] = UInt8(alpha * 255 + 0.5)
        }
    }
    let provider = CGDataProvider(data: Data(buf) as CFData)!
    let img = CGImage(width: px, height: px, bitsPerComponent: 8, bitsPerPixel: 32,
                      bytesPerRow: px * 4, space: CGColorSpaceCreateDeviceRGB(),
                      bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                      provider: provider, decode: nil, shouldInterpolate: false,
                      intent: .defaultIntent)!
    ctx.saveGState()
    ctx.translateBy(x: 0, y: G.canvas); ctx.scaleBy(x: 1, y: -1)
    ctx.draw(img, in: CGRect(x: 0, y: 0, width: G.canvas, height: G.canvas))
    ctx.restoreGState()
}

func emitPNG(px: Int, scale: CGFloat, bg: [Stop], bgAlpha: CGFloat,
             ink: (CGFloat, CGFloat, CGFloat), markAlpha: CGFloat,
             gradientInset: CGFloat, to path: String) {
    let cs = CGColorSpaceCreateDeviceRGB()
    let ctx = CGContext(data: nil, width: px, height: px, bitsPerComponent: 8,
                        bytesPerRow: 0, space: cs,
                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.setShouldAntialias(true)
    ctx.interpolationQuality = .high

    let s = CGFloat(px) / G.canvas
    ctx.translateBy(x: 0, y: CGFloat(px)); ctx.scaleBy(x: s, y: -s)

    if bgAlpha > 0 {
        drawGround(ctx, px: px, bg: bg, alpha: bgAlpha, inset: gradientInset)
    }

    if markAlpha > 0 {
        let art = artwork()
        let bb = artworkBounds()
        var m = CGAffineTransform(translationX: G.canvas/2, y: G.canvas/2)
        m = m.scaledBy(x: scale, y: scale)
        m = m.translatedBy(x: -bb.midX, y: -bb.midY)
        let body = CGMutablePath(); body.addPath(art.body, transform: m)
        let lines = CGMutablePath(); lines.addPath(art.lines, transform: m)
        ctx.setFillColor(CGColor(red: ink.0, green: ink.1, blue: ink.2, alpha: markAlpha))
        ctx.addPath(body);  ctx.fillPath(using: .evenOdd)
        ctx.addPath(lines); ctx.fillPath(using: .winding)
    }

    let img = ctx.makeImage()!
    let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL,
                                               UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, img, nil)
    CGImageDestinationFinalize(dest)
}

// --- SVG -------------------------------------------------------------------

func svgPathData(_ p: CGPath, transform m: CGAffineTransform) -> String {
    var out = ""
    func f(_ v: CGFloat) -> String {
        let r = (v * 1000).rounded() / 1000
        return r == r.rounded() ? "\(Int(r))" : "\(r)"
    }
    func pt(_ q: CGPoint) -> String { let a = q.applying(m); return "\(f(a.x)) \(f(a.y))" }
    p.applyWithBlock { e in
        let el = e.pointee
        switch el.type {
        case .moveToPoint:         out += "M\(pt(el.points[0]))"
        case .addLineToPoint:      out += "L\(pt(el.points[0]))"
        case .addQuadCurveToPoint: out += "Q\(pt(el.points[0])) \(pt(el.points[1]))"
        case .addCurveToPoint:     out += "C\(pt(el.points[0])) \(pt(el.points[1])) \(pt(el.points[2]))"
        case .closeSubpath:        out += "Z"
        @unknown default: break
        }
        out += " "
    }
    return out.trimmingCharacters(in: .whitespaces)
}

func emitSVG(scale: CGFloat, to path: String) {
    let art = artwork()
    let bb = artworkBounds()
    var m = CGAffineTransform(translationX: G.canvas/2, y: G.canvas/2)
    m = m.scaledBy(x: scale, y: scale)
    m = m.translatedBy(x: -bb.midX, y: -bb.midY)

    let body = svgPathData(art.body, transform: m)
    let lines = svgPathData(art.lines, transform: m)

    let svg = """
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
      <title>Offline Bible app mark</title>
      <!--
        Source of truth for every launcher icon and splash image in this repo.
        Regenerate the PNGs with tool/logo/ rather than editing them by hand.
        The wordmark is Open Sans Bold (SIL OFL 1.1, bundled in assets/fonts)
        converted to outlines, so nothing here depends on an installed font.
      -->
      <defs>
        <linearGradient id="ground" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stop-color="#1C1F24"/>
          <stop offset="1" stop-color="#000000"/>
        </linearGradient>
      </defs>
      <rect width="512" height="512" fill="url(#ground)"/>
      <g fill="#FFFFFF">
        <path fill-rule="evenodd" d="\(body)"/>
        <path d="\(lines)"/>
      </g>
    </svg>

    """
    try! svg.write(toFile: path, atomically: true, encoding: .utf8)
}

// --- macOS ------------------------------------------------------------------

/// Apple's continuous ("squircle") corner, as a sampled superellipse. macOS
/// icons are not full-bleed: the artwork sits in a rounded body inset from the
/// canvas, and the OS supplies no mask of its own.
func squirclePath(in r: CGRect, n: CGFloat = 5, steps: Int = 720) -> CGPath {
    let p = CGMutablePath()
    let a = r.width / 2, b = r.height / 2
    let cx = r.midX, cy = r.midY
    for i in 0...steps {
        let t = CGFloat(i) / CGFloat(steps) * 2 * .pi
        let ct = cos(t), st = sin(t)
        let x = cx + a * CGFloat(sign(ct)) * pow(abs(ct), 2 / n)
        let y = cy + b * CGFloat(sign(st)) * pow(abs(st), 2 / n)
        if i == 0 { p.move(to: CGPoint(x: x, y: y)) } else { p.addLine(to: CGPoint(x: x, y: y)) }
    }
    p.closeSubpath()
    return p
}
private func sign(_ v: CGFloat) -> CGFloat { v < 0 ? -1 : 1 }

/// macOS app icon: 824/1024 rounded body on a transparent canvas, per Apple's
/// icon grid, so it lines up with every other icon in the Dock.
func emitMacOS(px: Int, scale: CGFloat, bg: [Stop], ink: (CGFloat, CGFloat, CGFloat),
               to path: String) {
    let cs = CGColorSpaceCreateDeviceRGB()
    let ctx = CGContext(data: nil, width: px, height: px, bitsPerComponent: 8,
                        bytesPerRow: 0, space: cs,
                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.setShouldAntialias(true)
    let s = CGFloat(px) / G.canvas
    ctx.translateBy(x: 0, y: CGFloat(px)); ctx.scaleBy(x: s, y: -s)

    let bodyFrac: CGFloat = 824.0 / 1024.0
    let side = G.canvas * bodyFrac
    let body = CGRect(x: (G.canvas - side)/2, y: (G.canvas - side)/2, width: side, height: side)

    ctx.saveGState()
    ctx.addPath(squirclePath(in: body))
    ctx.clip()
    drawGround(ctx, px: px, bg: bg, alpha: 1, inset: 0)
    ctx.restoreGState()

    let art = artwork()
    let bb = artworkBounds()
    var m = CGAffineTransform(translationX: G.canvas/2, y: G.canvas/2)
    m = m.scaledBy(x: scale * bodyFrac, y: scale * bodyFrac)
    m = m.translatedBy(x: -bb.midX, y: -bb.midY)
    let bodyP = CGMutablePath(); bodyP.addPath(art.body, transform: m)
    let lineP = CGMutablePath(); lineP.addPath(art.lines, transform: m)
    ctx.setFillColor(CGColor(red: ink.0, green: ink.1, blue: ink.2, alpha: 1))
    ctx.addPath(bodyP);  ctx.fillPath(using: .evenOdd)
    ctx.addPath(lineP); ctx.fillPath(using: .winding)

    let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL,
                                               UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(dest, ctx.makeImage()!, nil)
    CGImageDestinationFinalize(dest)
}
