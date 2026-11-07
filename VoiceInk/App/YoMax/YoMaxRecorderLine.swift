import SwiftUI

/// Yo Max: recorder motion "C · Lijn" (design/schetsen/recorder-motion.html).
///
/// - Idle: one thin lime line, as wide as the waveform.
/// - Speaking: the line becomes the bars (`AudioVisualizer`, driven by the real mic level).
/// - Transcribing / enhancing: the line returns with a lime light that travels along it.
enum YoMaxRecorderLineMetrics {
    /// Same width as `AudioVisualizer`: 11 bars of 4 pt with 3 pt between them.
    static let width: CGFloat = 11 * 4 + 10 * 3
    static let thickness: CGFloat = 3
    /// Same height as `AudioVisualizer`'s maxHeight, so switching states never shifts the layout.
    static let frameHeight: CGFloat = 28
}

struct YoMaxIdleLine: View {
    var body: some View {
        Capsule()
            .fill(AppTheme.Brand.lime.opacity(0.55))
            .frame(width: YoMaxRecorderLineMetrics.width, height: YoMaxRecorderLineMetrics.thickness)
            .frame(height: YoMaxRecorderLineMetrics.frameHeight)
            .accessibilityHidden(true)
    }
}

struct YoMaxProcessingLine: View {
    let isEnhancing: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// One pass of the light along the line; constant motion, so linear.
    private let period: Double = 1.0
    private let highlightWidth: CGFloat = 26

    var body: some View {
        Group {
            if reduceMotion {
                Capsule().fill(AppTheme.Brand.lime)
            } else {
                TimelineView(.animation) { context in
                    let progress = context.date.timeIntervalSinceReferenceDate
                        .truncatingRemainder(dividingBy: period) / period
                    let travel = YoMaxRecorderLineMetrics.width + highlightWidth
                    let x = -highlightWidth + CGFloat(progress) * travel

                    ZStack(alignment: .leading) {
                        Capsule().fill(AppTheme.Brand.lime.opacity(0.35))
                        LinearGradient(
                            colors: [AppTheme.Brand.lime.opacity(0), AppTheme.Brand.lime, AppTheme.Brand.lime.opacity(0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: highlightWidth)
                        .offset(x: x)
                    }
                    .clipShape(Capsule())
                }
            }
        }
        .frame(width: YoMaxRecorderLineMetrics.width, height: YoMaxRecorderLineMetrics.thickness)
        .frame(height: YoMaxRecorderLineMetrics.frameHeight)
        .accessibilityElement()
        .accessibilityLabel(isEnhancing ? Text("Enhancing") : Text("Transcribing"))
    }
}
