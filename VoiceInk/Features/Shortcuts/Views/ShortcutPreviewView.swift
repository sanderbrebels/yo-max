import SwiftUI

struct ShortcutPreviewView: View {
    private let components: [String]?

    init(shortcut: Shortcut?) {
        self.components = shortcut?.displayTokens
    }

    var body: some View {
        if let components, !components.isEmpty {
            HStack(spacing: 6) {
                ForEach(components, id: \.self) { component in
                    KeyCapView(text: component)
                }
            }
        } else {
            KeyCapView(text: String(localized: "Not Set"))
                .foregroundColor(AppTheme.Text.secondary)
        }
    }

}

/// Yo Max (unslop, 2026-11-09): a flat keycap, a white key with a hairline and a slightly thicker
/// bottom edge. No gradients, glossy highlight or blurred shadows.
struct KeyCapView: View {
    let text: String

    private static let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)

    var body: some View {
        Text(text)
            .font(.yoMax(25, weight: .medium))
            .foregroundStyle(AppTheme.Text.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppTheme.Surface.card, in: Self.shape)
            .overlay(Self.shape.strokeBorder(AppTheme.Border.control, lineWidth: 1))
            .overlay(alignment: .bottom) {
                // The key's edge: one extra point of the same hairline at the bottom.
                Self.shape
                    .strokeBorder(AppTheme.Border.control, lineWidth: 1)
                    .offset(y: 1)
                    .mask(alignment: .bottom) { Rectangle().frame(height: 4) }
            }
    }
}

#Preview {
    VStack(spacing: 20) {
        ShortcutPreviewView(shortcut: ShortcutStore.shortcut(for: .primaryRecording))
        ShortcutPreviewView(shortcut: nil)
    }
    .padding()
}
