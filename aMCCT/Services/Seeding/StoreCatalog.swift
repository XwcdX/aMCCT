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
    static let all: [StoreCatalogItem] = stickers + wallpaper + profileBorders

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

    // MARK: - Wallpaper (3)
    static let wallpaper: [StoreCatalogItem] = [
        .init(
            id: "wallpaper_bibi_brain",
            type: .wallpaper,
            price: 150,
            name: "Bibi Brain",
            description: "Grows with every hard choice.",
            assetName: "Wallpaper 1"
        ),
        .init(
            id: "wallpaper_bibi_activities",
            type: .wallpaper,
            price: 300,
            name: "Bibi Activities",
            description: "Built through discipline.",
            assetName: "Wallpaper 2"
        ),
        .init(
            id: "wallpaper_grit_buddies",
            type: .wallpaper,
            price: 500,
            name: "Grit Buddies",
            description: "Trained by consistency.",
            assetName: "Wallpaper 3"
        ),
        .init(
            id: "wallpaper_bibi_tired",
            type: .wallpaper,
            price: 700,
            name: "Bibi Tired",
            description: "Choose hard. Get stronger.",
            assetName: "Wallpaper 4"
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
