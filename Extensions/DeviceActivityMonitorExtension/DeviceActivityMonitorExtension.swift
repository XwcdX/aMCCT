import DeviceActivity
internal import FamilyControls
import ManagedSettings
import SharedKit
import UserNotifications

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    let store = ManagedSettingsStore()
    let tokenStore = SharedTokenStore()

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
    }

    override func eventDidReachThreshold(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        super.eventDidReachThreshold(event, activity: activity)
        if event == .reShieldThreshold {
            reApplyAllShields()
        }
    }

    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
    }

    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
    }

    override func eventWillReachThresholdWarning(
        _ event: DeviceActivityEvent.Name,
        activity: DeviceActivityName
    ) {
        super.eventWillReachThresholdWarning(event, activity: activity)
        if event == .reShieldThreshold {
            sendWarningNotification()
        }
    }

    private func reApplyAllShields() {
        let selection = tokenStore.load()

        store.shield.applications = nil
        store.shield.applicationCategories = nil

        if !selection.applicationTokens.isEmpty {
            store.shield.applications = selection.applicationTokens
        }
        if !selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = .specific(
                selection.categoryTokens
            )
        }

        if let defaults = UserDefaults(suiteName: "group.com.oxylion.aMCCT") {
            defaults.set(true, forKey: "aMCCT.pendingReShield")
            defaults.synchronize()
        }

        print("DeviceActivityMonitor: shields restored")
    }

    private func sendWarningNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Shield Reactivating Soon"
        content.body = "Your shields will be restored in 5 minutes."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "shield-warning",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
