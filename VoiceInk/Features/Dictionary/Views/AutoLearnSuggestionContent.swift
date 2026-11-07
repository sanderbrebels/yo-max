import AppKit
import SwiftUI

struct AutoLearnSuggestionContent: View {
    let originalText: String?
    let correctedText: String
    let secondsRemaining: Int
    var dismissalDeadline: ContinuousClock.Instant?
    var dismissalSeconds = 10
    var isApplying = false
    var isValid = true
    var errorMessage: String?
    let onApprove: () -> Void
    let onDismiss: () -> Void

    // Yo Max: dark Tarmax card that belongs to the recorder (sketch 4B):
    // "tar max" crossed out → "Tarmax" on a lime highlight, No / Remember.
    private let onDarkMuted = Color(nsColor: AppTheme.Brand.rgb(0xA3AEA1))
    private let darkControl = Color(nsColor: AppTheme.Brand.rgb(0x2C312B))

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Remember this word?")
                .font(.yoMax(12, weight: .medium))
                .foregroundStyle(onDarkMuted)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 6) {
                if let originalText {
                    ViewThatFits(in: .vertical) {
                        originalTerms(originalText)
                        ScrollView {
                            originalTerms(originalText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(height: 104)
                    }
                    .frame(maxHeight: 104, alignment: .topLeading)
                }

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    if originalText != nil {
                        Image(systemName: "arrow.right")
                            .font(.yoMax(12, weight: .medium))
                            .foregroundStyle(onDarkMuted)
                            .accessibilityLabel("Replace with")
                    }
                    Text(correctedText)
                        .font(.yoMax(16, weight: .medium))
                        .foregroundStyle(AppTheme.Brand.ink)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(AppTheme.Brand.lime))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .textSelection(.enabled)

            if let errorMessage {
                Text(errorMessage)
                    .font(.yoMax(12))
                    .foregroundStyle(Color(nsColor: AppTheme.Brand.rgb(0xFF8A7A)))
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 8) {
                Spacer(minLength: 12)
                if isApplying {
                    ProgressView()
                        .controlSize(.small)
                        .colorScheme(.dark)
                }
                pill("No", fill: darkControl, text: .white, action: onDismiss)
                pill("Remember", fill: AppTheme.Brand.lime, text: AppTheme.Brand.ink, action: onApprove)
                    .disabled(!isValid)
                    .opacity(isValid ? 1 : 0.5)
            }
            .disabled(isApplying)
        }
        .padding(16)
        .padding(.bottom, 2)
        .frame(width: 360)
        .modifier(AutoLearnSuggestionSurface())
        .overlay(alignment: .bottom) {
            AutoLearnCountdownView(
                secondsRemaining: secondsRemaining,
                dismissalSeconds: dismissalSeconds,
                deadline: dismissalDeadline
            )
            .frame(maxHeight: .infinity, alignment: .bottom)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .allowsHitTesting(false)
        }
        .environment(\.colorScheme, .dark)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func originalTerms(_ text: String) -> some View {
        Text(text)
            .font(.yoMax(14))
            .strikethrough()
            .foregroundStyle(onDarkMuted)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func pill(_ title: LocalizedStringKey, fill: Color, text: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.yoMax(13, weight: .medium))
                .foregroundStyle(text)
                .padding(.horizontal, 16)
                .frame(minWidth: 64)
                .frame(height: 32)
                .background(Capsule().fill(fill))
        }
        .buttonStyle(.plain)
    }
}

private struct AutoLearnSuggestionSurface: ViewModifier {
    // Yo Max: solid brand-dark card (radius 20) instead of glass/popover material.
    private let shape = RoundedRectangle(cornerRadius: 20, style: .continuous)

    func body(content: Content) -> some View {
        content.background(AppTheme.Brand.brandDark, in: shape)
    }
}

private struct AutoLearnSuggestionBackdrop: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .popover
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    func updateNSView(_ view: NSVisualEffectView, context: Context) {}
}

private struct AutoLearnCountdownView: View {
    let secondsRemaining: Int
    let dismissalSeconds: Int
    let deadline: ContinuousClock.Instant?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60, paused: reduceMotion || deadline == nil || secondsRemaining == 0)) { _ in
            let remainingProgress = progress
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.white.opacity(0.08))  // Yo Max: lime timer on the dark card
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(AppTheme.Brand.lime)
                            .frame(width: geometry.size.width * remainingProgress)
                    }
            }
        }
        .transaction { $0.animation = nil }
        .frame(height: 3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Dismisses automatically")
        .accessibilityValue(Text(Duration.seconds(max(0, secondsRemaining)).formatted(.units(allowed: [.seconds]))))
    }

    private var progress: CGFloat {
        AutoLearnCountdownProgress.value(secondsRemaining: secondsRemaining, dismissalSeconds: dismissalSeconds,
            deadline: deadline, reduceMotion: reduceMotion)
    }
}

enum AutoLearnCountdownProgress {
    static func value(secondsRemaining: Int, dismissalSeconds: Int, deadline: ContinuousClock.Instant?,
        reduceMotion: Bool, now: ContinuousClock.Instant = ContinuousClock().now) -> CGFloat {
        let remainingSeconds: Double
        if !reduceMotion, let deadline {
            let remaining = now.duration(to: deadline).components
            remainingSeconds = Double(remaining.seconds) + Double(remaining.attoseconds) / 1e18
        } else {
            remainingSeconds = Double(secondsRemaining)
        }
        return CGFloat(min(1, max(0, remainingSeconds / Double(max(1, dismissalSeconds)))))
    }
}
