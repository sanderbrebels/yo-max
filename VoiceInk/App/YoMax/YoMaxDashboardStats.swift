import SwiftUI

/// Yo Max (schets dashboard-banner-3.html, variant A): total words, words per minute and the day
/// streak as three tiles under the banner, each a big figure with its label and a small sign
/// (Aa, a gauge, and this week as dots).
struct YoMaxDashboardStats: View {
    let totals: DashboardMetricTotals
    let dailyActivity: [DashboardProductivityPoint]

    var body: some View {
        HStack(spacing: 10) {
            tile(totals.words.formatted(), label: "words") {
                PhosphorIcon("text-aa").foregroundStyle(AppTheme.Text.secondary)
            }
            tile(wordsPerMinute.map { $0.formatted() } ?? "–", label: "words per minute") {
                PhosphorIcon("gauge").foregroundStyle(AppTheme.Text.secondary)
            }
            tile(streak.formatted(), label: streak == 1 ? "day in a row" : "days in a row") {
                weekDots
            }
        }
    }

    private func tile(
        _ value: String, label: LocalizedStringKey, @ViewBuilder sign: () -> some View
    ) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: value)
                    .font(.yoMax(28, weight: .medium))
                    .foregroundStyle(AppTheme.Text.primary)
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)
                Text(label)
                    .font(.yoMax(12.5))
                    .foregroundStyle(AppTheme.Text.secondary)
            }
            .lineLimit(1)
            Spacer(minLength: 0)
            sign()
                .padding(.bottom, 2)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(
            AppTheme.Brand.elevPage,
            in: RoundedRectangle(cornerRadius: AppTheme.Radius.tile, style: .continuous)
        )
        .accessibilityElement(children: .combine)
    }

    /// This week: the last seven days, a filled dot for a day with dictation.
    private var weekDots: some View {
        HStack(spacing: 4) {
            ForEach(Array(YoMaxDayWave.lastDays(from: dailyActivity).suffix(7).enumerated()), id: \.offset) { _, day in
                Circle()
                    .fill(day.words > 0 ? AppTheme.Text.primary : AppTheme.Brand.borderOutline)
                    .frame(width: 8, height: 8)
            }
        }
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
