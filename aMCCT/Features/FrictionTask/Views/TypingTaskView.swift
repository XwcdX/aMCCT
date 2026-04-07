import SwiftUI
import FoundationModels
import Combine

@MainActor
final class TypingFrictionManager: ObservableObject {
    @Published var prompt = ""
    @Published var input = ""
    @Published var isDone = false
    @Published var isLoading = true

    private let fallback = [
        "I am choosing distraction over discipline",
        "This scroll is stealing my real progress",
        "I finish this before I escape again"
    ]

    init() {
        prompt = fallback.randomElement()!
        Task { await generatePrompt() }
    }

    func handleInput(_ value: String) {
        let trimmed = String(value.prefix(prompt.count))
        input = trimmed
        
        guard trimmed.count == prompt.count else { return }
        guard matches(prompt, trimmed) else { return }
        
        isDone = true
    }
}

// MARK: - AI
private extension TypingFrictionManager {
    func generatePrompt() async {
        guard SystemLanguageModel.default.isAvailable else {
            finish()
            return
        }

        do {
            let session = createSession()
            let response = try await session.respond(
                to: "Output one short sentence now.",
                options: .init(maximumResponseTokens: 30)
            )

            let text = cleanResponse(response.content)
            prompt = text.isEmpty ? fallback.randomElement()! : text

        } catch {
            print("LLM Error:", error.localizedDescription)
        }

        finish()
    }

    func createSession() -> LanguageModelSession {
        let lang = Locale.current.language.languageCode?.identifier ?? "English"
        
        return LanguageModelSession(
            instructions: """
            Output ONE sentence, under 10 words.
            Language: \(lang)
            No emoji, no punctuation, no explanation.
            Make it guilt-inducing.
            """
        )
    }

    func cleanResponse(_ text: String) -> String {
        text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "\n")
            .first ?? ""
    }

    func finish() {
        input = ""
        isLoading = false
    }
}

// MARK: - Typing Logic
private extension TypingFrictionManager {
    func matches(_ target: String, _ typed: String) -> Bool {
        let t = Array(target)
        let u = Array(typed)

        for i in 0..<t.count {
            if !charMatch(t[i], u[i]) { return false }
        }
        return true
    }

    func charMatch(_ a: Character, _ b: Character) -> Bool {
        if a == b { return true }

        let map: [Character: Character] = [
            "’": "'", "‘": "'", "”": "\"", "“": "\""
        ]

        let na = map[a] ?? a
        let nb = map[b] ?? b

        if na == nb { return true }

        return String(a).precomposedStringWithCanonicalMapping ==
               String(b).precomposedStringWithCanonicalMapping
    }
}

// MARK: - Hidden Input
struct HiddenTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool

    func makeUIView(context: Context) -> UITextView {
        let v = UITextView()

        v.textColor = .clear
        v.tintColor = .clear
        v.backgroundColor = .clear

        v.autocorrectionType = .no
        v.spellCheckingType = .no
        v.smartQuotesType = .no
        v.smartDashesType = .no
        v.smartInsertDeleteType = .no
        v.autocapitalizationType = .none

        v.inputAssistantItem.leadingBarButtonGroups = []
        v.inputAssistantItem.trailingBarButtonGroups = []

        v.font = .systemFont(ofSize: 22, weight: .bold)
        v.isScrollEnabled = false
        v.textContainerInset = .zero
        v.textContainer.lineFragmentPadding = 0

        v.isSelectable = false
        v.isEditable = true

        v.delegate = context.coordinator
        return v
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }

        if isFocused && !uiView.isFirstResponder {
            DispatchQueue.main.async { uiView.becomeFirstResponder() }
        } else if !isFocused && uiView.isFirstResponder {
            DispatchQueue.main.async { uiView.resignFirstResponder() }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: HiddenTextView

        init(_ parent: HiddenTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.text = textView.text ?? ""
            }
        }

        func textView(
            _ textView: UITextView,
            editMenuForTextIn range: NSRange,
            suggestedActions: [UIMenuElement]
        ) -> UIMenu? {
            UIMenu(children: [])
        }
    }
}

// MARK: - View
struct TypingTaskView: View {
    @StateObject private var vm = TypingFrictionManager()
    @State private var focus = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("TRAIN YOUR MIND")
                .font(.title.bold())
                .foregroundColor(.secondary)

            ZStack {
                typingField
                    .opacity(vm.isLoading ? 0 : 1)
                    .allowsHitTesting(!vm.isLoading)

                if vm.isLoading {
                    VStack {
                        ProgressView()
                        Text("Generating...")
                            .font(.title2.bold())
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(minHeight: 120)
            .onChange(of: vm.isLoading) { _, loading in
                if !loading {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        focus = true
                    }
                }
            }

            if vm.isDone {
                Button("CONTINUE") {
                    print("Unlocked")
                }
                .font(.title2.bold())
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal, 40)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(), value: vm.isDone)
            }

            Spacer()
        }
        .onChange(of: vm.isDone) { _, done in
            if done {
                focus = false
            }
        }
    }

    private var typingField: some View {
        let binding = Binding(
            get: { vm.input },
            set: { vm.handleInput($0) }
        )

        return ZStack {
            Text(vm.prompt)
                .font(.title2.bold())
                .foregroundColor(.primary.opacity(0.2))
                .lineSpacing(8)
                .multilineTextAlignment(.center)

            Text(renderedText)
                .font(.title2.bold())
                .lineSpacing(8)
                .multilineTextAlignment(.center)

            HiddenTextView(text: binding, isFocused: $focus)
                .frame(width: 1, height: 1)
                .opacity(0.01)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .contentShape(Rectangle())
        .onTapGesture {
            if !vm.isDone && !vm.isLoading {
                focus = true
            }
        }
        .transaction { t in
            if vm.isDone {
                t.animation = nil
            }
        }
    }

    private var renderedText: AttributedString {
        let target = Array(vm.prompt)
        let typed = Array(vm.input)
        var result = AttributedString()

        for i in 0..<target.count {
            var char = AttributedString(String(target[i]))

            if i < typed.count {
                let ok = vm.charMatch(target[i], typed[i])
                char.foregroundColor = ok ? .primary : .red
            } else if i == typed.count && !vm.isDone {
                char.backgroundColor = .primary.opacity(0.2)
            } else {
                char.foregroundColor = .clear
            }

            result += char
        }

        return result
    }
}
