import Foundation
import SwiftData

@Observable
final class AppEnvironment {

    let dashboardViewModel: DashboardViewModel

    init(modelContext: ModelContext) {
        self.dashboardViewModel = DashboardViewModel(modelContext: modelContext)
    }
}
