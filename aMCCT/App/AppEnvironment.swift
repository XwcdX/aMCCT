import Foundation
import SwiftUI

@Observable final class AppEnvironment{
    let screenTimeService: any ScreenTimeServicing
    
    init(screenTimeService: any ScreenTimeServicing){
        self.screenTimeService = screenTimeService
    }
}
