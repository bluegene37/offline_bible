import Foundation
import CoreGraphics
import CoreText
import ImageIO
import UniformTypeIdentifiers

// ---------------------------------------------------------------------------
// Design space: 512 x 512, y increasing downward (same as the original PNG).
// Every number below was measured off assets/app_logo.png so the silhouette
// stays the one that shipped; only the ragged edges were regularised.
// ---------------------------------------------------------------------------

enum G {
    static let canvas: CGFloat = 512

    // Shared left edge. The original had the page-lines at x=210 and the body
    // at x=202 — an 8px stagger that read as a frayed spine. One value now.
    static let spine: CGFloat = 202

    static let coverTop: CGFloat  = 80     // was 88; band thickened, cover raised
    static let coverBot: CGFloat  = 94     // 14px cover line (was a ~7px hairline)
    static let waist: CGFloat     = 182    // counter floor / solid body starts
    static let bottom: CGFloat    = 391

    static let wordGap: CGFloat = 19       // air between wordmark and spine

    static let stripeRight: CGFloat = 352  // flush right edge of the page block
    static let stripeCount = 3
    static let stripeH: CGFloat = 13       // was 9px — sub-pixel at launcher size
    static let coverGap: CGFloat = 5       // extra air under the cover, so it
                                           // reads as a cover and not a 4th page
}

/// Outer silhouette of the book-B: cover line arcs over the top, thickens down
/// the right, pinches at the waist, then swells into the solid lower bowl.
func markOutline() -> CGPath {
    let p = CGMutablePath()
    p.move(to: CGPoint(x: G.spine, y: G.coverTop))
    p.addLine(to: CGPoint(x: 330, y: G.coverTop))
    p.addCurve(to: CGPoint(x: 388, y: 155),
               control1: CGPoint(x: 358, y: G.coverTop), control2: CGPoint(x: 388, y: 102))
    p.addCurve(to: CGPoint(x: 353, y: 222),
               control1: CGPoint(x: 388, y: 190), control2: CGPoint(x: 376, y: 209))
    p.addCurve(to: CGPoint(x: 395, y: 300),
               control1: CGPoint(x: 378, y: 236), control2: CGPoint(x: 395, y: 258))
    p.addCurve(to: CGPoint(x: 300, y: G.bottom),
               control1: CGPoint(x: 395, y: 347), control2: CGPoint(x: 378, y: G.bottom))
    p.addLine(to: CGPoint(x: G.spine, y: G.bottom))
    p.closeSubpath()
    return p
}

/// The counter — the black well the pages sit in.
func markCounter() -> CGPath {
    let p = CGMutablePath()
    p.move(to: CGPoint(x: G.spine, y: G.coverBot))
    p.addLine(to: CGPoint(x: 335, y: G.coverBot))
    p.addCurve(to: CGPoint(x: 372, y: 142),
               control1: CGPoint(x: 358, y: G.coverBot), control2: CGPoint(x: 372, y: 113))
    p.addCurve(to: CGPoint(x: 348, y: G.waist),
               control1: CGPoint(x: 372, y: 166), control2: CGPoint(x: 367, y: G.waist))
    p.addLine(to: CGPoint(x: G.spine, y: G.waist))
    p.closeSubpath()
    return p
}

/// Three page-lines on an even rhythm inside the counter.
func pageLines() -> [CGRect] {
    let span = G.waist - G.coverBot - G.coverGap
    let gap = (span - CGFloat(G.stripeCount) * G.stripeH) / CGFloat(G.stripeCount + 1)
    return (0..<G.stripeCount).map { i in
        let y = G.coverBot + G.coverGap + gap + CGFloat(i) * (G.stripeH + gap)
        return CGRect(x: G.spine, y: y, width: G.stripeRight - G.spine, height: G.stripeH)
    }
}
