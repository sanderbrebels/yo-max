import AppKit
import SwiftUI

/// Yo Max: every icon comes from Phosphor (the icon set of Tarmax), not from SF Symbols.
///
/// The Phosphor icons are custom symbols in `Assets.xcassets/PhosphorSymbols` (`ph.<name>` is bold,
/// `ph.<name>.fill` is fill), so they size with the font like an SF Symbol. Code keeps using the
/// SF Symbol names it already has; `Image(yoMax:)` and `Label(_:yoMax:)` translate them here.
/// A name that is not in the table falls back to the SF Symbol, so nothing ever goes missing.
///
/// Add an icon: download `assets/<bold|fill>/<name>-<weight>.svg` from @phosphor-icons/core,
/// replace `fill="currentColor"` by `fill="#000000"`, run
/// `swiftdraw in.svg --format sfsymbol --size medium --insets auto --output ph.<name>.svg`
/// (brew install swiftdraw), put it in a `.symbolset` and add a line to the table.
enum YoMaxSymbols {
    /// The asset name for an SF Symbol name, or nil when there is no Phosphor counterpart.
    static func asset(for systemName: String) -> String? {
        table[systemName]
    }

    private static let table: [String: String] = [
        "app": "ph.app-window",
        "app.fill": "ph.app-window.fill",
        "apple.logo": "ph.apple-logo.fill",
        "apple.terminal.fill": "ph.terminal-window.fill",
        "archivebox.fill": "ph.archive.fill",
        "arrow.2.squarepath": "ph.arrows-clockwise",
        "arrow.clockwise": "ph.arrow-clockwise",
        "arrow.clockwise.circle.fill": "ph.arrow-clockwise",
        "arrow.counterclockwise": "ph.arrow-counter-clockwise",
        "arrow.down.circle": "ph.arrow-circle-down",
        "arrow.down.circle.fill": "ph.arrow-circle-down.fill",
        "arrow.down.doc": "ph.file-arrow-down",
        "arrow.left.arrow.right": "ph.arrows-left-right",
        "arrow.right": "ph.arrow-right",
        "arrow.up.right": "ph.arrow-up-right",
        "arrow.up.right.circle.fill": "ph.arrow-circle-up-right.fill",
        "arrow.up.right.square": "ph.arrow-square-out",
        "arrow.uturn.backward": "ph.arrow-u-up-left",
        "bag.fill": "ph.bag.fill",
        "bicycle": "ph.bicycle",
        "bolt.circle.fill": "ph.lightning.fill",
        "bolt.fill": "ph.lightning.fill",
        "bolt.horizontal.circle.fill": "ph.lightning.fill",
        "book.fill": "ph.book.fill",
        "book.pages.fill": "ph.book-open.fill",
        "briefcase.fill": "ph.briefcase.fill",
        "bubble.left.and.bubble.right": "ph.chats",
        "bubble.left.and.bubble.right.fill": "ph.chats.fill",
        "bubble.left.and.text.bubble.right.fill": "ph.chats-teardrop.fill",
        "building.columns.circle.fill": "ph.bank.fill",
        "calendar": "ph.calendar-blank",
        "camera.fill": "ph.camera.fill",
        "captions.bubble": "ph.closed-captioning",
        "captions.bubble.fill": "ph.closed-captioning.fill",
        "cart.fill": "ph.shopping-cart.fill",
        "character.book.closed": "ph.book-open-text",
        "character.book.closed.fill": "ph.book-open-text.fill",
        "chart.bar.doc.horizontal": "ph.chart-bar-horizontal",
        "chart.bar.xaxis": "ph.chart-bar",
        "chart.line.uptrend.xyaxis": "ph.chart-line-up",
        "checkmark": "ph.check",
        "checkmark.circle": "ph.check-circle",
        "checkmark.circle.fill": "ph.check-circle.fill",
        "checkmark.seal": "ph.seal-check",
        "checkmark.seal.fill": "ph.seal-check.fill",
        "checkmark.shield": "ph.shield-check",
        "chevron.down": "ph.caret-down",
        "chevron.left": "ph.caret-left",
        "chevron.right": "ph.caret-right",
        "chevron.up": "ph.caret-up",
        "chevron.left.forwardslash.chevron.right": "ph.code",
        "chevron.up.chevron.down": "ph.caret-up-down",
        "circle.dashed": "ph.circle-dashed",
        "clock": "ph.clock",
        "clock.fill": "ph.clock.fill",
        "clock.arrow.circlepath": "ph.clock-counter-clockwise",
        "cloud.fill": "ph.cloud.fill",
        "cpu": "ph.cpu",
        "cpu.fill": "ph.cpu.fill",
        "cube": "ph.cube",
        "doc.on.clipboard": "ph.clipboard-text",
        "doc.on.doc": "ph.copy",
        "doc.text": "ph.file-text",
        "dollarsign.bank.building.fill": "ph.bank.fill",
        "ellipsis.circle": "ph.dots-three-circle",
        "envelope": "ph.envelope-simple",
        "envelope.fill": "ph.envelope-simple.fill",
        "exclamationmark.bubble.fill": "ph.warning-circle.fill",
        "exclamationmark.circle": "ph.warning-circle",
        "exclamationmark.circle.fill": "ph.warning-circle.fill",
        "exclamationmark.triangle": "ph.warning",
        "exclamationmark.triangle.fill": "ph.warning.fill",
        "flask.fill": "ph.flask.fill",
        "folder": "ph.folder",
        "gearshape": "ph.gear-six",
        "gearshape.fill": "ph.gear-six.fill",
        "globe": "ph.globe",
        "graduationcap.fill": "ph.graduation-cap.fill",
        "hand.raised": "ph.hand",
        "hourglass": "ph.hourglass",
        "house.fill": "ph.house.fill",
        "infinity": "ph.infinity",
        "info.circle": "ph.info",
        "info.circle.fill": "ph.info.fill",
        "internaldrive": "ph.hard-drive",
        "internaldrive.fill": "ph.hard-drive.fill",
        "key": "ph.key",
        "key.fill": "ph.key.fill",
        "keyboard": "ph.keyboard",
        "keyboard.fill": "ph.keyboard.fill",
        "leaf": "ph.leaf",
        "lightbulb.max.fill": "ph.lightbulb.fill",
        "link": "ph.link",
        "link.badge.plus": "ph.link",
        "list.bullet.clipboard.fill": "ph.clipboard-text.fill",
        "lock.fill": "ph.lock.fill",
        "lock.shield": "ph.lock-key",
        "long.text.page.and.pencil.fill": "ph.note-pencil.fill",
        "macbook": "ph.laptop",
        "magazine.fill": "ph.newspaper.fill",
        "magnifyingglass": "ph.magnifying-glass",
        "map.fill": "ph.map-trifold.fill",
        "mic": "ph.microphone",
        "mic.fill": "ph.microphone.fill",
        "mic.circle": "ph.microphone",
        "mic.slash": "ph.microphone-slash",
        "microphone": "ph.microphone",
        "microphone.fill": "ph.microphone.fill",
        "minus.circle": "ph.minus-circle",
        "minus.circle.fill": "ph.minus-circle.fill",
        "music.pages": "ph.music-notes",
        "note.text": "ph.note",
        "number": "ph.hash",
        "paintbrush.pointed.fill": "ph.paint-brush.fill",
        "paperplane.fill": "ph.paper-plane-tilt.fill",
        "pause": "ph.pause",
        "pause.fill": "ph.pause.fill",
        "pencil": "ph.pencil-simple",
        "pencil.circle.fill": "ph.pencil-circle.fill",
        "person": "ph.user",
        "person.crop.circle.badge.checkmark": "ph.user-circle-check",
        "phone.bubble.fill": "ph.phone.fill",
        "photo.fill.on.rectangle.fill": "ph.images.fill",
        "play": "ph.play",
        "play.fill": "ph.play.fill",
        "play.rectangle.fill": "ph.monitor-play.fill",
        "plus": "ph.plus",
        "plus.circle": "ph.plus-circle",
        "plus.circle.fill": "ph.plus-circle.fill",
        "quote.bubble.fill": "ph.quotes.fill",
        "receipt.fill": "ph.receipt.fill",
        "rectangle.2.swap": "ph.swap",
        "server.rack": "ph.hard-drives",
        "shield": "ph.shield",
        "shield.fill": "ph.shield.fill",
        "slash.circle.fill": "ph.prohibit.fill",
        "slider.horizontal.3": "ph.sliders-horizontal",
        "sparkle": "ph.sparkle",
        "sparkles": "ph.sparkle",
        "sparkles.square.fill.on.square": "ph.sparkle.fill",
        "square.and.arrow.down": "ph.download-simple",
        "square.and.arrow.up": "ph.export",
        "square.and.pencil": "ph.note-pencil",
        "square.grid.2x2": "ph.squares-four",
        "square.grid.2x2.fill": "ph.squares-four.fill",
        "star": "ph.star",
        "star.hexagon.fill": "ph.star.fill",
        "stop": "ph.stop",
        "stop.fill": "ph.stop.fill",
        "terminal": "ph.terminal",
        "text.alignleft": "ph.text-align-left",
        "text.bubble": "ph.chat-text",
        "text.bubble.fill": "ph.chat-text.fill",
        "text.cursor": "ph.cursor-text",
        "text.magnifyingglass": "ph.magnifying-glass",
        "timer": "ph.timer",
        "trash": "ph.trash",
        "tray.full.fill": "ph.tray.fill",
        "tree.fill": "ph.tree.fill",
        "video.fill": "ph.video-camera.fill",
        "wallet.bifold.fill": "ph.wallet.fill",
        "wand.and.stars": "ph.magic-wand",
        "waveform": "ph.waveform",
        "waveform.badge.magnifyingglass": "ph.waveform",
        "wifi": "ph.wifi-high",
        "xmark": "ph.x",
        "xmark.bin": "ph.trash-simple",
        "xmark.circle": "ph.x-circle",
        "xmark.circle.fill": "ph.x-circle.fill",
        "xmark.octagon.fill": "ph.x-circle.fill",
        "doc.text.fill": "ph.file-text.fill",
        "mic.badge.plus": "ph.microphone",
        "gauge.medium": "ph.gauge",
    ]
}

