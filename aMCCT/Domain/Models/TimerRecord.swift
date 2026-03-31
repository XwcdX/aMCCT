import Foundation
import SwiftData

@Model final class TimerRecord {
    var appTokenData: Data
    var unlockedAt: Date
    var expiresAt: Date
    var isActive: Bool {
        Date.now < expiresAt
    }

    init(appTokenData: Data, unlockedAt: Date = .now) {
        self.appTokenData = appTokenData
        self.unlockedAt   = unlockedAt
        self.expiresAt    = unlockedAt.addingTimeInterval(60 * 60 * 24)
    }
}
