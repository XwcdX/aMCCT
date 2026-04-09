import SwiftUI

@Observable
final class FrictionTaskCoordinator {
    enum TaskType: Identifiable{
        case typing
        var id: Self { self }
    }
    
    var activeTask: TaskType?

    func startRandomTask(){
        let choice = Int.random(in: 0..<1)
        switch choice {
        case 0:
            activeTask = .typing
        default:
            break
        }
    }
    
    func taskCompleted(){
        activeTask = nil
    }
}
