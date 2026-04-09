import Foundation
import SwiftData

@Model final class FrictionEvent {
    var timestamp: Date
    var appTokenData: Data?
    var pointsEarned: Int
    var taskType: String

    init(appTokenData: Data? = nil, pointsEarned: Int, taskType: String) {
        self.timestamp = .now
        self.appTokenData = appTokenData
        self.pointsEarned = pointsEarned
        self.taskType = taskType
    }
}
