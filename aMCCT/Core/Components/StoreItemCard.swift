import SwiftUI

struct StoreItemCard: View {
	let imageName: String
	let title: String
	let bodyText: String
	let buyTitle: String
	let buyButtonColor: Color
	let isBuyEnabled: Bool
	let isLocked: Bool
	let onBuy: () -> Void

	init(
		imageName: String = "Wallpaper-1",
		title: String,
		bodyText: String,
		buyTitle: String = "Buy",
		buyButtonColor: Color = .blue,
		isBuyEnabled: Bool = true,
		isLocked: Bool = false,
		onBuy: @escaping () -> Void
	) {
		self.imageName = imageName
		self.title = title
		self.bodyText = bodyText
		self.buyTitle = buyTitle
		self.buyButtonColor = buyButtonColor
		self.isBuyEnabled = isBuyEnabled
		self.isLocked = isLocked
		self.onBuy = onBuy
	}

	var body: some View {
		VStack(alignment: .center, spacing: 10) {
			GeometryReader { geometry in
				Image(imageName)
					.resizable()
					.scaledToFill()
					.frame(width: geometry.size.width, height: geometry.size.width)
					.position(x: geometry.size.width / 2, y: geometry.size.width / 2)
			}
			.frame(maxWidth: .infinity)
			.aspectRatio(1, contentMode: .fit)
			.clipped()
			.clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

			Text(title)
				.font(.system(size: 14, weight: .bold))
				.foregroundStyle(.baseBlacktoWhite)
				.lineLimit(1)
				.frame(maxWidth: .infinity, alignment: .center)
				.multilineTextAlignment(.center)

			Text(bodyText)
				.font(.system(size: 12, weight: .regular))
				.foregroundStyle(.baseBlacktoWhite.opacity(0.75))
				.lineLimit(2)
				.frame(maxWidth: .infinity, alignment: .center)
				.multilineTextAlignment(.center)

			ActionButton(
				buyTitle,
				icon: nil,
				color: buyButtonColor,
				shape: .capsule,
				size: .compact,
				isFullWidth: false,
				isEnabled: isBuyEnabled,
				action: onBuy
			)
		}
		.padding(10)
		.opacity(isLocked ? 0.72 : 1.0)
		.background(
			RoundedRectangle(cornerRadius: 24, style: .continuous)
				.fill(Color(.secondarySystemBackground))
		)
		.overlay {
			RoundedRectangle(cornerRadius: 24, style: .continuous)
				.stroke(Color.baseBlacktoWhite.opacity(0.12), lineWidth: 1)
		}
	}
}

#Preview {
	StoreItemCard(
		imageName: "Wallpaper-1",
		title: "Neon Waves",
		bodyText: "A calm gradient wallpaper to keep your focus mode aesthetic clean.",
		buyTitle: "Buy"
	) {
	}
	.padding()
	.background(Color.baseWhitetoblack.ignoresSafeArea())
}

