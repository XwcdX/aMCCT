struct TypingTaskConfig: Sendable {
    let maxToken: Int
    let wordCount: Int
    let vocabulary: VocabularyLevel
    let structure: SentenceStructure
    let constraints: [TypingConstraint]
}

extension TypingTaskConfig {
    static func difficulty(for level: Int) -> TypingTaskConfig {
        let wordCount = 10 + (level / 10)
        let vocabulary: VocabularyLevel = {
            switch level {
            case 1...15:
                return .basic
            case 16...35:
                return .intermediate
            case 36...55:
                return .advanced
            case 56...75:
                return .expert
            case 76...90:
                return .master
            default:
                return .technical
            }
        }()

        let structure: SentenceStructure = {
            switch level {
            case 1...25:
                return .shortPhrase
            case 26...50:
                return .simpleSentence
            case 51...75:
                return .compoundSentence
            default:
                return .complexSentence
            }
        }()

        var activeConstraints: [TypingConstraint] = []
        if level >= 30 { activeConstraints.append(.caseSensitive) }
        if level >= 50 { activeConstraints.append(.punctuationRequired) }
        if level >= 75 { activeConstraints.append(.noBackspace) }
        
        return TypingTaskConfig(
            maxToken: 8 * wordCount,
            wordCount: wordCount,
            vocabulary: vocabulary,
            structure: structure,
            constraints: activeConstraints
        )
    }
}
