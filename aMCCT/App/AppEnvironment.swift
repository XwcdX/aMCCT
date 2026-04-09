import Foundation
import ManagedSettings
import SwiftData
import UserNotifications

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

        setupNotifications()

        Task {
            try? await Task.sleep(for: .seconds(1))
            do {
                try await screenTimeService.startMonitoring()
                print("AppEnvironment: monitoring started successfully")
            } catch {
                print("AppEnvironment: startMonitoring failed: \(error)")
            }
        }
    }

    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [
            .alert, .sound, .badge,
        ]) { _, _ in }

        let openAction = UNNotificationAction(
            identifier: "OPEN_APP",
            title: "Open",
            options: .foreground
        )
        let category = UNNotificationCategory(
            identifier: "FRICTION_TASK",
            actions: [openAction],
            intentIdentifiers: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}
