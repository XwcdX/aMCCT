import Foundation

@Observable
final class GraphSheetViewModel {
    var selectedRange: GraphSheetRange = .day {
        didSet {
            selectedBrainPoint = nil
            selectedShieldPoint = nil
        }
    }

    var selectedBrainPoint: GraphSheetPoint?
    var selectedShieldPoint: GraphSheetPoint?

    private let brainLevelSeries: [GraphSheetRange: [GraphSheetPoint]]
    private let shieldOpenSeries: [GraphSheetRange: [GraphSheetPoint]]

    init(
        brainLevelSeries: [GraphSheetRange: [GraphSheetPoint]]? = nil,
        shieldOpenSeries: [GraphSheetRange: [GraphSheetPoint]]? = nil
    ) {
        self.brainLevelSeries = brainLevelSeries ?? Self.previewBrainLevelSeries
        self.shieldOpenSeries = shieldOpenSeries ?? Self.previewShieldOpenSeries
    }

    var currentBrainLevelPoints: [GraphSheetPoint] {
        brainLevelSeries[selectedRange] ?? []
    }

    var currentShieldOpenPoints: [GraphSheetPoint] {
        shieldOpenSeries[selectedRange] ?? []
    }

    var currentBrainLevelAverage: Double {
        guard !currentBrainLevelPoints.isEmpty else { return 0 }
        return currentBrainLevelPoints.map(\.level).reduce(0, +) / Double(currentBrainLevelPoints.count)
    }

    var currentShieldOpenAverage: Double {
        guard !currentShieldOpenPoints.isEmpty else { return 0 }
        return currentShieldOpenPoints.map(\.level).reduce(0, +) / Double(currentShieldOpenPoints.count)
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

    var brainChartTitle: String {
        switch selectedRange {
        case .day:
            return "Brain level trend"
        case .week:
            return "Weekly brain level trend"
        case .month:
            return "Brain level growth this month"
        case .year:
            return "Brain level progress this year"
        }
    }

    var brainChartSubtitle: String {
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

    var shieldChartTitle: String {
        switch selectedRange {
        case .day:
            return "Shield open count trend"
        case .week:
            return "Weekly shield open count"
        case .month:
            return "Shield opens this month"
        case .year:
            return "Shield opens this year"
        }
    }

    var shieldChartSubtitle: String {
        "Tap a point to inspect shield open count"
    }

    var shieldChartMaxY: Double {
        let highestValue = currentShieldOpenPoints.map(\.level).max() ?? 10
        return max(10, highestValue + 2)
    }

    var culpritApps: [CulpritApp] {
        [
            CulpritApp(name: "Instagram", symbolName: "camera.fill"),
            CulpritApp(name: "YouTube", symbolName: "play.rectangle.fill"),
            CulpritApp(name: "TikTok", symbolName: "music.note"),
            CulpritApp(name: "X", symbolName: "bubble.left.and.bubble.right.fill"),
            CulpritApp(name: "Game", symbolName: "gamecontroller.fill")
        ]
    }

    func selectBrainPoint(_ point: GraphSheetPoint?) {
        selectedBrainPoint = point
    }

    func selectShieldPoint(_ point: GraphSheetPoint?) {
        selectedShieldPoint = point
    }

    static let previewBrainLevelSeries: [GraphSheetRange: [GraphSheetPoint]] = [
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

    static let previewShieldOpenSeries: [GraphSheetRange: [GraphSheetPoint]] = [
        .day: [
            GraphSheetPoint(index: 0, label: "06", detail: "06:00", level: 1),
            GraphSheetPoint(index: 1, label: "09", detail: "09:00", level: 3),
            GraphSheetPoint(index: 2, label: "12", detail: "12:00", level: 2),
            GraphSheetPoint(index: 3, label: "15", detail: "15:00", level: 4),
            GraphSheetPoint(index: 4, label: "18", detail: "18:00", level: 5),
            GraphSheetPoint(index: 5, label: "21", detail: "21:00", level: 3)
        ],
        .week: [
            GraphSheetPoint(index: 0, label: "Mon", detail: "Monday", level: 8),
            GraphSheetPoint(index: 1, label: "Tue", detail: "Tuesday", level: 7),
            GraphSheetPoint(index: 2, label: "Wed", detail: "Wednesday", level: 6),
            GraphSheetPoint(index: 3, label: "Thu", detail: "Thursday", level: 5),
            GraphSheetPoint(index: 4, label: "Fri", detail: "Friday", level: 6),
            GraphSheetPoint(index: 5, label: "Sat", detail: "Saturday", level: 4),
            GraphSheetPoint(index: 6, label: "Sun", detail: "Sunday", level: 3)
        ],
        .month: [
            GraphSheetPoint(index: 0, label: "01", detail: "1 Apr", level: 31),
            GraphSheetPoint(index: 1, label: "05", detail: "5 Apr", level: 27),
            GraphSheetPoint(index: 2, label: "10", detail: "10 Apr", level: 24),
            GraphSheetPoint(index: 3, label: "15", detail: "15 Apr", level: 20),
            GraphSheetPoint(index: 4, label: "20", detail: "20 Apr", level: 16),
            GraphSheetPoint(index: 5, label: "25", detail: "25 Apr", level: 14),
            GraphSheetPoint(index: 6, label: "30", detail: "30 Apr", level: 12)
        ],
        .year: [
            GraphSheetPoint(index: 0, label: "Jan", detail: "January", level: 98),
            GraphSheetPoint(index: 1, label: "Mar", detail: "March", level: 84),
            GraphSheetPoint(index: 2, label: "May", detail: "May", level: 72),
            GraphSheetPoint(index: 3, label: "Jul", detail: "July", level: 61),
            GraphSheetPoint(index: 4, label: "Sep", detail: "September", level: 54),
            GraphSheetPoint(index: 5, label: "Nov", detail: "November", level: 49),
            GraphSheetPoint(index: 6, label: "Dec", detail: "December", level: 44)
        ]
    ]
}

struct CulpritApp: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let symbolName: String
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
