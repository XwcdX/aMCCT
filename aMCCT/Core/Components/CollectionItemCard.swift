import SwiftUI

struct CollectionItemCard: View {
    let imageName: String
    let title: String
    let bodyText: String
    let equipTitle: String
    let equipButtonColor: Color
    let isEquipEnabled: Bool
    let isLocked: Bool
    let onEquip: () -> Void

    init(
        imageName: String = "Wallpaper-1",
        title: String,
        bodyText: String,
        equipTitle: String = "Equip",
        equipButtonColor: Color = .blue,
        isEquipEnabled: Bool = true,
        isLocked: Bool = false,
        onEquip: @escaping () -> Void
    ) {
        self.imageName = imageName
        self.title = title
        self.bodyText = bodyText
        self.equipTitle = equipTitle
        self.equipButtonColor = equipButtonColor
        self.isEquipEnabled = isEquipEnabled
        self.isLocked = isLocked
        self.onEquip = onEquip
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
                equipTitle,
                icon: nil,
                color: equipButtonColor,
                shape: .capsule,
                size: .compact,
                isFullWidth: false,
                isEnabled: isEquipEnabled,
                action: onEquip
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
    CollectionItemCard(
        imageName: "Wallpaper-1",
        title: "Neon Waves",
        bodyText: "A calm gradient wallpaper to keep your focus mode aesthetic clean.",
        equipTitle: "Equip"
    ) {
    }
    .padding()
    .background(Color.baseWhitetoblack.ignoresSafeArea())
}
