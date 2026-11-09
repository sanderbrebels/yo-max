import SwiftUI

struct AppCardBackground: View {
    var isSelected: Bool = false
    var cornerRadius: CGFloat = AppTheme.Radius.card  // Yo Max: Tarmax --r-card

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(AppTheme.Surface.card)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        isSelected ? AppTheme.Selection.border : AppTheme.Border.card,  // Yo Max: hairline on the white panel
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
    }
}

struct AppMaterialCardBackground: View {
    var isSelected: Bool = false
    var cornerRadius: CGFloat = AppTheme.Radius.card  // Yo Max: Tarmax --r-card

    static let fill = AppTheme.Surface.materialCard

    static func border(for isSelected: Bool) -> Color {
        isSelected ? AppTheme.Selection.border : AppTheme.Border.card
    }

    static func lineWidth(for isSelected: Bool) -> CGFloat {
        isSelected ? 1.5 : 1
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Self.fill)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        Self.border(for: isSelected),
                        lineWidth: Self.lineWidth(for: isSelected)
                    )
            )
    }
}
