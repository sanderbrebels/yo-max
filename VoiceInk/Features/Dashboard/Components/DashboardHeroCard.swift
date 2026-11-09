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
    // as tiles under it. The whole stage opens Insights.
    let totals: DashboardMetricTotals
    let dailyActivity: [DashboardProductivityPoint]

    @State private var isHovering = false

    private var stageShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: DashboardLayout.cardCornerRadius, style: .continuous)
    }

    var body: some View {
        VStack(spacing: 10) {
            if isLocked {
                stage
            } else {
                Button(action: onViewInsights) { stage }
                    .buttonStyle(.plain)
                    .disabled(!canViewInsights)
                    .help(actionHelp)
                    .accessibilityLabel(Text(actionAccessibilityLabel))
                    .onHover { isHovering = $0 && canViewInsights }
            }

            YoMaxDashboardStats(totals: totals, dailyActivity: dailyActivity)
        }
    }

    private var stage: some View {
        HStack(alignment: .center, spacing: 24) {
            heroCopy
                .frame(maxWidth: .infinity, alignment: .leading)
            YoMaxDayWave(dailyActivity: dailyActivity)
                .frame(maxWidth: 320)
        }
        .padding(.horizontal, 26)
        .padding(.vertical, 22)
        .frame(minHeight: 132)
        .background(AppTheme.Brand.brandDark, in: stageShape)
        .overlay(alignment: .topTrailing) {
            if !isLocked, canViewInsights {
                Image(yoMax: "arrow.up.right")
                    .font(.yoMax(11))
                    .foregroundStyle(isHovering ? AppTheme.Brand.lime : DashboardMomentumBackground.onDarkMuted)
                    .padding(12)
                    .accessibilityHidden(true)
            }
        }
        .overlay(stageShape.strokeBorder(Color.white.opacity(isHovering ? 0.16 : 0), lineWidth: 1))
        .contentShape(stageShape)
        .animation(.easeOut(duration: 0.15), value: isHovering)
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
