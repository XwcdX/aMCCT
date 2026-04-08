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
