import Foundation
import FamilyControls

public struct SharedTokenStore: @unchecked Sendable {
    private let defaults: UserDefaults

    public static let appGroupID = "group.com.oxy.aMCCT"
    public static let selectedTokensKey = "aMCCT.selectedTokens"

    public init() {
        self.defaults = UserDefaults(suiteName: SharedTokenStore.appGroupID) ?? UserDefaults.standard
    }

    public func save(_ selection: FamilyActivitySelection) throws {
        let data = try PropertyListEncoder().encode(selection)
        defaults.set(data, forKey: SharedTokenStore.selectedTokensKey)
    }

    public func load() -> FamilyActivitySelection {
        guard let data = defaults.data(forKey: SharedTokenStore.selectedTokensKey),
              let selection = try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data) else {
            return FamilyActivitySelection()
        }
        return selection
    }
}
