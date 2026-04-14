import FamilyControls
import Foundation
import ManagedSettings
import SharedKit

final class ShieldService: ShieldServicing {

    private let store = ManagedSettingsStore()
    private let tokenStore = SharedTokenStore()

    init() {}

    func applyShields(to selection: FamilyActivitySelection) async throws {
        store.shield.applications = nil
        store.shield.applicationCategories = nil

        if !selection.applicationTokens.isEmpty {
            store.shield.applications = selection.applicationTokens
        }

        if !selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
        }

        let preventDelete = tokenStore.loadDeletionContext()
        store.application.denyAppRemoval = preventDelete

        print("Shields applied — apps: \(selection.applicationTokens.count), categories: \(selection.categoryTokens.count)")
    }

    func removeShield(for target: PendingUnlockTarget) async throws {
        var selection = tokenStore.load()

        switch target.type {
        case .app:
            if let token = try? JSONDecoder().decode(ApplicationToken.self, from: target.tokenData) {
                selection.applicationTokens.remove(token)
                store.shield.applications = selection.applicationTokens.isEmpty
                    ? nil : selection.applicationTokens
            }

        case .category:
            if let token = try? JSONDecoder().decode(ActivityCategoryToken.self, from: target.tokenData) {
                selection.categoryTokens.remove(token)
                store.shield.applicationCategories = selection.categoryTokens.isEmpty
                    ? nil : .specific(selection.categoryTokens)
            }

        case .webDomain:
            if let token = try? JSONDecoder().decode(WebDomainToken.self, from: target.tokenData) {
                selection.webDomainTokens.remove(token)
                store.shield.webDomains = selection.webDomainTokens.isEmpty
                    ? nil : selection.webDomainTokens
            }
        }

        try tokenStore.save(selection)
    }

    func removeAllShields() async throws {
        store.clearAllSettings()
    }
}
