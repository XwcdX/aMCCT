import Foundation
import FamilyControls

protocol ScreenTimeServicing: Sendable {
    func requestAuthorization() async throws
}
