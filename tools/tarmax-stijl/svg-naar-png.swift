import AppKit
// usage: render out.png size in1.svg [in2.svg ...]  (side by side, with gap)
let a = CommandLine.arguments
let out = a[1]; let size = CGFloat(Double(a[2])!); let ins = Array(a[3...])
let gap: CGFloat = ins.count > 1 ? size * 0.12 : 0
let W = Int(CGFloat(ins.count) * size + CGFloat(ins.count - 1) * gap + (ins.count > 1 ? 2*gap : 0))
let H = Int(size + (ins.count > 1 ? 2*gap : 0))
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
if ins.count > 1 { NSColor(white: 0.85, alpha: 1).setFill(); NSRect(x: 0, y: 0, width: W, height: H).fill() }
for (i, p) in ins.enumerated() {
    guard let img = NSImage(contentsOfFile: p) else { fatalError("cannot load \(p)") }
    let x = (ins.count > 1 ? gap : 0) + CGFloat(i) * (size + gap)
    img.draw(in: NSRect(x: x, y: ins.count > 1 ? gap : 0, width: size, height: size))
}
NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
