import SwiftUI

struct ProBadge: View {
    var body: some View {
        Text("PRO")
            .font(.yoMax(10, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppTheme.Status.infoStrong.opacity(0.80))
            )
    }
}

#Preview {
    ProBadge()
}
