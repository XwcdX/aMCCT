import Foundation
import ManagedSettings

// Override the functions below to customize the shield actions used in various situations.
// The system provides a default response for any functions that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldActionExtension: ShieldActionDelegate {
    private let appGroupID = "group.com.oxy.aMCCT"

    override func handle(
        action: ShieldAction,
        for application: ApplicationToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        handleAction(
            action,
            tokenData: try? JSONEncoder().encode(application),
            completionHandler: completionHandler
        )
    }

    override func handle(
        action: ShieldAction,
        for webDomain: WebDomainToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        handleAction(
            action,
            tokenData: try? JSONEncoder().encode(webDomain),
            completionHandler: completionHandler
        )
    }

    override func handle(
        action: ShieldAction,
        for category: ActivityCategoryToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        handleAction(
            action,
            tokenData: try? JSONEncoder().encode(category),
            completionHandler: completionHandler
        )
    }

    private func handleAction(
        _ action: ShieldAction,
        tokenData: Data?,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        switch action {
        case .primaryButtonPressed:
            if let defaults = UserDefaults(suiteName: appGroupID) {
                defaults.set(true, forKey: "aMCCT.needsFrictionTask")
                if let data = tokenData {
                    defaults.set(data, forKey: "aMCCT.pendingUnlockToken")
                }
            }
            completionHandler(.close)
        case .secondaryButtonPressed:
            completionHandler(.close)
        case .firstSecondarySubmenuItemPressed:
            completionHandler(.defer)
        case .secondSecondarySubmenuItemPressed:
            completionHandler(.defer)
        case .thirdSecondarySubmenuItemPressed:
            completionHandler(.defer)
        @unknown default:
            completionHandler(.defer)
        }
    }
}
