import SwiftUI
import SwiftData

struct TypingTaskView: View {
    @ObservedObject var viewModel: FrictionTaskViewModel
    @State private var isFieldFocused = false
    @State private var wallpaperIndex = Int.random(in: 1...4)
    
    @Query private var brainStates: [BrainState]
    
    private var currentLevel: Int {
        brainStates.first?.currentLevel ?? 1
    }

    var body: some View {
        FrictionCard(
            title: "TRAIN YOUR MIND",
            progress: viewModel.targetPhrase.isEmpty ? 0.0 : Double(viewModel.currentTextEntry.count) / Double(viewModel.targetPhrase.count),
            currentLevel: currentLevel,
            backgroundImageName: "Wallpaper-\(wallpaperIndex)",
            onCancel: {
                exit(0)
            }
        ) {
            VStack(spacing: 40) {
                Spacer()

                Text("Focus on every character")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
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
}

private extension TypingTaskView {
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
                .foregroundStyle(.baseBlacktoWhite)
                .opacity(0.3)

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
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
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
                .foregroundStyle(.secondary)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }

    var continueButton: some View {
        Button(action: {
            print("Action: Task complete, unlocking app.")
        }) {
            Text("CONTINUE")
                .font(.headline.bold())
                .foregroundStyle(.baseWhitetoblack)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.baseBlacktoWhite)
                .cornerRadius(14)
        }
        .padding(.bottom, 20)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

private extension TypingTaskView {
    var renderedProgressString: AttributedString {
        let targetChars = Array(viewModel.targetPhrase)
        let typedChars = Array(viewModel.currentTextEntry)
        var result = AttributedString()

        for i in 0..<targetChars.count {
            var char = AttributedString(String(targetChars[i]))

            if i < typedChars.count {
                let isMatch = viewModel.compareCharacters(targetChars[i], typedChars[i])
                char.foregroundColor = isMatch ? Color.primary : Color.red
            } else if i == typedChars.count && !viewModel.isTaskComplete {
                char.backgroundColor = Color.primary.opacity(0.15)
                char.foregroundColor = Color.primary.opacity(0.3)
            } else {
                char.foregroundColor = Color.clear
            }
            result += char
        }
        return result
    }
}

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
