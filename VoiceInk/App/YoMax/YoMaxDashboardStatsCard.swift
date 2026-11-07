import SwiftUI

/// Yo Max (schets elevation-flow.html): total words, words per minute and the day streak,
/// in a soft inset card beside the recent dictations on the dashboard. Always visible,
/// also while VoiceInk's insights are still locked.
struct YoMaxDashboardStatsCard: View {
    let totals: DashboardMetricTotals
    let dailyActivity: [DashboardProductivityPoint]

    static let width: CGFloat = 200

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            stat(totals.words.formatted(), label: "words")
            stat(wordsPerMinute.map { $0.formatted() } ?? "–", label: "wpm")
            stat(streak.formatted(), label: "day streak")
        }
        .padding(18)
        .frame(width: Self.width, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DashboardLayout.cardCornerRadius, style: .continuous)
                .fill(AppTheme.Surface.subtle)
        )
        .accessibilityElement(children: .combine)
    }

    private func stat(_ value: String, label: LocalizedStringKey) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(verbatim: value)
                .font(.yoMax(24, weight: .medium))
                .foregroundStyle(AppTheme.Text.primary)
                .monospacedDigit()
            Text(label)
                .font(.yoMax(13))
                .foregroundStyle(AppTheme.Text.secondary)
        }
        .lineLimit(1)
    }

    /// Words per minute of speaking, over all dictations.
    private var wordsPerMinute: Int? {
        guard totals.duration >= 1, totals.words > 0 else { return nil }
        return Int((Double(totals.words) / (totals.duration / 60)).rounded())
    }

    /// Days in a row with at least one dictation, ending today (or yesterday, if today has none yet).
    private var streak: Int {
        let calendar = Calendar.current
        let activeDays = Set(
            dailyActivity.filter { $0.words > 0 }.map { calendar.startOfDay(for: $0.date) })
        var day = calendar.startOfDay(for: Date())
        if !activeDays.contains(day) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day) else { return 0 }
            day = yesterday
        }
        var count = 0
        while activeDays.contains(day) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return count
    }
}
