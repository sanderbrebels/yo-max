import SwiftUI

struct CompactHeroSection: View {
    let icon: String
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    var maxDescriptionWidth: CGFloat? = nil

    var body: some View {
        VStack(spacing: 16) {
            Image(yoMax: icon)
                .font(.yoMax(28))
                .foregroundStyle(AppTheme.Status.infoStrong)
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: 6) {
                Text(title)
                    .font(.yoMax(22, weight: .bold))
                Text(description)
                    .font(.yoMax(14))
                    .foregroundStyle(AppTheme.Text.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: maxDescriptionWidth)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
    }
}
