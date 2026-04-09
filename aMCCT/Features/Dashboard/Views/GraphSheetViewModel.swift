import Foundation

@Observable
final class GraphSheetViewModel {
    var selectedRange: GraphSheetRange = .day {
        didSet {
            selectedPoint = nil
        }
    }

    var selectedPoint: GraphSheetPoint?

    private let dataSeries: [GraphSheetRange: [GraphSheetPoint]]

    init(dataSeries: [GraphSheetRange: [GraphSheetPoint]]? = nil) {
        self.dataSeries = dataSeries ?? Self.previewDataSeries
    }

    var currentPoints: [GraphSheetPoint] {
        dataSeries[selectedRange] ?? []
    }

    var currentAverage: Double {
        guard !currentPoints.isEmpty else { return 0 }
        return currentPoints.map(\.level).reduce(0, +) / Double(currentPoints.count)
    }

    var periodLabel: String {
        switch selectedRange {
        case .day:
            return Date.now.formatted(date: .abbreviated, time: .shortened)
        case .week:
            return "Last 7 days"
        case .month:
            return Date.now.formatted(.dateTime.month(.wide).year())
        case .year:
            return Date.now.formatted(.dateTime.year())
        }
    }

    var chartTitle: String {
        switch selectedRange {
        case .day:
            return "Recent aMCC trend"
        case .week:
            return "Weekly aMCC trend"
        case .month:
            return "aMCC growth this month"
        case .year:
            return "aMCC progress this year"
        }
    }

    var chartSubtitle: String {
        switch selectedRange {
        case .day:
            return "Tap a point to inspect the exact hour"
        case .week:
            return "Tap any day to inspect its value"
        case .month:
            return "Tap a date to inspect the level"
        case .year:
            return "Tap a month to inspect the level"
        }
    }

    func select(point: GraphSheetPoint?) {
        selectedPoint = point
    }

    static let previewDataSeries: [GraphSheetRange: [GraphSheetPoint]] = [
        .day: [
            GraphSheetPoint(index: 0, label: "06", detail: "06:00", level: 39),
            GraphSheetPoint(index: 1, label: "09", detail: "09:00", level: 42),
            GraphSheetPoint(index: 2, label: "12", detail: "12:00", level: 48),
            GraphSheetPoint(index: 3, label: "15", detail: "15:00", level: 51),
            GraphSheetPoint(index: 4, label: "18", detail: "18:00", level: 57),
            GraphSheetPoint(index: 5, label: "21", detail: "21:00", level: 61)
        ],
        .week: [
            GraphSheetPoint(index: 0, label: "Mon", detail: "Monday", level: 41),
            GraphSheetPoint(index: 1, label: "Tue", detail: "Tuesday", level: 45),
            GraphSheetPoint(index: 2, label: "Wed", detail: "Wednesday", level: 49),
            GraphSheetPoint(index: 3, label: "Thu", detail: "Thursday", level: 53),
            GraphSheetPoint(index: 4, label: "Fri", detail: "Friday", level: 58),
            GraphSheetPoint(index: 5, label: "Sat", detail: "Saturday", level: 62),
            GraphSheetPoint(index: 6, label: "Sun", detail: "Sunday", level: 67)
        ],
        .month: [
            GraphSheetPoint(index: 0, label: "01", detail: "1 Apr", level: 35),
            GraphSheetPoint(index: 1, label: "05", detail: "5 Apr", level: 41),
            GraphSheetPoint(index: 2, label: "10", detail: "10 Apr", level: 47),
            GraphSheetPoint(index: 3, label: "15", detail: "15 Apr", level: 54),
            GraphSheetPoint(index: 4, label: "20", detail: "20 Apr", level: 60),
            GraphSheetPoint(index: 5, label: "25", detail: "25 Apr", level: 68),
            GraphSheetPoint(index: 6, label: "30", detail: "30 Apr", level: 74)
        ],
        .year: [
            GraphSheetPoint(index: 0, label: "Jan", detail: "January", level: 24),
            GraphSheetPoint(index: 1, label: "Mar", detail: "March", level: 34),
            GraphSheetPoint(index: 2, label: "May", detail: "May", level: 43),
            GraphSheetPoint(index: 3, label: "Jul", detail: "July", level: 55),
            GraphSheetPoint(index: 4, label: "Sep", detail: "September", level: 66),
            GraphSheetPoint(index: 5, label: "Nov", detail: "November", level: 78),
            GraphSheetPoint(index: 6, label: "Dec", detail: "December", level: 84)
        ]
    ]
}

enum GraphSheetRange: String, CaseIterable, Hashable {
    case day
    case week
    case month
    case year
}

struct GraphSheetPoint: Identifiable, Hashable {
    let id = UUID()
    let index: Int
    let label: String
    let detail: String
    let level: Double
}
