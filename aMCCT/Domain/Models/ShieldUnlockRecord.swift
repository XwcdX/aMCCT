import Foundation
import SwiftData

@Model final class ShieldUnlockRecord {
    var appTokenData: Data

    var unlockedAt: Date
    var expiresAt: Date

    var disableRequestedAt: Date?
    var disableEffectiveAt: Date?

    var isDisabled: Bool

    var isUnlockActive: Bool {
        Date.now < expiresAt && !isDisabled
    }

    var isPendingDisable: Bool {
        disableRequestedAt != nil && Date.now < (disableEffectiveAt ?? .distantPast)
    }

    init(appTokenData: Data, unlockedAt: Date = .now) {
        self.appTokenData = appTokenData
        self.unlockedAt   = unlockedAt
        self.expiresAt    = unlockedAt.addingTimeInterval(86400) // 60 * 60 * 24

        self.disableRequestedAt = nil
        self.disableEffectiveAt = nil
        self.isDisabled         = false
    }
}
