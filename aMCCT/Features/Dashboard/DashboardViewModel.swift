import Foundation
import SwiftData

@Observable
@MainActor
final class DashboardViewModel {
    var brainState: BrainState?
    var totalFrictionsCount: Int = 0
    var isSettingsPresented: Bool = false
    var isDecreaseConfirmPresented: Bool = false
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func load() {
        brainState = loadOrCreateBrainState()
        totalFrictionsCount = fetchFrictionEventsCount()
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
        let absoluteMax = Double(LevelConfig.actualLevelMax + LevelConfig.increaseThreshold + 1)
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
        let increasesLeft = LevelConfig.dailyIncreaseStep - state.dailyLevelIncreaseCount

        return "Decreases left today: \(max(decreasesLeft, 0))  ·  Actual increases left today: \(max(increasesLeft, 0))"
    }
    
    /// Called when any friction task (Typing, Hold, etc.) is finished.
    func recordFrictionCompleted(appTokenData: Data? = nil, taskType: String = "typing") {
        guard let state = brainState else { return }
        resetDailyCountersIfNeeded()

        let canIncreaseActualToday =
            state.dailyLevelIncreaseCount < LevelConfig.dailyIncreaseStep
        let maxCurrentAllowed = currentLevelMax(
            actual: state.actualLevel,
            canIncreaseActualToday: canIncreaseActualToday
        )

        if state.currentLevel < maxCurrentAllowed {
            state.currentLevel += 1

            let gap = state.currentLevel - state.actualLevel

            if gap > LevelConfig.increaseThreshold && canIncreaseActualToday {
                state.actualLevel = min(state.actualLevel + 1, LevelConfig.actualLevelMax)
                state.dailyLevelIncreaseCount += 1
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
        totalFrictionsCount += 1

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
        _ = loadOrCreateBrainState()
        recordFrictionCompleted(taskType: "debug")
    }

    func resetSwiftData() {
        do {
            let brainStates = try modelContext.fetch(FetchDescriptor<BrainState>())
            brainStates.forEach(modelContext.delete)

            let storeItems = try modelContext.fetch(FetchDescriptor<StoreItem>())
            storeItems.forEach(modelContext.delete)

            let shieldUnlockRecords = try modelContext.fetch(FetchDescriptor<ShieldUnlockRecord>())
            shieldUnlockRecords.forEach(modelContext.delete)

            let frictionEvents = try modelContext.fetch(FetchDescriptor<FrictionEvent>())
            frictionEvents.forEach(modelContext.delete)

            try modelContext.save()

            brainState = nil
            totalFrictionsCount = 0
            StoreSeeder.seed(context: modelContext)
            brainState = loadOrCreateBrainState()
        } catch {
            print("💾 SwiftData Error: Failed to reset store: \(error.localizedDescription)")
        }
    }

    private func currentLevelMax(actual: Int, canIncreaseActualToday: Bool) -> Int {
        let trailingBuffer = canIncreaseActualToday ? 1 : 0
        return actual + LevelConfig.increaseThreshold + trailingBuffer
    }

    private func fetchFrictionEventsCount() -> Int {
        let descriptor = FetchDescriptor<FrictionEvent>()
        return (try? modelContext.fetchCount(descriptor)) ?? 0
    }

    private func save() {
        do {
            try modelContext.save()
            print("💾 BrainState saved: actualLevel=\(brainState?.actualLevel ?? -1), currentLevel=\(brainState?.currentLevel ?? -1), points=\(brainState?.points ?? -1), dailyIncreases=\(brainState?.dailyLevelIncreaseCount ?? -1), dailyDecreases=\(brainState?.dailyLevelDecreaseCount ?? -1)")
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

