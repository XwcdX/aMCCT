enum SentenceStructure: Sendable {
    case shortPhrase
    case simpleSentence
    case compoundSentence
    case complexSentence
    
    var promptInstruction: String {
        switch self {
        case .shortPhrase: return "Write a short phrase, no verbs required."
        case .simpleSentence: return "Write one simple sentence."
        case .compoundSentence: return "Write a compound sentence using a conjunction like 'and' or 'but'."
        case .complexSentence: return "Write a complex sentence with an independent and dependent clause."
        }
    }
}

enum TypingConstraint: Sendable {
    case none
    case caseSensitive
    case punctuationRequired
    case noBackspace
}

enum VocabularyLevel: Sendable {
    case basic, intermediate, advanced, expert, master, technical
    
    var promptInstruction: String {
        switch self {
        case .basic: return "Use elementary school level, extremely simple words."
        case .intermediate: return "Use everyday conversational words."
        case .advanced: return "Use sophisticated, high-school level vocabulary."
        case .expert: return "Use obscure, highly articulate SAT-level words."
        case .master: return "Use archaic or highly intellectual academic words."
        case .technical: return "Use technical jargon related to neuroscience or productivity."
        }
    }
}
