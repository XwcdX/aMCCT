import Foundation
import FamilyControls
import ManagedSettings

protocol ShieldServicing: Sendable {
    func applyShields(to selection: FamilyActivitySelection) async throws
    func removeShield(for token: ApplicationToken) async throws
    func removeAllShields() async throws
}
