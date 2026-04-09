import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var viewModel: OnboardingViewModel
    @State private var currentPage = 0
    
    init(hasSeenOnboarding: Binding<Bool>, service: any ScreenTimeServicing) {
        self._hasSeenOnboarding = hasSeenOnboarding
        self._viewModel = State(initialValue: OnboardingViewModel(screenTimeService: service))
    }
    
    private let steps = [
        PagedCarouselItem(
            id: 0,
            title: "Welcome!",
            imageName: "welcome-1",
            text: "Struggling with endless scrolling?\nLet's train your boredom tolerance.\n\nBeat digital distractions and sustain your goal-directed effort to focus on what truly matters."
        ),
        PagedCarouselItem(
            id: 1,
            title: "Meet\nThe aMCC",
            imageName: nil,
            text: "The secret to your focus is the aMCC (Anterior Midcingulate Cortex).\n\nYou can strengthen this brain area by pushing through boredom. A stronger aMCC means unbreakable willpower!"
        ),
        PagedCarouselItem(
            id: 2,
            title: "The Shield",
            imageName: "welcome-3",
            text: "Opening a distracting app?\nOur shield will replace it with an interactive brain challenge.\n\nBeat the challenge to earn points for cool rewards."
        ),
        PagedCarouselItem(
            id: 3,
            title: "Final Step",
            systemIconName: "shield.checkered",
            text: "To protect your focus, we need your permission to shield distracting apps.\n\nYour data is private and never leaves this iPhone."
        )
    ]
    
    var body: some View {
        VStack {
            PagedComponentView(
                currentPage: $currentPage,
                items: steps,
                nextTitle: "Next",
                doneTitle: viewModel.isAuthorizing ? "Authorizing..." : "Grant Access",
                onDone: {
                    handleGetStarted()
                }
            ) { step in
                VStack {
                    PagedCarouselPageView(
                        title: step.title,
                        imageName: step.imageName,
                        systemIconName: step.systemIconName,
                        text: step.text
                    )
                    
                    if currentPage == 3, let error = viewModel.error {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 10)
                    }
                }
            }
        }
        .background(Color.baseWhitetoblack.ignoresSafeArea())
    }
    
    private func handleGetStarted() {
        Task {
            let success = await viewModel.authorize()
            if success {
                hasSeenOnboarding = true
            }
        }
    }
}

private struct PreviewScreenTimeService: ScreenTimeServicing {
    func requestAuthorization() async throws {
    }
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false), service: PreviewScreenTimeService())
}
