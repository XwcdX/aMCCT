import Foundation
import SwiftData

@Observable
@MainActor
final class DashboardViewModel {
    var brainState: BrainState?
    var isSettingsPresented: Bool = false
    var isDecreaseConfirmPresented: Bool = false
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func load() {
        let descriptor = FetchDescriptor<BrainState>()
        if let existing = try? modelContext.fetch(descriptor).first {
            brainState = existing
        } else {
            let fresh = BrainState()
            modelContext.insert(fresh)
            try? modelContext.save()
            brainState = fresh
        }
        resetDailyCountersIfNeeded()
    }

    var brainStrength: Double {
        guard let state = brainState else { return 0.0 }
        return Double(state.actualLevel) / Double(LevelConstants.actualLevelMax)
    }

    var currentLevelFraction: Double {
        guard let state = brainState else { return 0.0 }
        return Double(state.currentLevel) / Double(LevelConstants.currentLevelMax)
    }

    var actualLevelFraction: Double {
        guard let state = brainState else { return 0.0 }
        return Double(state.actualLevel) / Double(LevelConstants.actualLevelMax)
    }

    var canDecreaseToday: Bool {
        guard let state = brainState else { return false }
        return state.dailyLevelDecreaseCount < LevelConstants.dailyDecreaseLimit
            && state.actualLevel > 1
    }

    var dailyCapsDescription: String {
        guard let state = brainState else { return "" }
        let decreasesLeft = LevelConstants.dailyDecreaseLimit - state.dailyLevelDecreaseCount
        let increaseCapRemaining = LevelConstants.dailyIncreaseLimit(actual: state.actualLevel) - state.currentLevel
        return "Decreases left today: \(max(decreasesLeft, 0))  ·  Level headroom: \(max(increaseCapRemaining, 0))"
    }

    func recordFrictionCompleted() {
        guard let state = brainState else { return }
        resetDailyCountersIfNeeded()

        let dailyCap = LevelConstants.dailyIncreaseLimit(actual: state.actualLevel)

        if state.currentLevel < dailyCap && state.currentLevel < LevelConstants.currentLevelMax {
            state.currentLevel += 1
            state.dailyLevelIncreaseCount += 1

            let gap = state.currentLevel - state.actualLevel
            if gap > LevelConstants.increaseThreshold {
                state.actualLevel = min(
                    state.currentLevel - LevelConstants.increaseThreshold,
                    LevelConstants.actualLevelMax
                )
            }
        }

        let earned = state.actualLevel
        state.totalPoints += earned
        state.spendablePoints += earned

        let today = Calendar.current.startOfDay(for: .now)
        if let last = state.lastFrictionDate,
           Calendar.current.isDate(last, inSameDayAs: today) {
            state.currentStreak += 1
        } else if let last = state.lastFrictionDate,
                  let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today),
                  Calendar.current.isDate(last, inSameDayAs: yesterday) {
            state.currentStreak += 1
        } else {
            state.currentStreak = 1
        }
        state.longestStreak = max(state.longestStreak, state.currentStreak)
        state.lastFrictionDate = .now
        state.totalFrictions += 1

        save()
    }

    func decreaseLevel() {
        guard let state = brainState, canDecreaseToday else { return }
        resetDailyCountersIfNeeded()

        state.actualLevel = max(state.actualLevel - 1, 1)
        state.currentLevel = state.actualLevel
        state.dailyLevelDecreaseCount += 1

        save()
    }

    private func applyDayReset(to state: BrainState) {
        state.currentLevel = state.actualLevel
        state.dailyLevelIncreaseCount = 0
        state.dailyLevelDecreaseCount = 0
        state.dailyCounterResetDate = Calendar.current.startOfDay(for: .now)
    }

    private func resetDailyCountersIfNeeded() {
        guard let state = brainState else { return }
        let todayStart = Calendar.current.startOfDay(for: .now)
        if state.dailyCounterResetDate < todayStart {
            applyDayReset(to: state)
            save()
        }
    }

    func debugIncrementLevel() {
        recordFrictionCompleted()
    }

    private func save() {
        try? modelContext.save()
    }
}
