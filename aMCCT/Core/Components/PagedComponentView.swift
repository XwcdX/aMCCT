import SwiftUI

struct PagedCarouselItem: Identifiable {
	let id: Int
	let title: String?
	let imageName: String?
    let systemIconName: String?
	let text: String
    
    init(
        id: Int,
        title: String?,
        imageName: String? = nil,
        systemIconName: String? = nil,
        text: String
    ) {
        self.id = id
        self.title = title
        self.imageName = imageName
        self.systemIconName = systemIconName
        self.text = text
    }
}

struct PagedComponentView<Data: RandomAccessCollection, Content: View>: View {
	@Binding var currentPage: Int
	let items: Data
	let nextTitle: String
	let doneTitle: String
	let onDone: () -> Void
	let content: (Data.Element) -> Content

	init(
		currentPage: Binding<Int>,
		items: Data,
		nextTitle: String = "Next",
		doneTitle: String = "Done",
		onDone: @escaping () -> Void = {},
		@ViewBuilder content: @escaping (Data.Element) -> Content
	) {
		self._currentPage = currentPage
		self.items = items
		self.nextTitle = nextTitle
		self.doneTitle = doneTitle
		self.onDone = onDone
		self.content = content
	}

	var body: some View {
		VStack {
			TabView(selection: $currentPage) {
				ForEach(Array(items.enumerated()), id: \.offset) { index, item in
					content(item)
						.tag(index)
				}
			}
			.tabViewStyle(.page(indexDisplayMode: .always))
			.onAppear(perform: setupPageControlAppearance)

			navigationButton
		}
		.padding(.top, 24)
	}

	private var navigationButton: some View {
		Button(action: handleNextTap) {
			Text(currentPage < items.count - 1 ? nextTitle : doneTitle)
				.font(.system(size: 16, weight: .semibold))
				.foregroundStyle(.white)
				.frame(width: 120, height: 44)
				.background(Color.blue)
				.cornerRadius(22)
		}
		.padding(.bottom, 40)
	}

	private func handleNextTap() {
		if currentPage < items.count - 1 {
			withAnimation {
				currentPage += 1
			}
		} else {
			onDone()
		}
	}

	private func setupPageControlAppearance() {
		UIPageControl.appearance().currentPageIndicatorTintColor = .black
		UIPageControl.appearance().pageIndicatorTintColor = .systemGray4
	}
}

struct PagedCarouselPageView: View {
	let title: String?
	let imageName: String?
    let systemIconName: String?
	let text: String

	var body: some View {
		VStack(spacing: 32) {
			if let title {
				Text(title)
					.font(.system(size: 32, weight: .bold))
					.multilineTextAlignment(.center)
			}

            if let systemIconName {
                Image(systemName: systemIconName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .foregroundStyle(.blue)
            } else if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 220)
            }

			Text(text)
				.font(.system(size: 15, weight: .regular))
				.multilineTextAlignment(.center)
				.lineSpacing(6)
				.padding(.horizontal, 32)
		}
		.padding(.horizontal)
	}
}

