import Foundation
import SwiftData

@Model final class BrainState {
    var actualLevel: Int
    var currentLevel: Int
    
    var points: Int

    var dailyLevelIncreaseCount: Int
    var dailyLevelDecreaseCount: Int
    var dailyCounterResetDate: Date
    
    init() {
        self.actualLevel             = 1
        self.currentLevel            = 1
        self.points                  = 0
        self.dailyLevelIncreaseCount = 0
        self.dailyLevelDecreaseCount = 0
        self.dailyCounterResetDate   = Calendar.current.startOfDay(for: .now)
    }
}
