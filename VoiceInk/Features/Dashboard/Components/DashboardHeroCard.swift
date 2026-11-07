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
    // Yo Max: the stats in the banner (variant B of design/schetsen/dashboard-banner.html).
    let totals: DashboardMetricTotals
    let dailyActivity: [DashboardProductivityPoint]

    private var bannerShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: DashboardLayout.cardCornerRadius, style: .continuous)
    }

    var body: some View {
        Group {
            if isLocked {
                // Still locked: only the numbers, no headline and no button.
                YoMaxDashboardStats(totals: totals, dailyActivity: dailyActivity, axis: .horizontal)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 22)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                HStack(spacing: 0) {
                    storyColumn
                        .frame(maxWidth: .infinity, alignment: .leading)
                    statsColumn
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .background(AppTheme.Surface.banner)
        .clipShape(bannerShape)
        .overlay(bannerShape.strokeBorder(AppTheme.Border.card, lineWidth: 1))
    }

    private var statsColumn: some View {
        YoMaxDashboardStats(totals: totals, dailyActivity: dailyActivity)
            .padding(.horizontal, 22)
            .padding(.vertical, 20)
            .frame(width: DashboardLayout.bannerStatsColumnWidth, alignment: .leading)
            .frame(maxHeight: .infinity)
            .background(AppTheme.Surface.subtle)
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(AppTheme.Border.subtle)
                    .frame(width: 1)
            }
    }

    private var storyColumn: some View {
        VStack(alignment: .leading, spacing: 10) {
            heroCopy

            HStack(spacing: 12) {
                Button(action: onViewInsights) {
                    DashboardMomentumActionLabel(
                        title: actionTitle,
                        icon: actionIcon,
                        isPrimary: canViewInsights,
                        isLocked: !canViewInsights
                    )
                }
                .buttonStyle(.plain)
                .disabled(!canViewInsights)
                .help(actionHelp)
                .accessibilityLabel(Text(actionAccessibilityLabel))
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 22)
    }

    private var heroCopy: some View {
        VStack(alignment: .leading, spacing: 10) {
            headlineText
                .frame(maxWidth: 720, alignment: .leading)

            Text(subtext)
                .font(.yoMax(14))  // Yo Max: Tarmax body 400
                .foregroundStyle(DashboardMomentumBackground.subtext)
                .frame(maxWidth: 620, alignment: .leading)
        }
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
    private static let cornerRadius: CGFloat = 12

    let title: LocalizedStringKey
    let icon: String
    let isPrimary: Bool
    var isLocked = false

    var body: some View {
        HStack(spacing: 9) {
            Text(title)
                .lineLimit(2)

            Image(yoMax: icon)
                .font(.yoMax(13, weight: .semibold))
        }
        .font(.yoMax(13, weight: .semibold))
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, 18)
        .frame(minHeight: 40)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        )
        .shadow(color: shadowColor, radius: 5, y: 2)
    }

    private var foregroundColor: Color {
        if isPrimary {
            return Color.white
        }

        return isLocked
            ? DashboardMomentumBackground.subtext
            : DashboardMomentumBackground.headline
    }

    private var backgroundColor: Color {
        if isPrimary {
            return DashboardMomentumBackground.accent
        }

        return isLocked ? Color.white.opacity(0.64) : Color.white.opacity(0.82)
    }

    private var borderColor: Color {
        if isPrimary {
            return Color.clear
        }

        return isLocked ? DashboardMomentumBackground.accent.opacity(0.22) : Color.black.opacity(0.08)
    }

    private var shadowColor: Color {
        isPrimary ? DashboardMomentumBackground.accent.opacity(0.18) : Color.black.opacity(0.06)
    }
}

private struct DashboardMomentumBackground {
    // Yo Max: Tarmax colours on the new banner (ink and muted text).
    static let accent = AppTheme.Brand.ink
    static let headline = AppTheme.Brand.ink
    static let subtext = AppTheme.Brand.textMuted
}
