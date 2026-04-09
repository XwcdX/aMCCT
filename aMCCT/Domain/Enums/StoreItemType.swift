enum StoreItemType: String, Codable, CaseIterable, Sendable {
    case sticker
    case wallpaper
    case profileBorder

    var displayName: String {
        switch self {
        case .sticker:       return "Stickers"
        case .wallpaper:     return "Wallpapers"
        case .profileBorder: return "Borders"
        }
    }

    var icon: String {
        switch self {
        case .sticker:       return "face.smiling"
        case .wallpaper:     return "photo"
        case .profileBorder: return "person.crop.circle.badge.checkmark"
        }
    }
}
