import Foundation
import FamilyControls

protocol ScreenTimeServicing: Sendable {
    func requestAuthorization() async throws
    func startMonitoring() async throws
}
