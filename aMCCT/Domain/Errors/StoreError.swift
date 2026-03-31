import Foundation

enum StoreError: LocalizedError {
    case insufficientPoints(needed: Int, have: Int)
    case alreadyPurchased
    case itemNotFound
 
    var errorDescription: String? {
        switch self {
        case .insufficientPoints(let needed, let have):
            return "Not enough points. Need \(needed), you have \(have)."
        case .alreadyPurchased:
            return "You already own this item."
        case .itemNotFound:
            return "Item could not be found."
        }
    }
}
