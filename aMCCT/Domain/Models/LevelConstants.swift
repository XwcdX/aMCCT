import Foundation

enum LevelConstants {
    static let increaseThreshold: Int = 2
    static let actualLevelMax: Int = 100
    static let currentLevelMax: Int = actualLevelMax + increaseThreshold

    static func dailyIncreaseLimit(actual: Int) -> Int {
        min(actual + 10, currentLevelMax)
    }

    static let dailyDecreaseLimit: Int = 2
}
