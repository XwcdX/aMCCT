import SwiftUI
import SwiftData

@main
struct aMCCTApp: App {
    let container: ModelContainer
    @State private var appEnvironment: AppEnvironment

    init() {
        do {
            let container = try ModelContainer(for: BrainState.self, StoreItem.self, TimerRecord.self)
            self.container = container
            self._appEnvironment = State(initialValue: AppEnvironment(modelContext: container.mainContext))
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(appEnvironment.dashboardViewModel)
                .modelContainer(container)
        }
    }
}
