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
