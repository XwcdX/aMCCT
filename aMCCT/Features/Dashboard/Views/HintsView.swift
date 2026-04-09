import SwiftUI

struct HintsView: View {
    @State private var currentPage = 0
    
    private let steps = [
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
    
    var body: some View {
        VStack {
            PagedComponentView(
                currentPage: $currentPage,
                items: steps,
                nextTitle: "Next",
            ) { step in
                PagedCarouselPageView(
                    title: step.title,
                    imageName: step.imageName,
                    systemIconName: step.systemIconName,
                    text: step.text
                )
            }
        }
        .background(Color.baseWhitetoblack.ignoresSafeArea())
    }
}

#Preview {
    HintsView()
}
