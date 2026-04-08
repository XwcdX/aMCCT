import Foundation
import FoundationModels

final class FoundationPromptService: PromptGenerationServicing {
    
    init() {}
    
    func generatePrompt(config: TypingTaskConfig) async throws -> String {
        guard SystemLanguageModel.default.isAvailable else {
            throw AppError.aiUnavailable
        }
        
        let lang = Locale.current.language.languageCode?.identifier ?? "English"
        
        let instructions = """
        Language: \(lang)
        Word count constraint: Exactly \(config.wordCount) words.
        Structure: \(config.structure.promptInstruction)
        Vocabulary: \(config.vocabulary.promptInstruction)
        Tone: Firm, disciplined, and direct.
        Content: Write a sentence about choosing deep work over digital distraction. 
        Constraint: No emoji, no punctuation, no explanations. Output only the requested text.
        """
        
        let session = LanguageModelSession(instructions: instructions)
        
        let response = try await session.respond(
            to: "Output the text now.",
            options: .init(maximumResponseTokens: config.maxToken)
        )
        
        return cleanResponse(response.content, config: config)
    }
    
    private func cleanResponse(_ text: String, config: TypingTaskConfig) -> String {
        var clean = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "\n")
            .first ?? ""
        
        if !config.constraints.contains(.punctuationRequired) {
            clean = clean.replacingOccurrences(of: "[.,!?]", with: "", options: .regularExpression)
        }
        
        return clean.replacingOccurrences(of: "  ", with: " ").trimmingCharacters(in: .whitespaces)
    }
}
