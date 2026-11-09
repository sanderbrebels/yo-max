import SwiftUI

/// Yo Max (schets dashboard-banner-2.html, variant A): total words, words per minute and the day
/// streak as a row under the wave, each figure above its label.
struct YoMaxDashboardStats: View {
    let totals: DashboardMetricTotals
    let dailyActivity: [DashboardProductivityPoint]

    var body: some View {
        HStack(alignment: .top, spacing: 32) {
            stat(totals.words.formatted(), label: "words")
            stat(wordsPerMinute.map { $0.formatted() } ?? "–", label: "words per minute")
            stat(streak.formatted(), label: streak == 1 ? "day in a row" : "days in a row")
        }
        .accessibilityElement(children: .combine)
    }

    private func stat(_ value: String, label: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: value)
                .font(.yoMax(20, weight: .medium))
                .foregroundStyle(AppTheme.Text.primary)
                .monospacedDigit()
            Text(label)
                .font(.yoMax(12.5))
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
