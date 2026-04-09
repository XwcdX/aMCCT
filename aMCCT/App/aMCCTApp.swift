import SharedKit
import SwiftData
import SwiftUI

@main
struct aMCCTApp: App {
    let container: ModelContainer
    @State private var appEnvironment: AppEnvironment
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @Environment(\.scenePhase) private var scenePhase

    init() {
        do {
            let schema = Schema([
                BrainState.self,
                StoreItem.self,
                ShieldUnlockRecord.self,
                FrictionEvent.self,
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

            let environment = AppEnvironment(
                modelContext: container.mainContext
            )
            self._appEnvironment = State(initialValue: environment)
        } catch {
            fatalError(
                "CRITICAL: Failed to initialize SwiftData ModelContainer: \(error.localizedDescription)"
            )
        }
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack(
                path: .init(
                    get: { appEnvironment.coordinator.path },
                    set: { appEnvironment.coordinator.path = $0 }
                )
            ) {
                DashboardView()
                    .environment(appEnvironment.dashboardViewModel)
                    .environment(appEnvironment.coordinator)
                    .environment(appEnvironment)
                    .navigationDestination(
                        for: AppCoordinator.AppDestination.self
                    ) { destination in
                        switch destination {
                        case .distractionHistory:
                            Text("Analytics Page coming soon...")
                        case .store:
                            Text("Store Page")
                        }
                    }
                    .fullScreenCover(
                        isPresented: .init(
                            get: { !hasSeenOnboarding },
                            set: { _ in }
                        )
                    ) {
                        OnboardingView(
                            hasSeenOnboarding: $hasSeenOnboarding,
                            service: appEnvironment.screenTimeService
                        )
                        .environment(appEnvironment)
                        .modelContainer(container)
                        .interactiveDismissDisabled()
                    }
            }
            .modelContainer(container)

            .fullScreenCover(
                item: .init(
                    get: { appEnvironment.coordinator.activeFullScreenTask },
                    set: {
                        appEnvironment.coordinator.activeFullScreenTask = $0
                    }
                )
            ) { _ in
                FrictionTaskCoordinatorView()
                    .environment(appEnvironment)
                    .modelContainer(container)
                    .interactiveDismissDisabled()
            }

            .sheet(
                item: .init(
                    get: { appEnvironment.coordinator.activeSheet },
                    set: { appEnvironment.coordinator.activeSheet = $0 }
                )
            ) { _ in
                switch appEnvironment.coordinator.activeSheet {
                case .settings:
                    SettingsSheet()
                        .environment(appEnvironment)
                case .graphSheet:
                    GraphSheetView()
                case nil:
                    EmptyView()
                }
            }

            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    checkForPendingTaks()
                    reShieldIfNeeded()
                }
            }
            .onOpenURL { _ in
                checkForPendingTaks()
            }
        }
    }

    private func checkForPendingTaks() {
        guard let defaults = UserDefaults(suiteName: "group.com.oxy.aMCCT")
        else { return }
        let needTask = defaults.bool(forKey: "aMCCT.needsFrictionTask")
        if needTask {
            defaults.set(false, forKey: "aMCCT.needsFrictionTask")
            appEnvironment.coordinator.triggerFrictionTask()
        }
    }

    private func reShieldIfNeeded() {
        guard let defaults = UserDefaults(suiteName: "group.com.oxy.aMCCT")
        else { return }
        guard defaults.bool(forKey: "aMCCT.pendingReShield") else { return }
        defaults.set(false, forKey: "aMCCT.pendingReShield")
        Task {
            let selection = SharedTokenStore().load()
            try? await appEnvironment.shieldService.applyShields(to: selection)
        }
    }
}
