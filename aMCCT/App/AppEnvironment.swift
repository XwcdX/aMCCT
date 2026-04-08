import Foundation
import SwiftData

@Observable
final class AppEnvironment {
    let dashboardViewModel: DashboardViewModel
    let screenTimeService: any ScreenTimeServicing

    init(modelContext: ModelContext) {
        self.dashboardViewModel = DashboardViewModel(modelContext: modelContext)
        self.screenTimeService = ScreenTimeService()
    }
}
