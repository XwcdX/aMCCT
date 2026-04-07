import Foundation

struct StoreCatalogItem {
    let id: String
    let type: StoreItemType
    let price: Int
    let name: String
    let description: String
    let assetName: String
}

enum StoreCatalog {
    static let all: [StoreCatalogItem] = stickers + brainSkins + profileBorders

    // MARK: - Stickers (3)
    static let stickers: [StoreCatalogItem] = [
        .init(
            id: "sticker_spark",
            type: .sticker,
            price: 50,
            name: "Spark",
            description: "A small flame — for every friction that lit something up.",
            assetName: "sticker_spark"
        ),
        .init(
            id: "sticker_iron",
            type: .sticker,
            price: 120,
            name: "Iron Mind",
            description: "Forged through resistance. Wear it with intent.",
            assetName: "sticker_iron"
        ),
        .init(
            id: "sticker_ghost",
            type: .sticker,
            price: 200,
            name: "Ghost Mode",
            description: "You were bored. You chose not to scroll. Nobody saw it. You did.",
            assetName: "sticker_ghost"
        )
    ]

    // MARK: - Brain Skins (3)
    static let brainSkins: [StoreCatalogItem] = [
        .init(
            id: "skin_crystal",
            type: .brainSkin,
            price: 150,
            name: "Crystal",
            description: "Cold, clear, unshakeable.",
            assetName: "skin_crystal"
        ),
        .init(
            id: "skin_ember",
            type: .brainSkin,
            price: 300,
            name: "Ember",
            description: "Burning slow. The kind of fire that doesn't go out.",
            assetName: "skin_ember"
        ),
        .init(
            id: "skin_void",
            type: .brainSkin,
            price: 500,
            name: "Void",
            description: "Beyond distraction. Beyond noise. Just signal.",
            assetName: "skin_void"
        )
    ]

    // MARK: - Profile Borders (3)
    static let profileBorders: [StoreCatalogItem] = [
        .init(
            id: "border_pulse",
            type: .profileBorder,
            price: 80,
            name: "Pulse",
            description: "A quiet rhythm. Still going.",
            assetName: "border_pulse"
        ),
        .init(
            id: "border_arc",
            type: .profileBorder,
            price: 180,
            name: "Arc",
            description: "Every streak leaves a mark.",
            assetName: "border_arc"
        ),
        .init(
            id: "border_crown",
            type: .profileBorder,
            price: 400,
            name: "Crown",
            description: "Reserved for those who showed up.",
            assetName: "border_crown"
        )
    ]
}
