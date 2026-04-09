import SwiftUI

let hintSteps = [
    PagedCarouselItem(
        id: 0,
        title: "Current Level",
        imageName: "welcome-3",
        text: "Your daily progress.\nBoost it by completing\nfriction tasks!"
    ),
    PagedCarouselItem(
        id: 1,
        title: "Brain Level",
        imageName: "welcome-1",
        text: "Your actual rank. It levels up whenever your Current Level gets 2 steps ahead.\n\nLevel: 1-100"
    ),
    PagedCarouselItem(
        id: 2,
        title: "Daily Reset",
        imageName: "welcome-3",
        text: "Every day, your Current Level resets to match your Brain Level."
    ),
    PagedCarouselItem(
        id: 3,
        title: "Manual Drop",
        imageName: "welcome-1",
        text: "You can manually drop your level (max -2 times/day). This lowers both your Brain and Current levels at the same time."
    )
]
struct HintsMainView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPage = 0

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Hints")
                    .font(.system(size: 17, weight: .semibold))
                
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.gray.opacity(0.2))
                    }
                    Spacer()
                }
            }
            .padding()

            PagedComponentView(
                currentPage: $currentPage,
                items: hintSteps,
                nextTitle: "Next",
                doneTitle: "Get Started",
                onDone: {
                    dismiss()
                }
            ) { step in
                PagedCarouselPageView(
                    title: step.title,
                    imageName: step.imageName,
                    text: step.text
                )
            }
        }
        .background(Color.white)
    }
}
#Preview {
    HintsMainView()
}
