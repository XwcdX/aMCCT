import Foundation
import SwiftData

@Model final class BrainState {
    var actualLevel: Int
    var currentLevel: Int
    var totalPoints: Int
    var spendablePoints: Int
    
    var totalFrictions: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastFrictionDate: Date?

    var dailyLevelIncreaseCount: Int
    var dailyLevelDecreaseCount: Int
    var dailyCounterResetDate: Date

    var equippedBrainSkinID: String?
    var equippedBorderID: String?
    
    init() {
        self.actualLevel             = 1
        self.currentLevel            = 1
        self.totalPoints             = 0
        self.spendablePoints         = 0
        self.totalFrictions          = 0
        self.currentStreak           = 0
        self.longestStreak           = 0
        self.lastFrictionDate        = nil
        self.dailyLevelIncreaseCount = 0
        self.dailyLevelDecreaseCount = 0
        self.dailyCounterResetDate   = Calendar.current.startOfDay(for: .now)
    }
}
