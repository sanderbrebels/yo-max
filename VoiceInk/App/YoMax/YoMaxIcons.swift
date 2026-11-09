import AVFoundation
import SwiftUI

/// Yo Max: a Phosphor icon by its Phosphor name (MIT, see Phosphor-LICENSE.txt), the icon set of Tarmax.
/// Uses the custom symbols in `Assets.xcassets/PhosphorSymbols` (see `YoMaxSymbols`), so it has the
/// same weight and optical size as every other icon. Yo Max rule (B, 2026-11-09): an icon is 4/3 of
/// its font size, so text + 4 beside the text it labels, and bold; the chosen page in the navigation is fill. Decorative: the
/// text or the button around it carries the label.
struct PhosphorIcon: View {
    enum Weight {
        case bold
        case fill
    }

    /// The 13.5 pt sidebar and row labels: an 18 pt icon (text + 4, built into the symbols).
    static let textSize: CGFloat = 13.5
    /// An icon alone in a small icon button (28 pt): the same 18 pt icon as beside text.
    static let buttonSize: CGFloat = 13.5
    /// A small companion icon, such as the "opens outside" arrow.
    static let smallSize: CGFloat = 11

    let name: String
    var weight: Weight = .bold
    var size: CGFloat = PhosphorIcon.textSize

    init(_ name: String, weight: Weight = .bold, size: CGFloat = PhosphorIcon.textSize) {
        self.name = name
        self.weight = weight
        self.size = size
    }

    var body: some View {
        Image(weight == .fill ? "ph.\(name).fill" : "ph.\(name)")
            .font(.yoMax(size))
            .accessibilityHidden(true)
    }
}

/// Yo Max: a small square icon button (Play, Copy) for rows; a soft fill on hover.
struct YoMaxIconButton: View {
    let icon: String
    var weight: PhosphorIcon.Weight = .bold
    var tint: Color = AppTheme.Text.primary
    let help: LocalizedStringKey
    let action: () -> Void

    @State private var isHovering = false

    static let side: CGFloat = 28
    /// The smallest pointer target for an icon-only control.
    static let minimumHitTarget: CGFloat = 24

    var body: some View {
        Button(action: action) {
            PhosphorIcon(icon, weight: weight, size: PhosphorIcon.buttonSize)
                .foregroundStyle(tint)
                .frame(width: Self.side, height: Self.side)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.sidebarRow, style: .continuous)
                        .fill(isHovering ? AppTheme.Brand.hoverSurface : .clear)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .help(help)
        .accessibilityLabel(help)
    }
}

/// Yo Max: plays one dictation at a time from the dashboard; a second tap stops it.
@MainActor
final class YoMaxQuickAudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    static let shared = YoMaxQuickAudioPlayer()

    @Published private(set) var playingID: UUID?
    private var player: AVAudioPlayer?

    func toggle(id: UUID, url: URL) {
        if playingID == id {
            stop()
            return
        }
        stop()
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.play()
            self.player = player
            playingID = id
        } catch {
            playingID = nil
        }
    }

    func stop() {
        player?.stop()
        player = nil
        playingID = nil
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in self.stop() }
    }
}

extension View {
    /// Yo Max: gives a small icon inside a button a hit area of at least 24 × 24 pt
    /// (the macOS minimum for a pointer target), without changing how it looks.
    func yoMaxIconHitTarget() -> some View {
        frame(minWidth: YoMaxIconButton.minimumHitTarget, minHeight: YoMaxIconButton.minimumHitTarget)
            .contentShape(Rectangle())
    }
}
