import Foundation
import FamilyControls
import SharedKit
import DeviceActivity

struct ScreenTimeService: ScreenTimeServicing {
    func requestAuthorization() async throws {
        let center = AuthorizationCenter.shared
        try await center.requestAuthorization(for: .individual)
    }
    
    func startMonitoring() async throws {
        let center = DeviceActivityCenter()
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        let selection = SharedTokenStore().load()
        
        let events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [
            .reShieldThreshold: DeviceActivityEvent(
                applications: selection.applicationTokens,
                categories: selection.categoryTokens,
                threshold: DateComponents(minute: 6),
                includesPastActivity: false
            )
        ]
        
        try center.startMonitoring(.reShieldCheck, during: schedule, events: events)
        print("startMonitoring: started tracking \(selection.applicationTokens.count) apps, \(selection.categoryTokens.count) categories")
    }
}
