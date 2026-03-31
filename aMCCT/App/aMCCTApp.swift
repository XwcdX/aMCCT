import SwiftUI

@main
struct aMCCTApp: App {
    @State private var environment = AppEnvironment()
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(environment)
        }
    }
}
