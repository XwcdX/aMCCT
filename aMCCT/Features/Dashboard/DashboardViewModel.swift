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
        brainState = loadOrCreateBrainState()
        StoreSeeder.seed(context: modelContext)
        resetDailyCountersIfNeeded()
    }

    func purchaseItem(_ item: StoreItem) {
        let state = loadOrCreateBrainState()
        guard !item.isPurchased else { return }
        guard state.points >= item.price else { return }
        state.points -= item.price
        item.isPurchased = true
        item.purchasedAt = .now
        save()
    }

    func purchaseCatalogItem(_ catalogItem: StoreCatalogItem) {
        let existingItem = (try? modelContext.fetch(FetchDescriptor<StoreItem>()))?.first {
            $0.id == catalogItem.id
        }

        if let existingItem {
            purchaseItem(existingItem)
            return
        }

        let item = StoreItem(
            id: catalogItem.id,
            type: catalogItem.type,
            price: catalogItem.price,
            name: catalogItem.name,
            description: catalogItem.description,
            assetName: catalogItem.assetName
        )
        modelContext.insert(item)
        try? modelContext.save()
        purchaseItem(item)
    }

    
    /// Returns the total number of friction tasks successfully completed.
    var totalFrictionsCount: Int {
        let descriptor = FetchDescriptor<FrictionEvent>()
        return (try? modelContext.fetchCount(descriptor)) ?? 0
    }

    /// Finds the App Token that the user attempts to open most frequently.
    var culpritToken: Data? {
        let descriptor = FetchDescriptor<FrictionEvent>()
        guard let events = try? modelContext.fetch(descriptor) else { return nil }
        
        var frequencies: [Data: Int] = [:]
        for event in events {
            if let token = event.appTokenData {
                frequencies[token, default: 0] += 1
            }
        }
        
        return frequencies.max(by: { $0.value < $1.value })?.key
    }

    /// Brain level on a 1–100 scale for UI components like BrainSceneView.
    var brainLevel: Int {
        guard let state = brainState else { return 1 }
        let fraction = Double(state.actualLevel) / Double(LevelConfig.actualLevelMax)
        return max(1, min(100, Int((fraction * 100.0).rounded())))
    }

    var currentLevelFraction: Double {
        guard let state = brainState else { return 0.0 }
        let absoluteMax = Double(LevelConfig.actualLevelMax + LevelConfig.currentLevelMaxOffset)
        return Double(state.currentLevel) / absoluteMax
    }

    var actualLevelFraction: Double {
        guard let state = brainState else { return 0.0 }
        return Double(state.actualLevel) / Double(LevelConfig.actualLevelMax)
    }

    var canDecreaseToday: Bool {
        guard let state = brainState else { return false }
        return state.dailyLevelDecreaseCount < LevelConfig.dailyDecreaseLimit
            && state.actualLevel > 1
    }

    var dailyCapsDescription: String {
        guard let state = brainState else { return "" }
        let decreasesLeft = LevelConfig.dailyDecreaseLimit - state.dailyLevelDecreaseCount
        
        let maxAllowedToday = LevelRules.dailyIncreaseLimit(actual: state.actualLevel)
        let increaseCapRemaining = maxAllowedToday - state.currentLevel
        
        return "Decreases left today: \(max(decreasesLeft, 0))  ·  Level headroom: \(max(increaseCapRemaining, 0))"
    }
    
    /// Called when any friction task (Typing, Hold, etc.) is finished.
    func recordFrictionCompleted(appTokenData: Data? = nil, taskType: String = "typing") {
        guard let state = brainState else { return }
        resetDailyCountersIfNeeded()

        let dailyCap = LevelRules.dailyIncreaseLimit(actual: state.actualLevel)
        let maxCurrentAllowed = LevelRules.currentLevelMax(actual: state.actualLevel)

        if state.currentLevel < dailyCap && state.currentLevel < maxCurrentAllowed {
            state.currentLevel += 1
            state.dailyLevelIncreaseCount += 1

            let gap = state.currentLevel - state.actualLevel
            if gap > LevelConfig.increaseThreshold {
                state.actualLevel = min(
                    state.currentLevel - LevelConfig.increaseThreshold,
                    LevelConfig.actualLevelMax
                )
            }
        }

        let earned = state.actualLevel
        state.points += earned
        
        let event = FrictionEvent(
            appTokenData: appTokenData,
            pointsEarned: earned,
            taskType: taskType
        )
        modelContext.insert(event)

        save()
    }

    /// Manually lower the difficulty (costs progress, limited per day)
    func decreaseLevel() {
        guard let state = brainState, canDecreaseToday else { return }
        resetDailyCountersIfNeeded()

        state.actualLevel = max(state.actualLevel - 1, 1)
        state.currentLevel = state.actualLevel
        state.dailyLevelDecreaseCount += 1

        save()
    }
    
    private func resetDailyCountersIfNeeded() {
        guard let state = brainState else { return }
        let todayStart = Calendar.current.startOfDay(for: .now)
        
        if state.dailyCounterResetDate < todayStart {
            applyDayReset(to: state)
            save()
        }
    }

    private func applyDayReset(to state: BrainState) {
        state.currentLevel = state.actualLevel
        state.dailyLevelIncreaseCount = 0
        state.dailyLevelDecreaseCount = 0
        state.dailyCounterResetDate = Calendar.current.startOfDay(for: .now)
    }
    
    func debugIncrementLevel() {
        recordFrictionCompleted(taskType: "debug")
    }

    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("💾 SwiftData Error: Failed to save context: \(error.localizedDescription)")
        }
    }

    private func loadOrCreateBrainState() -> BrainState {
        if let brainState {
            return brainState
        }

        let descriptor = FetchDescriptor<BrainState>()
        if let existing = try? modelContext.fetch(descriptor).first {
            brainState = existing
            return existing
        }

        let fresh = BrainState()
        modelContext.insert(fresh)
        try? modelContext.save()
        brainState = fresh
        return fresh
    }
}

