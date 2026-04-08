import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0
    
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
            title: nil,
            imageName: "welcome-3",
            text: "Opening a distracting app?\nOur shield will replace it with an interactive brain challenge.\n\nBeat the challenge to earn points for cool rewards."
        )
    ]
    
    var body: some View {
        PagedComponentView(
            currentPage: $currentPage,
            items: steps,
            nextTitle: "Next",
            doneTitle: "Get Started",
            onDone: { hasSeenOnboarding = true }
        ) { step in
            PagedCarouselPageView(
                title: step.title,
                imageName: step.imageName,
                text: step.text
            )
        }
    }
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}