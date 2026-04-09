import Foundation
import FamilyControls
import ManagedSettings
import SharedKit

protocol ShieldServicing: Sendable {
    func applyShields(to selection: FamilyActivitySelection) async throws
    func removeShield(for target: PendingUnlockTarget) async throws
    func removeAllShields() async throws
}
