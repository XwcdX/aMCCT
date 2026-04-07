import SwiftUI
import SwiftData

@main
struct aMCCTApp: App {
    let container: ModelContainer
    @State private var appEnvironment: AppEnvironment
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    init() {
        do {
            let container = try ModelContainer(for: BrainState.self, StoreItem.self, ShieldUnlockRecord.self)
            self.container = container
            self._appEnvironment = State(initialValue: AppEnvironment(modelContext: container.mainContext))
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
//            TypingTaskView(
//                            viewModel: FrictionTaskViewModel(
//                                config: TypingTaskConfig(
//                                    maxToken: 40,
//                                    wordCount: 8,
//                                    vocabulary: .advanced,
//                                    structure: .simpleSentence,
//                                    constraints: [.punctuationRequired]
//                                ),
//                                promptService: FoundationPromptService()
//                            )
//                        )
//            .modelContainer(container)
            
            DashboardView()
                .environment(appEnvironment.dashboardViewModel)
                .modelContainer(container)
                .fullScreenCover(isPresented: .init(
                    get: { !hasSeenOnboarding },
                    set: { _ in }
                )) {
                    OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                        .interactiveDismissDisabled()
                }
        }
    }
}
