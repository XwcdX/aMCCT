import Foundation

enum AppError: LocalizedError {
    case authorizationDenied
    case noSelectionFound
    case shieldApplicationFailed(underlying: Error)
    case storageCorrupted
 
    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Screen Time access was denied. Please enable it in Settings > Screen Time."
        case .noSelectionFound:
            return "No apps have been selected for blocking."
        case .shieldApplicationFailed(let e):
            return "Failed to apply shield: \(e.localizedDescription)"
        case .storageCorrupted:
            return "Local data could not be read. Please restart the app."
        }
    }
}
