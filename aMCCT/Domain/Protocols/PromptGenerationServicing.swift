import Foundation

protocol PromptGenerationServicing: Sendable {
    func generatePrompt(config: TypingTaskConfig) async throws -> String
}
