struct TypingTaskConfig: Sendable{
    let maxToken: Int
    let wordCount: Int
    let vocabulary: VocabularyLevel
    let structure: SentenceStructure
    let constraints: [TypingConstraint]
}
