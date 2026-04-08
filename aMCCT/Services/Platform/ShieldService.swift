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
            store.shield.applicationCategories = .specific(
                selection.categoryTokens
            )
        }

        let preventDelete = tokenStore.loadDeletionContext()
        store.application.denyAppRemoval = preventDelete

        print("🛡️ Shields synced correctly.")
    }

    func removeShield(for token: ApplicationToken) async throws {
        if var currentApps = store.shield.applications {
            currentApps.remove(token)
            store.shield.applications = currentApps.isEmpty ? nil : currentApps
        }
    }

    func removeAllShields() async throws {
        store.clearAllSettings()
    }
}
