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

        // Elevation (Tarmax variant B): depth from tone, a shadow only for what floats.
        static let elevPage = dynamic(light: rgb(0xF5F5F5), dark: rgb(0x000000))  // --elev-page
        static let elevCard = dynamic(light: rgb(0xFFFFFF), dark: rgb(0x1C1C1E))  // --elev-card
        static let elevFloat = dynamic(light: rgb(0xFFFFFF), dark: rgb(0x2C2C2E))  // --elev-float
        static let elevInset = dynamic(light: rgb(0xF6FAF5), dark: rgb(0x242426))  // --elev-inset (--canvas)
        static let fillStrong = dynamic(light: rgb(0xEEF4EC), dark: rgb(0x2C2C2E))  // --fill-strong
        static let text = dynamic(light: rgb(0x121213), dark: rgb(0xF0F0F0))  // --text
        static let textSecondary = dynamic(light: rgb(0x657064), dark: rgb(0xA3AAA2))  // --text-muted
        static let separator = dynamic(light: rgb(0xE5E5E5), dark: rgb(0x38383A))  // --separator
        static let borderOutline = dynamic(light: rgb(0xD1D1D1), dark: rgb(0x48484A))  // --border-outline
        // Yo Max: hover and press, ink over the surface (Tarmax --hover-surface 8 %, --press-surface 12 %).
        static let hoverSurface = dynamic(light: rgb(0x0B1F0D, alpha: 0.08), dark: rgb(0xFFFFFF, alpha: 0.10))
        static let hoverSoft = dynamic(light: rgb(0x0B1F0D, alpha: 0.04), dark: rgb(0xFFFFFF, alpha: 0.05))  // half a hover step
        static let pressSurface = dynamic(light: rgb(0x0B1F0D, alpha: 0.12), dark: rgb(0xFFFFFF, alpha: 0.14))
        static let success = dynamic(light: rgb(0x2D5A1E), dark: rgb(0x8FD47A))  // --success-text
        static let successIcon = dynamic(light: rgb(0x5FAD4D), dark: rgb(0x8FD47A))  // --success-icon
        static let warning = dynamic(light: rgb(0x8A5300), dark: rgb(0xF2C94C))  // --warn-text
        static let warningIcon = rgb(0xE8A735)  // --amber-450
        static let danger = dynamic(light: rgb(0xD93326), dark: rgb(0xFF8A7A))  // --danger
        static let info = dynamic(light: rgb(0x2F80ED), dark: rgb(0x60A5FA))  // --blue-500 / --blue-400

        /// The accent (also in AccentColor.colorset): ink on light, lime on dark.
        static let accent = dynamic(light: rgb(0x0B1F0D), dark: rgb(0x86F46D))
        /// Text on the accent: white on ink, ink on lime.
        static let onAccent = dynamic(light: rgb(0xFFFFFF), dark: rgb(0x0B1F0D))

        static func rgb(_ hex: UInt32, alpha: CGFloat = 1) -> NSColor {
            NSColor(
                srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
                green: CGFloat((hex >> 8) & 0xFF) / 255,
                blue: CGFloat(hex & 0xFF) / 255,
                alpha: alpha
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
        // Yo Max: Tarmax elevation. Page → card (white, no border, no shadow) → inset fill.
        static let card = Brand.elevCard
        static let materialCard = Brand.elevCard
        static let subtle = Brand.elevInset
        static let controlActive = Brand.fillStrong
        static let control = Brand.elevCard  // fields stay white (--surface)
        static let window = Brand.elevPage
        static let sidePanelOverlay = Brand.elevPage.opacity(0.50)
        // Yo Max (Flow elevation, 2026-11-07): the sidebar lies flat on the window page,
        // the content sits in one card-white panel with a hairline.
        static let contentPanel = Brand.elevCard
        static let banner = Brand.fillStrong  // Yo Max: the dashboard banner (--fill-strong)
        static let clear = Color.clear
    }

    enum Border {
        // Yo Max: Tarmax cards have no border; a line only marks a control or a separator.
        static let subtle = Brand.separator
        static let card = Brand.separator  // Yo Max: a card on the white content panel gets a hairline (--border)
        static let panel = Brand.separator  // Yo Max: the content panel's hairline
        static let control = Brand.borderOutline
        static let tint = Brand.separator
        static let sidePanelOuter = Color.white.opacity(0.12)
    }

    enum Selection {
        // Yo Max: Tarmax --selected-bg (soft green) with the accent as edge.
        static let fill = Brand.selectedBackground
        static let border = Brand.accent.opacity(0.35)
        static let foreground = Brand.text
    }

    enum Status {
        // Yo Max: Tarmax status colours.
        static let success = Brand.success
        static let positive = Brand.successIcon
        static let info = Brand.textSecondary
        static let infoStrong = Brand.info
        static let warning = Brand.warning
        static let warningStrong = Color(nsColor: Brand.warningIcon)
        static let error = Brand.danger
    }

    enum Data {
        // Yo Max: chart colours from the Tarmax palette.
        static let transcript = Brand.accent
        static let audio = Color(nsColor: Brand.rgb(0x5FAD4D))  // --green-525
        static let enhancement = Color(nsColor: Brand.rgb(0x39D29E))  // --teal-475
        static let purple = Color(nsColor: Brand.rgb(0x2F80ED))  // --blue-500
        static let yellow = Color(nsColor: Brand.rgb(0xE8A735))  // --amber-450
        static let orange = Color(nsColor: Brand.rgb(0xE8913A))  // --orange-425
    }

    enum Insights {
        // Yo Max: Tarmax elevation (page, card, and the soft inset for a card in a card).
        static let page = Brand.elevPage
        static let card = Brand.elevCard
        static let elevated = Brand.elevInset
        static let hover = Color.primary.opacity(0.045)
        static let border = AppTheme.Border.tint
        // Yo Max: Tarmax colours instead of system blue/teal.
        static let productivity = Brand.accent
        static let activity = Brand.textMuted
        static let selection = Brand.selectedBackground
        static let selectionText = Brand.accent
        static let grid = Color.primary.opacity(0.075)


        private static func dynamic(light: NSColor, dark: NSColor) -> Color {
            Color(nsColor: NSColor(name: nil) { appearance in
                let isDark = appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
                return isDark ? dark : light
            })
        }
    }

    enum Sidebar {
        // Yo Max (variant A "Zacht", 2026-11-07): Phosphor icons without tiles, the chosen page
        // a soft neutral fill on the page (like Flow). No lime.
        static let modes = Brand.brandDark  // the onboarding tile
        static let fallback = Brand.textSecondary  // footer actions on the dashboard
        static let license = Brand.success
        static let icon = Brand.textSecondary  // --icon-idle
        static let selectedIcon = Brand.text
        static let hoverRow = Brand.hoverSoft
        static let selectedRow = Brand.hoverSurface
        static let selectedRowText = Brand.text
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
        static let primary = Brand.text  // Yo Max: Tarmax --text
        static let secondary = Brand.textSecondary  // Yo Max: Tarmax --text-muted
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
        static let card: CGFloat = 20  // Yo Max: Tarmax --r-card
        static let pill: CGFloat = 22
        static let panel: CGFloat = 20  // Yo Max: the content panel (--r-card)
        static let sidebarRow: CGFloat = 10  // Yo Max: a sidebar row
        static let tile: CGFloat = 12  // Yo Max: Tarmax --r-tile (the stat tiles on the dashboard)
    }
}
