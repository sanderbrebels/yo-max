import AVFoundation
import SwiftUI

/// Yo Max: Phosphor icons (MIT, see Phosphor-LICENSE.txt), the icon set of Tarmax.
/// The SVGs live in `Assets.xcassets/Phosphor` as template images named `ph-<name>-<weight>`.
/// Tarmax rule: beside text an icon is 1 em and bold; the chosen page in the navigation is fill.
/// To add an icon: download `assets/<weight>/<name>-<weight>.svg` from @phosphor-icons/core,
/// replace `fill="currentColor"` by `fill="#000000"` and add it as an imageset (template, vector).
struct PhosphorIcon: View {
    enum Weight: String {
        case bold
        case fill
    }

    /// The size of an icon beside 13–14 pt text (1 em).
    static let textSize: CGFloat = 16
    /// The size of an icon in a small icon button.
    static let buttonSize: CGFloat = 16

    let name: String
    var weight: Weight = .bold
    var size: CGFloat = PhosphorIcon.textSize

    init(_ name: String, weight: Weight = .bold, size: CGFloat = PhosphorIcon.textSize) {
        self.name = name
        self.weight = weight
        self.size = size
    }

    var body: some View {
        Image("ph-\(name)-\(weight.rawValue)")
            .renderingMode(.template)
            .resizable()
            .interpolation(.high)
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
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
