import Foundation
import SwiftData
import ManagedSettings 

@Observable
final class AppEnvironment {
    let dashboardViewModel: DashboardViewModel
    let screenTimeService: any ScreenTimeServicing
    let shieldService: any ShieldServicing
    let coordinator: AppCoordinator

    init(modelContext: ModelContext) {
        self.coordinator = AppCoordinator()
        self.dashboardViewModel = DashboardViewModel(modelContext: modelContext)
        self.screenTimeService = ScreenTimeService()
        self.shieldService = ShieldService()
    }
}
