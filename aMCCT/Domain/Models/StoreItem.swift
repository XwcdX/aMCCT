import Foundation
import SwiftData

@Model final class StoreItem {
    var id: String
    var type: StoreItemType
    var name: String
    var itemDescription: String
    var assetName: String
    var price: Int
    var isPurchased: Bool
    var purchasedAt: Date?

    init(
        id: String,
        type: StoreItemType,
        price: Int,
        name: String,
        description: String,
        assetName: String
    ) {
        self.id              = id
        self.type            = type
        self.price           = price
        self.name            = name
        self.itemDescription = description
        self.assetName       = assetName
        self.isPurchased     = false
        self.purchasedAt     = nil
    }
}

enum StoreItemType: String, Codable, CaseIterable, Sendable {
    case sticker
    case brainSkin
    case profileBorder

    var displayName: String {
        switch self {
        case .sticker:       return "Stickers"
        case .brainSkin:     return "Brain Skins"
        case .profileBorder: return "Profile Borders"
        }
    }

    var icon: String {
        switch self {
        case .sticker:       return "face.smiling"
        case .brainSkin:     return "cube.transparent"
        case .profileBorder: return "circle.dotted"
        }
    }
}
