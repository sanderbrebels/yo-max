import SwiftUI

struct AudioVisualizer: View {
    let audioMeterProvider: () -> AudioMeter
    let color: Color
    let isActive: Bool

    // Yo Max: fewer, rounder bars, symmetric like the app icon.
    private let barCount = 11
    private let barWidth: CGFloat = 4
    private let barSpacing: CGFloat = 3
    private let minHeight: CGFloat = 4
    private let maxHeight: CGFloat = 28

    private let phases: [Double]

    init(audioMeterProvider: @escaping () -> AudioMeter, color: Color, isActive: Bool) {
        self.audioMeterProvider = audioMeterProvider
        self.color = color
        self.isActive = isActive
        self.phases = (0..<barCount).map { Double($0) * 0.4 }
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.016)) { context in
            let audioMeter = audioMeterProvider()

            HStack(spacing: barSpacing) {
                ForEach(0..<barCount, id: \.self) { index in
                    RoundedRectangle(cornerRadius: barWidth / 2)
                        .fill(color)
                        .frame(
                            width: barWidth,
                            height: barHeight(
                                for: index,
                                at: context.date,
                                audioMeter: audioMeter
                            )
                        )
                }
            }
        }
    }

    private func barHeight(for index: Int, at date: Date, audioMeter: AudioMeter) -> CGFloat {
        guard isActive else { return minHeight }

        let time = date.timeIntervalSince1970
        let amplitude = max(0, min(1, pow(audioMeter.averagePower, 0.7)))  // boosted for visibility
        // Yo Max: a calmer wave (Tarmax motion) and a stronger peak in the middle.
        let wave = sin(time * 5 + phases[index]) * 0.35 + 0.65
        let center = Double(barCount - 1) / 2
        let centerDistance = abs(Double(index) - center) / center
        let centerBoost = 1.0 - (centerDistance * 0.6)

        return max(minHeight, minHeight + CGFloat(amplitude * wave * centerBoost) * (maxHeight - minHeight))
    }
}

// Flat bars shown when the recorder is idle (no audio input)
struct StaticVisualizer: View {
    private let barCount = 11  // Yo Max: matches AudioVisualizer
    private let barWidth: CGFloat = 4
    private let barHeight: CGFloat = 4
    private let barSpacing: CGFloat = 3
    let color: Color

    var body: some View {
        HStack(spacing: barSpacing) {
            ForEach(0..<barCount, id: \.self) { _ in
                RoundedRectangle(cornerRadius: barWidth / 2)
                    .fill(color.opacity(0.5))
                    .frame(width: barWidth, height: barHeight)
            }
        }
    }
}

// MARK: - Processing Status Display

struct ProcessingStatusDisplay: View {
    enum Mode {
        case transcribing
        case enhancing
    }

    let mode: Mode
    let color: Color

    private var label: LocalizedStringKey {
        switch mode {
        case .transcribing: return "Transcribing"
        case .enhancing: return "Enhancing"
        }
    }

    private var animationSpeed: Double {
        switch mode {
        case .transcribing: return 0.18
        case .enhancing: return 0.22
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .foregroundColor(color)
                .font(.yoMax(11, weight: .medium))  // Yo Max: Aeonik
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            ProgressAnimation(color: color, animationSpeed: animationSpeed)
        }
        .frame(height: 28)  // matches AudioVisualizer maxHeight to prevent layout shift
    }
}
