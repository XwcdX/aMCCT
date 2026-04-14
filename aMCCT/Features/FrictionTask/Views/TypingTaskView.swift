import SwiftData
import SwiftUI

struct TypingTaskView: View {
    @Bindable var viewModel: FrictionTaskViewModel
    var onSuccess: () -> Void
    
    @State private var isFieldFocused = false
    @Query private var brainStates: [BrainState]
    @Query(filter: #Predicate<StoreItem> { $0.isEquipped }) private var equippedItems: [StoreItem]

    private var currentLevel: Int {
        brainStates.first?.currentLevel ?? 1
    }

    private var progressValue: Double {
        guard !viewModel.targetPhrase.isEmpty else { return 0 }
        return Double(viewModel.currentTextEntry.count) / Double(viewModel.targetPhrase.count)
    }

    private var equippedWallpaper: String? {
        equippedItems.first(where: { $0.type == .wallpaper })?.assetName
    }

    var body: some View {
        FrictionCard(
            title: "TRAIN YOUR MIND",
            progress: progressValue,
            currentLevel: currentLevel,
            backgroundImageName: equippedWallpaper,
            onCancel: {
                exit(0)
            }
        ) {
            VStack(spacing: 40) {
                Spacer()

                VStack(spacing: 8) {
                    Text("Focus on every character")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if viewModel.isBackspaceDisabled {
                        Text("No Backspace: Accuracy is mandatory")
                            .font(.caption2.bold())
                            .foregroundStyle(.red.opacity(0.8))
                    }
                }

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
                    ActionButton("CONTINUE", color: .baseBlacktoWhite, shape: .capsule) {
                        onSuccess()
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.horizontal, 24)
            .onAppear { setupInitialState() }
            .onChange(of: viewModel.isLoading) { _, loading in
                handleLoadingChange(loading)
            }
            .onChange(of: viewModel.isTaskComplete) { _, complete in
                if complete {
                    withAnimation { isFieldFocused = false }
                }
            }
        }
    }
}

// MARK: - Components

extension TypingTaskView {
    private var typingArea: some View {
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(0.011)
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

    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("AI is generating friction...")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
}

// MARK: - String Rendering
extension TypingTaskView {
    private var renderedProgressString: AttributedString {
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

// MARK: - Lifecycle Logic
extension TypingTaskView {
    private func setupInitialState() {
        if !viewModel.isLoading {
            isFieldFocused = true
        }
    }

    private func handleLoadingChange(_ loading: Bool) {
        if !loading {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation { isFieldFocused = true }
            }
        }
    }
}
