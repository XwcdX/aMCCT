import Foundation
import SwiftData

@Model final class StoreItem {
    var id: String
    var type: StoreItemType
    var price: Int
    var isPurchased: Bool
    var isEquipped: Bool
    var purchasedAt: Date?

    init(id: String, type: StoreItemType, price: Int) {
        self.id          = id
        self.type        = type
        self.price       = price
        self.isPurchased = false
        self.isEquipped  = false
        self.purchasedAt = nil
    }
}

enum StoreItemType: String, Codable, CaseIterable, Sendable {
    case sticker
    case brainSkin
    case profileBorder

    var displayName: String {
        switch self {
        case .sticker:       return "Sticker"
        case .brainSkin:     return "Brain Skin"
        case .profileBorder: return "Profile Border"
        }
    }

    var slotIsExclusive: Bool {
        return true
    }
}
