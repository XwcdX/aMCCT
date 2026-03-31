import Foundation

enum TaskError: LocalizedError {
    case holdTooShort
    case phraseIncorrect
    case taskExpired
 
    var errorDescription: String? {
        switch self {
        case .holdTooShort:   return "You let go too early. Try again."
        case .phraseIncorrect: return "Phrase didn't match. Check your typing."
        case .taskExpired:    return "Task timed out. Please try again."
        }
    }
}