extension Image {
    /// Yo Max: the Phosphor icon for an SF Symbol name (falls back to the SF Symbol).
    init(yoMax systemName: String) {
        if let asset = YoMaxSymbols.asset(for: systemName) {
            self.init(asset)
        } else {
            self.init(systemName: systemName)
        }
    }
}

extension NSImage {
    /// Yo Max: the Phosphor icon for an SF Symbol name, for AppKit (falls back to the SF Symbol).
    static func yoMax(_ systemName: String, accessibilityDescription: String? = nil) -> NSImage? {
        if let asset = YoMaxSymbols.asset(for: systemName),
            let image = NSImage(symbolName: asset, bundle: .main, variableValue: 1)
        {
            image.accessibilityDescription = accessibilityDescription
            return image
        }
        return NSImage(systemSymbolName: systemName, accessibilityDescription: accessibilityDescription)
    }
}

extension Label where Title == Text, Icon == Image {
    /// Yo Max: like `Label(_:systemImage:)`, with the Phosphor icon.
    init(_ titleKey: LocalizedStringKey, yoMax systemName: String) {
        self.init { Text(titleKey) } icon: { Image(yoMax: systemName) }
    }

    @_disfavoredOverload
    init<S: StringProtocol>(_ title: S, yoMax systemName: String) {
        self.init { Text(title) } icon: { Image(yoMax: systemName) }
    }
}
