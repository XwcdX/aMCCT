import SwiftUI

@Observable
final class AppCoordinator {
    var path = NavigationPath()
    var activeSheet: SheetDestination?
    var activeFullScreenTask: TaskDestination?

    enum SheetDestination: Identifiable {
        case settings
        var id: Self { self }
    }

    enum TaskDestination: Identifiable {
        case frictionTask
        var id: Self { self }
    }

    enum AppDestination: Hashable {
        case distractionHistory
        case store
    }
    
    func showSettings() {
        activeSheet = .settings
    }
    
    func showHistory() {
        path.append(AppDestination.distractionHistory)
    }
    
    func triggerFrictionTask() {
        activeFullScreenTask = .frictionTask
    }
}
