import SwiftUI

enum AppTheme {
    /// Yo Max: the Tarmax palette (see ~/GIT/tarmax/DESIGN_SYSTEMS.md and tokens.css).
    /// Screens use the meanings below; only this block holds the colours themselves.
    enum Brand {
        static let lime = Color(nsColor: rgb(0x86F46D))  // --lime-400: action and selection
        static let limeTint = Color(nsColor: rgb(0xE1FCDB))  // --lime-100
        static let ink = Color(nsColor: rgb(0x0B1F0D))  // --green-950: text and the primary button
        static let brandDark = Color(nsColor: rgb(0x212520))  // --dark-900: logo, splash, recorder
        static let textMuted = Color(nsColor: rgb(0x657064))  // --green-500
        static let selectedBackground = dynamic(light: rgb(0xE9F6E5), dark: rgb(0x2F4A24))  // --green-75 / --green-775

        /// The accent (also in AccentColor.colorset): ink on light, lime on dark.
        static let accent = dynamic(light: rgb(0x0B1F0D), dark: rgb(0x86F46D))
        /// Text on the accent: white on ink, ink on lime.
        static let onAccent = dynamic(light: rgb(0xFFFFFF), dark: rgb(0x0B1F0D))

        static func rgb(_ hex: UInt32) -> NSColor {
            NSColor(
                srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
                green: CGFloat((hex >> 8) & 0xFF) / 255,
                blue: CGFloat(hex & 0xFF) / 255,
                alpha: 1
            )
        }

        static func dynamic(light: NSColor, dark: NSColor) -> Color {
            Color(nsColor: NSColor(name: nil) { appearance in
                appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? dark : light
            })
        }
    }

    enum Accent {
        static let primary = Color.accentColor
        static let fillSubtle = primary.opacity(0.10)
        static let fill = primary.opacity(0.14)
        static let fillStrong = primary.opacity(0.28)
        static let border = primary.opacity(0.40)
        static let disabled = primary.opacity(0.50)
        static let foreground = primary.opacity(0.65)
        static let strong = primary.opacity(0.80)
        static let shadow = primary.opacity(0.20)
    }

    enum Surface {
        static let card = Color.secondary.opacity(0.10)
        static let materialCard = Color(nsColor: .controlBackgroundColor).opacity(0.50)
        static let subtle = Color.primary.opacity(0.06)
        static let controlActive = Color.secondary.opacity(0.14)
        static let control = Color(nsColor: .controlBackgroundColor)
        static let window = Color(nsColor: .windowBackgroundColor)
        static let sidePanelOverlay = Color(nsColor: .windowBackgroundColor).opacity(0.50)
        static let clear = Color.clear
    }

    enum Border {
        static let subtle = Color(nsColor: .separatorColor).opacity(0.28)
        static let card = Color(nsColor: .separatorColor).opacity(0.35)
        static let control = Color(nsColor: .separatorColor)
        static let tint = Color.primary.opacity(0.12)
        static let sidePanelOuter = Color.white.opacity(0.12)
    }

    enum Selection {
        static let fill = Color.primary.opacity(0.10)
        static let border = Color.primary.opacity(0.14)
        static let foreground = Color.primary.opacity(0.78)
    }

    enum Status {
        static let success = Color(nsColor: .alternateSelectedControlTextColor).opacity(0.85)
        static let positive = Color(nsColor: .systemGreen)
        static let info = Color(nsColor: .alternateSelectedControlTextColor).opacity(0.75)
        static let infoStrong = Color(nsColor: .systemBlue)
        static let warning = Color(nsColor: .alternateSelectedControlTextColor).opacity(0.85)
        static let warningStrong = Color(nsColor: .systemOrange)
        static let error = Color(nsColor: .systemRed)
    }

    enum Data {
        static let transcript = Color.indigo
        static let audio = Color.teal
        static let enhancement = Color.mint
        static let purple = Color(nsColor: .systemPurple)
        static let yellow = Color(nsColor: .systemYellow)
        static let orange = Color(nsColor: .systemOrange)
    }

    enum Insights {
        static let page = neutral(light: 0.995, dark: 0.065)
        static let card = neutral(light: 0.955, dark: 0.105)
        static let elevated = neutral(light: 1.0, dark: 0.145)
        static let hover = Color.primary.opacity(0.045)
        static let border = AppTheme.Border.tint
        // Yo Max: Tarmax colours instead of system blue/teal.
        static let productivity = Brand.accent
        static let activity = Brand.textMuted
        static let selection = Brand.selectedBackground
        static let selectionText = Brand.accent
        static let grid = Color.primary.opacity(0.075)

        private static func neutral(light: CGFloat, dark: CGFloat) -> Color {
            dynamic(light: NSColor(white: light, alpha: 1), dark: NSColor(white: dark, alpha: 1))
        }

        private static func dynamic(light: NSColor, dark: NSColor) -> Color {
            Color(nsColor: NSColor(name: nil) { appearance in
                let isDark = appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
                return isDark ? dark : light
            })
        }
    }

    enum Sidebar {
        // Yo Max: every tile is the Tarmax brand-dark with a lime sign, like the Tarmax badge.
        static let dashboard = Brand.brandDark
        static let modes = Brand.brandDark
        static let models = Brand.brandDark
        static let audio = Brand.brandDark
        static let dictionary = Brand.brandDark
        static let transcribeAudio = Brand.brandDark
        static let fallback = Brand.brandDark
        static let license = Brand.brandDark
        static let iconForeground = Brand.lime
        static let selectedRow = Brand.lime
        static let selectedRowText = Brand.ink
    }

    enum Waveform {
        static let hoverBubble = Color.primary.opacity(0.74)
        static let hoverMarker = Color.primary.opacity(0.68)
        static let playedLower = Color.primary
        static let playedUpper = Color.primary.opacity(0.80)
        static let unplayedLower = Color.primary.opacity(0.30)
        static let unplayedUpper = Color.primary.opacity(0.20)
    }

    enum Text {
        static let primary = Color(nsColor: .labelColor)
        static let secondary = Color(nsColor: .secondaryLabelColor)
        static let muted = secondary.opacity(0.70)
        static let disabled = Color(nsColor: .disabledControlTextColor)
        static let onAccent = Brand.onAccent  // Yo Max
    }

    enum NativeText {
        static let primary = NSColor.labelColor
    }

    enum Action {
        static let primaryFill = Accent.primary
        static let primaryForeground = Text.onAccent
        static let destructiveFill = Color(nsColor: .systemRed)
        static let destructiveForeground = Text.onAccent
        static let secondaryForeground = Text.primary
        static let disabledFill = Surface.controlActive
        static let disabledForeground = Text.disabled
    }

    enum Radius {
        static let control: CGFloat = 14
        static let card: CGFloat = 16  // Yo Max: Tarmax --r-card-sm
        static let pill: CGFloat = 22
    }
}
