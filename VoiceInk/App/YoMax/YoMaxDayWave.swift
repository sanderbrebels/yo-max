import SwiftUI

/// Yo Max (schets dashboard-banner-3.html, variant A): the last 30 days as the wave of the app
/// icon, on the dark banner. One rounded lime bar per day, its height the words dictated that day;
/// a day without dictation is a small dot.
struct YoMaxDayWave: View {
    static let dayCount = 30

    let dailyActivity: [DashboardProductivityPoint]
    var height: CGFloat = 88

    private static let barWidth: CGFloat = 5
    private static let minimumBar: CGFloat = 6
    /// A day without dictation on the dark banner (--dark-700).
    private static let idle = Color(nsColor: AppTheme.Brand.rgb(0x424841))

    var body: some View {
        let days = Self.lastDays(from: dailyActivity)
        let maximum = max(days.map(\.words).max() ?? 0, 1)

        HStack(alignment: .bottom, spacing: 0) {
            ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                if index > 0 { Spacer(minLength: 2) }
                bar(words: day.words, maximum: maximum)
            }
        }
        .frame(height: height, alignment: .bottom)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Words per day, last 30 days"))
        .accessibilityValue(Text(accessibilitySummary(days)))
    }

    @ViewBuilder
    private func bar(words: Int, maximum: Int) -> some View {
        if words == 0 {
            Circle()
                .fill(Self.idle)
                .frame(width: Self.barWidth, height: Self.barWidth)
        } else {
            Capsule()
                .fill(AppTheme.Brand.lime)
                .frame(
                    width: Self.barWidth,
                    height: max(Self.minimumBar, height * CGFloat(words) / CGFloat(maximum)))
        }
    }

    private func accessibilitySummary(_ days: [(date: Date, words: Int)]) -> String {
        let active = days.filter { $0.words > 0 }.count
        return String(localized: "Dictated on \(active) of \(days.count) days")
    }

    /// The last 30 calendar days ending today, with 0 words for a day without dictation.
    static func lastDays(from points: [DashboardProductivityPoint]) -> [(date: Date, words: Int)] {
        let calendar = Calendar.current
        var wordsByDay: [Date: Int] = [:]
        for point in points {
            wordsByDay[calendar.startOfDay(for: point.date), default: 0] += point.words
        }
        let today = calendar.startOfDay(for: Date())
        return (0..<dayCount).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return (day, wordsByDay[day] ?? 0)
        }
    }
}

/// Yo Max: the time saved, compared with something from Sander's world (a ride on the bike).
enum YoMaxRideComparison {
    static func text(for timeSaved: TimeInterval) -> String {
        let minutes = Int((timeSaved / 60).rounded())
        let rides = minutes / 60
        switch rides {
        case 0:
            return String(localized: "Enough for a \(max(minutes, 1))-minute ride")
        case 1:
            return String(localized: "Enough for a one-hour ride")
        default:
            return String(localized: "Enough for \(rides) one-hour rides")
        }
    }
}
