import Foundation
import FamilyControls

struct ScreenTimeService: ScreenTimeServicing {
    func requestAuthorization() async throws {
        let center = AuthorizationCenter.shared
        try await center.requestAuthorization(for: .individual)
    }
}
