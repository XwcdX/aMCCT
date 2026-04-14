import Foundation

public struct PendingUnlockTarget: Codable, Sendable {
    public enum TargetType: String, Codable, Sendable {
        case app
        case category
        case webDomain
    }
    
    public let type: TargetType
    public let tokenData: Data
    
    public init(type: TargetType, tokenData: Data) {
        self.type = type
        self.tokenData = tokenData
    }
}
