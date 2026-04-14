struct LevelConfig {
    static let increaseThreshold: Int = 3 // ketika (current - actual) > increaseThreshold, actual level naik 1
    static let actualLevelMax: Int = 100 // actual level maksimal 100
    // sesuai rule di atas, current level maksimal adalah 100 + increaseThreshold + 1 = 104
    // semisal actual sudah 100, current maksimal 104 lalu stop

    static let dailyIncreaseStep: Int = 10 // maksimal dari actual level nambah, maksimal nambah +10 per hari
    static let dailyDecreaseLimit: Int = 2 // maksimal dari actual level turun, maksimal turun -2 per hari
}
