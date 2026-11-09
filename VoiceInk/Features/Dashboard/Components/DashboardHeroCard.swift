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
    // Yo Max: the banner (variant A "Golf" of design/schetsen/dashboard-banner-2.html): the time
    // saved, the last 30 days as the wave of the app icon, and the stats in a row.
    let totals: DashboardMetricTotals
    let dailyActivity: [DashboardProductivityPoint]

    private var bannerShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: DashboardLayout.cardCornerRadius, style: .continuous)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !isLocked {
                HStack(alignment: .top, spacing: 24) {
                    heroCopy
                        .frame(maxWidth: .infinity, alignment: .leading)
                    insightsButton
                }
                .padding(.bottom, 24)
            }

            YoMaxDayWave(dailyActivity: dailyActivity)

            Rectangle()
                .fill(AppTheme.Border.card)
                .frame(height: 1)
                .padding(.vertical, 16)

            YoMaxDashboardStats(totals: totals, dailyActivity: dailyActivity)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Surface.card)
        .clipShape(bannerShape)
        .overlay(bannerShape.strokeBorder(AppTheme.Border.card, lineWidth: 1))
    }

    private var insightsButton: some View {
        Button(action: onViewInsights) {
            DashboardMomentumActionLabel(title: actionTitle, icon: actionIcon, isLocked: !canViewInsights)
        }
        .buttonStyle(.plain)
        .disabled(!canViewInsights)
        .help(actionHelp)
        .accessibilityLabel(Text(actionAccessibilityLabel))
    }

    @ViewBuilder
    private var heroCopy: some View {
        if case .savedTime(let value) = headline {
            VStack(alignment: .leading, spacing: 4) {
                Text("Time saved with Yo Max")
                    .font(.yoMax(13.5))
                    .foregroundStyle(DashboardMomentumBackground.subtext)

                Text(verbatim: value)
                    .font(.yoMax(44, weight: .medium))
                    .foregroundStyle(DashboardMomentumBackground.headline)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                HStack(spacing: 6) {
                    PhosphorIcon("bicycle")
                        .foregroundStyle(DashboardMomentumBackground.subtext)
                    Text(YoMaxRideComparison.text(for: timeSaved))
                        .font(.yoMax(13.5))
                        .foregroundStyle(DashboardMomentumBackground.headline)
                }
                .padding(.top, 2)
            }
        } else {
            VStack(alignment: .leading, spacing: 10) {
                headlineText
                    .frame(maxWidth: 720, alignment: .leading)

                Text(subtext)
                    .font(.yoMax(14))  // Yo Max: Tarmax body 400
                    .foregroundStyle(DashboardMomentumBackground.subtext)
                    .frame(maxWidth: 620, alignment: .leading)
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

private struct DashboardMomentumActionLabel: View {
    // Yo Max: a quiet outline pill (Tarmax outline button), weight 500, no shadow.
    let title: LocalizedStringKey
    let icon: String
    var isLocked = false

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .lineLimit(1)

            Image(yoMax: icon)
        }
        .font(.yoMax(13, weight: .medium))
        .foregroundStyle(isLocked ? DashboardMomentumBackground.subtext : DashboardMomentumBackground.headline)
        .padding(.horizontal, 16)
        .frame(height: 36)
        .background(AppTheme.Surface.card, in: Capsule())
        .overlay(Capsule().strokeBorder(AppTheme.Border.card, lineWidth: 1))
        .contentShape(Capsule())
    }
}

private struct DashboardMomentumBackground {
    // Yo Max: Tarmax colours on the new banner (ink and muted text).
    static let accent = AppTheme.Brand.ink
    static let headline = AppTheme.Brand.ink
    static let subtext = AppTheme.Brand.textMuted
}
