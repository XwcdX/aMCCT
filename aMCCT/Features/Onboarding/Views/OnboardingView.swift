import SwiftUI

// MARK: - Data Model

struct OnboardingStep: Identifiable {
    let id: Int
    let title: String?
    let imageName: String?
    let text: String
}

// MARK: - Main View

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0
    
    private let steps = [
        OnboardingStep(
            id: 0,
            title: "Welcome!",
            imageName: "welcome-1",
            text: "Struggling with endless scrolling?\nLet's train your boredom tolerance.\n\nBeat digital distractions and sustain your goal-directed effort to focus on what truly matters."
        ),
        OnboardingStep(
            id: 1,
            title: "Meet\nThe aMCC",
            imageName: nil,
            text: "The secret to your focus is the aMCC (Anterior Midcingulate Cortex).\n\nYou can strengthen this brain area by pushing through boredom. A stronger aMCC means unbreakable willpower!"
        ),
        OnboardingStep(
            id: 2,
            title: nil,
            imageName: "welcome-3",
            text: "Opening a distracting app?\nOur shield will replace it with an interactive brain challenge.\n\nBeat the challenge to earn points for cool rewards."
        )
    ]
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(steps) { step in
                    OnboardingPage(step: step)
                        .tag(step.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .onAppear(perform: setupPageControlAppearance)
            
            nextButton
        }
        .padding(.top, 24)
    }
    
    // MARK: - Subviews
    
    private var nextButton: some View {
        Button(action: {
            if currentPage < steps.count - 1 {
                withAnimation {
                    currentPage += 1
                }
            } else {
                hasSeenOnboarding = true
            }
        }) {
            Text(currentPage < steps.count - 1 ? "Next" : "Get Started")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 120, height: 44)
                .background(Color.blue)
                .cornerRadius(22)
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - Helpers
    
    private func setupPageControlAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .black
        UIPageControl.appearance().pageIndicatorTintColor = .systemGray4
    }
}

// MARK: - Reusable Page View

struct OnboardingPage: View {
    let step: OnboardingStep
    
    var body: some View {
        VStack(spacing: 32) {
            
            if let title = step.title {
                Text(title)
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
            }
            
            if let imageName = step.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 220)
            }
            
            Text(step.text)
                .font(.system(size: 15, weight: .regular))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 32)
            
        }
        .padding(.horizontal)
    }
}
