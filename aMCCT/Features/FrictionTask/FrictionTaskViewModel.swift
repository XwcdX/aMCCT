import SwiftUI
import Combine

@MainActor
final class FrictionTaskViewModel: ObservableObject {
    var isBackspaceDisabled: Bool {
        taskConfig.constraints.contains(.noBackspace)
    }
    
    @Published var isTaskComplete = false
    @Published var isLoading = true
    
    @Published var targetPhrase = ""
    @Published var currentTextEntry = ""
    
    private let taskConfig: TypingTaskConfig
    private let promptService: PromptGenerationServicing
    private let fallbackPhrase = "I am choosing distraction over discipline"
    
    init(config: TypingTaskConfig, promptService: PromptGenerationServicing) {
        self.taskConfig = config
        self.promptService = promptService
        
        Task { await fetchChallengePhrase() }
    }
    
    private func fetchChallengePhrase() async {
        isLoading = true
        do {
            let generatedText = try await promptService.generatePrompt(config: taskConfig)
            self.targetPhrase = generatedText.isEmpty ? fallbackPhrase : generatedText
        } catch {
            print("AI Prompt Error: \(error.localizedDescription)")
            self.targetPhrase = fallbackPhrase
        }
        isLoading = false
    }
    
    // MARK: - Typing Logic
    /// Processes text changes
    func handleTypingInput(_ newValue: String) {
        if taskConfig.constraints.contains(.noBackspace) {
            if newValue.count < currentTextEntry.count {
                return
            }
        }
        
        self.currentTextEntry = newValue
        
        if newValue.count == targetPhrase.count {
            if validateFullMatch(targetPhrase, newValue) {
                isTaskComplete = true
            } else {
                handleTypingFailure()
            }
        }
    }

    private func handleTypingFailure() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut) {
                self.currentTextEntry = ""
            }
        }
    }
    
    /// Compares two characters based on task configuration
    func compareCharacters(_ target: Character, _ typed: Character) -> Bool {
        if target == typed { return true }
        
        let punctuationMap: [Character: Character] = ["’": "'", "‘": "'", "”": "\"", "“": "\""]
        let normalizedTarget = punctuationMap[target] ?? target
        let normalizedTyped = punctuationMap[typed] ?? typed
        
        if normalizedTarget == normalizedTyped { return true }
        
        if taskConfig.constraints.contains(.caseSensitive) {
            return String(normalizedTarget) == String(normalizedTyped)
        } else {
            return String(normalizedTarget).lowercased() == String(normalizedTyped).lowercased()
        }
    }
}

// MARK: - Private Helpers
private extension FrictionTaskViewModel {
    func validateFullMatch(_ target: String, _ typed: String) -> Bool {
        let targetArray = Array(target)
        let typedArray = Array(typed)
        
        guard targetArray.count == typedArray.count else { return false }
        
        for i in 0..<targetArray.count {
            if !compareCharacters(targetArray[i], typedArray[i]) {
                return false
            }
        }
        return true
    }
}
