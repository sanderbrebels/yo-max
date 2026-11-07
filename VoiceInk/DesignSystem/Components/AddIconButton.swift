import Foundation
import SwiftUI

struct AddIconButton: View {
    let helpText: LocalizedStringResource
    var size: CGFloat = 18
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(yoMax: "plus.circle.fill")
                .font(.yoMax(size))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(isDisabled ? .tertiary : .secondary)
        }
        .buttonStyle(.plain)
        .help(helpText)
        .accessibilityLabel(helpText)
        .disabled(isDisabled)
    }
}
