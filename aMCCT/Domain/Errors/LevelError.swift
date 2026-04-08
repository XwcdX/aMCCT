import Foundation

enum LevelError: LocalizedError {
    case dailyDecreaseLimitReached
    case alreadyAtMinimum
 
    var errorDescription: String? {
        switch self {
        case .dailyDecreaseLimitReached:
            return "You've already decreased your level \(LevelConfig.dailyDecreaseLimit) times today."
        case .alreadyAtMinimum:
            return "Your level is already at the minimum."
        }
    }
}
