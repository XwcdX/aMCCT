import SwiftUI
import SwiftData

@main
struct aMCCTApp: App {
    let container: ModelContainer
    @State private var appEnvironment: AppEnvironment
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    init() {
        do {
            let schema = Schema([
                BrainState.self,
                StoreItem.self,
                ShieldUnlockRecord.self,
                FrictionEvent.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            
            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            self.container = container
            let environment = AppEnvironment(modelContext: container.mainContext)
            self._appEnvironment = State(initialValue: environment)
        } catch {
            fatalError("CRITICAL: Failed to initialize SwiftData ModelContainer: \(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(appEnvironment.dashboardViewModel)
                .environment(appEnvironment)
                .modelContainer(container)
                
                .fullScreenCover(isPresented: .init(
                    get: { !hasSeenOnboarding },
                    set: { _ in }
                )) {
                    OnboardingView(
                        hasSeenOnboarding: $hasSeenOnboarding,
                        service: appEnvironment.screenTimeService
                    )
                    .environment(appEnvironment)
                    .modelContainer(container)
                    .interactiveDismissDisabled()
                }
        }
    }
}
