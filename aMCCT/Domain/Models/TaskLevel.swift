import Foundation

enum TaskLevel: Sendable {
    case beginner
    case intermediate
    case advanced
    case elite

    init(currentLevel: Int) {
        switch currentLevel {
        case 1...25:   self = .beginner
        case 26...50:  self = .intermediate
        case 51...75:  self = .advanced
        default:       self = .elite
        }
    }

    var holdDuration: Duration {
        switch self {
        case .beginner:      return .seconds(10)
        case .intermediate:  return .seconds(20)
        case .advanced:      return .seconds(30)
        case .elite:         return .seconds(45)
        }
    }

    var requiresTyping: Bool {
        switch self {
        case .beginner, .intermediate: return false
        case .advanced, .elite:        return true
        }
    }

    var typingPhraseCount: Int {
        switch self {
        case .beginner, .intermediate: return 0
        case .advanced:                return 1
        case .elite:                   return 2
        }
    }

    var displayName: String {
        switch self {
        case .beginner:     return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced:     return "Advanced"
        case .elite:        return "Elite"
        }
    }
}
