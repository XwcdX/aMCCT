import SwiftUI
import FamilyControls

@Observable
@MainActor
final class OnboardingViewModel {
    var isAuthorizing = false
    var error: String?
    
    private let screenTimeService: any ScreenTimeServicing

    init(screenTimeService: any ScreenTimeServicing) {
        self.screenTimeService = screenTimeService
    }

    func authorize() async -> Bool {
        isAuthorizing = true
        error = nil
        
        do {
            try await screenTimeService.requestAuthorization()
            try await screenTimeService.startMonitoring()
            isAuthorizing = false
            return true
        } catch {
            isAuthorizing = false
            self.error = "Permission denied. Please enable it in Settings to continue."
            return false
        }
    }
}
