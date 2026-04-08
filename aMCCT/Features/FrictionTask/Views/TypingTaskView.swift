import SwiftUI

struct TypingTaskView: View {
    @ObservedObject var viewModel: FrictionTaskViewModel
    @State private var isFieldFocused = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            headerSection
            
            ZStack {
                if viewModel.isLoading {
                    loadingState
                } else {
                    typingArea
                }
            }
            .frame(minHeight: 150)
            
            Spacer()
            
            if viewModel.isTaskComplete {
                continueButton
            }
        }
        .padding(.horizontal, 24)
        .onAppear { setupInitialState() }
        .onChange(of: viewModel.isLoading) { _, loading in
            handleLoadingChange(loading)
        }
        .onChange(of: viewModel.isTaskComplete) { _, complete in
            if complete { isFieldFocused = false }
        }
    }
}

// MARK: - View Components
private extension TypingTaskView {
    
    var headerSection: some View {
        VStack(spacing: 8) {
            Text("TRAIN YOUR MIND")
                .font(.caption.bold())
                .tracking(2)
                .foregroundColor(.secondary)
            
            Text("Focus on every character")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.8))
        }
    }

    var typingArea: some View {
        let textBinding = Binding(
            get: { viewModel.currentTextEntry },
            set: { viewModel.handleTypingInput($0) }
        )

        return ZStack {
            Text(viewModel.targetPhrase)
                .font(.title2.bold())
                .lineSpacing(8)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary.opacity(0.1))

            Text(renderedProgressString)
                .font(.title2.bold())
                .lineSpacing(8)
                .multilineTextAlignment(.center)

            HiddenText(
                text: textBinding,
                isFocused: $isFieldFocused,
                maxLength: viewModel.targetPhrase.count,
                disableBackspace: viewModel.isBackspaceDisabled
            )
            .frame(width: 1, height: 1)
            .opacity(0.01)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !viewModel.isTaskComplete && !viewModel.isLoading {
                isFieldFocused = true
            }
        }
    }

    var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("AI is generating friction...")
                .font(.callout)
                .foregroundColor(.secondary)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }

    var continueButton: some View {
        Button(action: {
            print("Action: Task complete, unlocking app.")
        }) {
            Text("CONTINUE")
                .font(.headline.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                .cornerRadius(14)
                .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
        }
        .padding(.bottom, 20)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// MARK: - Text Rendering Logic
private extension TypingTaskView {
    var renderedProgressString: AttributedString {
        let targetChars = Array(viewModel.targetPhrase)
        let typedChars = Array(viewModel.currentTextEntry)
        var result = AttributedString()

        for i in 0..<targetChars.count {
            var char = AttributedString(String(targetChars[i]))

            if i < typedChars.count {
                let isMatch = viewModel.compareCharacters(targetChars[i], typedChars[i])
                char.foregroundColor = isMatch ? .primary : .red
            } else if i == typedChars.count && !viewModel.isTaskComplete {
                char.backgroundColor = .primary.opacity(0.15)
                char.foregroundColor = .primary.opacity(0.3)
            } else {
                char.foregroundColor = .clear
            }
            result += char
        }
        return result
    }
}

// MARK: - Lifecycle Helpers
private extension TypingTaskView {
    func setupInitialState() {
        if !viewModel.isLoading {
            isFieldFocused = true
        }
    }
    
    func handleLoadingChange(_ loading: Bool) {
        if !loading {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation { isFieldFocused = true }
            }
        }
    }
}
