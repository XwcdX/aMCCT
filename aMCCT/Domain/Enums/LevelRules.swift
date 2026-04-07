enum LevelRules {
    static func currentLevelMax(actual: Int) -> Int {
        actual + LevelConfig.currentLevelMaxOffset
    }

    static func dailyIncreaseLimit(actual: Int) -> Int {
        min(actual + LevelConfig.dailyIncreaseStep,
            currentLevelMax(actual: actual))
    }
}
