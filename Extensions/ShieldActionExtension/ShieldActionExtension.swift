import Foundation
import ManagedSettings
import UserNotifications
import SharedKit

class ShieldActionExtension: ShieldActionDelegate {
    private let appGroupID = "group.com.oxy.aMCCT"

    override func handle(
        action: ShieldAction,
        for application: ApplicationToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        handleAction(
            action,
            type: .app,
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
            type: .webDomain,
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
            type: .category,
            tokenData: try? JSONEncoder().encode(category),
            completionHandler: completionHandler
        )
    }

    private func handleAction(
        _ action: ShieldAction,
        type: PendingUnlockTarget.TargetType,
        tokenData: Data?,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        switch action {
        case .primaryButtonPressed:
            if let defaults = UserDefaults(suiteName: appGroupID),
               let tokenData,
               let data = try? JSONEncoder().encode(PendingUnlockTarget(type: type, tokenData: tokenData)) {
                defaults.set(true, forKey: "aMCCT.needsFrictionTask")
                defaults.set(data, forKey: "aMCCT.pendingUnlockToken")
                defaults.synchronize()
            }
            sendTaskNotification()
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
    
    private func sendTaskNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Complete Your Task"
        content.body = "Tap to open aMCCT and earn access."
        content.sound = .default
        content.categoryIdentifier = "FRICTION_TASK"
        
        let request = UNNotificationRequest(identifier: "friction-task-\(UUID().uuidString)", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
