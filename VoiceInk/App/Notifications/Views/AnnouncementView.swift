import SwiftUI

struct AnnouncementView: View {
    let title: String
    let description: String
    let onClose: () -> Void
    let onLearnMore: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(title)
                    .font(.yoMax(14, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer()

                Button(action: onClose) {
                    Image(yoMax: "xmark")
                        .font(.yoMax(11, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .yoMaxIconHitTarget()  // Yo Max
                }
                .buttonStyle(PlainButtonStyle())
                .help("Close")  // Yo Max: label for VoiceOver and a tooltip
                .accessibilityLabel("Close")
            }

            if !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                ScrollView {
                    Text(description)
                        .font(.yoMax(12))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 120)
            }

            HStack(spacing: 8) {
                Button(action: onLearnMore) {
                    Text("Learn more")
                        .font(.yoMax(12, weight: .medium))
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: onClose) {
                    Text("Dismiss")
                        .font(.yoMax(12, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(minWidth: 360, idealWidth: 420)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.clear)
                .background(
                    // Yo Max: one flat brand-dark surface, like the recorder (no gradient, no glass).
                    AppTheme.Brand.brandDark
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.white.opacity(0.3), lineWidth: 0.5)
        )
    }
}
