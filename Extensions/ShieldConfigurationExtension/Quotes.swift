import Foundation

private let quotesDictionary: [String: [String]] = [
    "~Franz Kafka~": [
        "Productivity is being able to do things that you were never able to do before."
    ],
    "~Jocko Willink~": [
        "Discipline equals freedom.",
        "Don't expect to be motivated every day to get out there and make things happen.",
    ],
    "~Marcus Aurelius~": [
        "The obstacle in the path becomes the path.",
        "You have power over your mind - not outside events.",
    ],
    "~Jim Rohn~": [
        "Suffer the pain of discipline, or suffer the pain of regret.",
        "Discipline is the bridge between goals and accomplishment.",
    ],
    "~Hardwayyy~": [
        "You cannot escape the work. You can only delay it.",
        "The aMCC grows when you do what you don't want to do.",
    ],
]

func getQuotes() -> [String] {
    guard let (author, quotes) = quotesDictionary.randomElement(),
        let quote = quotes.randomElement()
    else {
        return []
    }
    return [author, quote]
}
