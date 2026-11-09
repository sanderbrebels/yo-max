import Foundation
import SwiftUI

enum DashboardHeroHeadline {
    case calculatingProgress
    case startRecordingProgress
    case savedTime(String)
}

struct DashboardHeroCard: View {
    private static let headlineFont: Font = .yoMax(23, weight: .medium)  // Yo Max: Tarmax 500
    private static let highlightedHeadlineFont: Font = .yoMax(30, weight: .medium)  // Yo Max: Tarmax 500

    let isLocked: Bool
    let headline: DashboardHeroHeadline
    let subtext: String
    let actionTitle: LocalizedStringKey
    let actionIcon: String
    let canViewInsights: Bool
    let actionHelp: String
    let actionAccessibilityLabel: String
    let onViewInsights: () -> Void
    // Yo Max: the banner (variant A of design/schetsen/dashboard-banner-3.html): a dark stage with
    // the time saved in lime and the last 30 days as the wave of the app icon, and the three stats
    // as tiles under it. A lime "View Insights" button under the figure (icoon-gewicht.html).
    let totals: DashboardMetricTotals
    let dailyActivity: [DashboardProductivityPoint]

    @State private var isHoveringButton = false

    private var stageShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: DashboardLayout.cardCornerRadius, style: .continuous)
    }

    var body: some View {
        VStack(spacing: 10) {
            stage
            YoMaxDashboardStats(totals: totals, dailyActivity: dailyActivity)
        }
    }

    private var stage: some View {
        HStack(alignment: .center, spacing: 24) {
            VStack(alignment: .leading, spacing: 14) {
                heroCopy
                if !isLocked, canViewInsights {
                    insightsButton
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            YoMaxDayWave(dailyActivity: dailyActivity, height: 96)
                .frame(maxWidth: 320)
        }
        .padding(.horizontal, 26)
        .padding(.vertical, 22)
        .background(AppTheme.Brand.brandDark, in: stageShape)
    }

    /// Lime on the dark stage: the one action of the dashboard (lime = action on dark, as in Tarmax).
    private var insightsButton: some View {
        Button(action: onViewInsights) {
            HStack(spacing: 8) {
                Text(actionTitle)
                PhosphorIcon("arrow-right", size: 13)
            }
            .font(.yoMax(13, weight: .medium))
            .foregroundStyle(AppTheme.Brand.ink)
            .padding(.horizontal, 16)
            .frame(height: 36)
            .background(
                AppTheme.Brand.lime.mix(with: .white, by: isHoveringButton ? 0.25 : 0), in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .help(actionHelp)
        .accessibilityLabel(Text(actionAccessibilityLabel))
        .onHover { isHoveringButton = $0 }
        .animation(.easeOut(duration: 0.15), value: isHoveringButton)
    }

    @ViewBuilder
    private var heroCopy: some View {
        if case .savedTime(let value) = headline {
            VStack(alignment: .leading, spacing: 2) {
                Text("Time saved with Yo Max")
                    .font(.yoMax(13))
                    .foregroundStyle(DashboardMomentumBackground.onDarkMuted)

                Text(verbatim: value)
                    .font(.yoMax(46, weight: .medium))
                    .foregroundStyle(AppTheme.Brand.lime)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                HStack(spacing: 6) {
                    PhosphorIcon("bicycle", size: 13)
                        .foregroundStyle(DashboardMomentumBackground.onDarkMuted)
                    Text(YoMaxRideComparison.text(for: timeSaved))
                        .font(.yoMax(13))
                        .foregroundStyle(Color.white)
                }
                .padding(.top, 4)
            }
        } else {
            VStack(alignment: .leading, spacing: 8) {
                headlineText
                Text(subtext)
                    .font(.yoMax(13.5))
                    .foregroundStyle(DashboardMomentumBackground.onDarkMuted)
            }
        }
    }

    private var timeSaved: TimeInterval {
        DashboardTimeSaving.timeSaved(words: totals.words, duration: totals.duration)
    }

    private var headlineText: Text {
        Text(styledHeadline)
    }

    private var styledHeadline: AttributedString {
        let highlightedValue: String
        var text: AttributedString

        switch headline {
        case .calculatingProgress:
            highlightedValue = String(localized: "Yo Max progress")
            text = AttributedString(localized: "Calculating \(highlightedValue).")
        case .startRecordingProgress:
            highlightedValue = String(localized: "Yo Max progress")
            text = AttributedString(localized: "Start recording to build \(highlightedValue).")
        case .savedTime(let value):
            highlightedValue = value
            text = AttributedString(localized: "You have saved \(highlightedValue) with Yo Max")
        }

        text.font = Self.headlineFont
        text.foregroundColor = DashboardMomentumBackground.headline

        if let highlightedRange = text.range(of: highlightedValue) {
            text[highlightedRange].font = Self.highlightedHeadlineFont
            text[highlightedRange].foregroundColor = DashboardMomentumBackground.accent
        }

        return text
    }
}

private struct DashboardMomentumBackground {
    // Yo Max: the dark banner (brand-dark): white text, lime for the figure, a soft grey beside it.
    static let accent = AppTheme.Brand.lime
    static let headline = Color.white
    static let subtext = AppTheme.Brand.textMuted
    static let onDarkMuted = Color(nsColor: AppTheme.Brand.rgb(0xA9B3A8))
}
