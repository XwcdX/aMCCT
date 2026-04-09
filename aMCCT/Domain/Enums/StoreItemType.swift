enum StoreItemType: String, Codable, CaseIterable, Sendable {
    case sticker
    case wallpaper
    case profileBorder

    var displayName: String {
        switch self {
        case .sticker:       return "Stickers"
        case .wallpaper:     return "wallpaper"
        case .profileBorder: return "Profile Borders"
        }
    }

    var icon: String {
        switch self {
        case .sticker:       return "face.smiling"
        case .wallpaper:     return "document"
        case .profileBorder: return "circle.dotted"
        }
    }
}
