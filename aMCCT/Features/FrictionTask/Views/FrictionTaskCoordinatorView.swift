import SwiftUI
import ManagedSettings
import SharedKit

struct FrictionTaskCoordinatorView: View {
    @State private var coordinator = FrictionTaskCoordinator()
    @State private var hasStarted = false
    @Environment(AppEnvironment.self) private var appEnvironment
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            switch coordinator.activeTask {
            case .typing:
                let brainLevel =
                    appEnvironment.dashboardViewModel.brainState?.currentLevel
                    ?? 1
                let config = TypingTaskConfig.difficulty(for: brainLevel)
                TypingTaskView(
                    viewModel: FrictionTaskViewModel(
                        config: config,
                        promptService: FoundationPromptService()
                    ), onSuccess: {
                        appEnvironment.dashboardViewModel.recordFrictionCompleted(taskType: "Typing")
                        coordinator.taskCompleted()
                        Task { await unlockAndReturn() }
                    }
                )
            case .none:
                if hasStarted {
                    ProgressView("Calibrating Friction...")
                        .onAppear { dismiss() }
                }
            }
        }
        .onAppear {
            hasStarted = true
            coordinator.startRandomTask()
        }
    }

    private func unlockAndReturn() async {
        guard let defaults = UserDefaults(suiteName: "group.com.oxy.aMCCT") else {
            print("unlockAndReturn: failed to get UserDefaults")
            return
        }

        defaults.synchronize()

        guard let tokenData = defaults.data(forKey: "aMCCT.pendingUnlockToken") else {
            print("unlockAndReturn: no pending token found")
            return
        }

        guard let target = try? JSONDecoder().decode(PendingUnlockTarget.self, from: tokenData) else {
            print("unlockAndReturn: failed to decode target, data size: \(tokenData.count)")
            return
        }

        defaults.removeObject(forKey: "aMCCT.pendingUnlockToken")
        defaults.synchronize()
        do {
            try await appEnvironment.shieldService.removeShield(for: target)
            defaults.set(true, forKey: "aMCCT.pendingReShield")
            defaults.synchronize()
            print("unlockAndReturn: shield removed successfully")
        } catch {
            print("unlockAndReturn: removeShield failed: \(error)")
        }
    }
}
