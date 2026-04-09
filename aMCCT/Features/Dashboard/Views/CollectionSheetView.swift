import SwiftUI

struct CollectionSheetView: View {
    let items: [StoreItem]

    @State private var selectedType: StoreItemType = .sticker

    private let orderedTypes: [StoreItemType] = [.sticker, .wallpaper, .profileBorder]
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var visibleItems: [StoreItem] {
        items
            .filter { $0.type == selectedType }
            .sorted { ($0.purchasedAt ?? .distantPast) > ($1.purchasedAt ?? .distantPast) }
    }

    private var collectionTitle: String {
        "My \(selectedType.displayName) Collection"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 15) {
                    if visibleItems.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: selectedType.icon)
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundStyle(.secondary)

                            Text("No \(selectedType.displayName.lowercased()) yet")
                                .font(.headline)

                            Text("Buy more from the store to fill this section.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 32)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(visibleItems, id: \.id) { item in
                                    StoreItemCard(
                                        imageName: item.assetName,
                                        title: item.name,
                                        bodyText: item.itemDescription ?? "Owned item",
                                        buyTitle: "Owned",
                                        buyButtonColor: .gray,
                                        isBuyEnabled: false,
                                        isLocked: true
                                    ) {
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .background(.baseWhitetoblack)
            .navigationTitle(collectionTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        moveToPreviousType()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .semibold))
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        moveToNextType()
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                    }
                }
            }
        }
    }

    private func moveToPreviousType() {
        guard let index = orderedTypes.firstIndex(of: selectedType) else {
            selectedType = .sticker
            return
        }

        let previousIndex = (index - 1 + orderedTypes.count) % orderedTypes.count
        selectedType = orderedTypes[previousIndex]
    }

    private func moveToNextType() {
        guard let index = orderedTypes.firstIndex(of: selectedType) else {
            selectedType = .sticker
            return
        }

        let nextIndex = (index + 1) % orderedTypes.count
        selectedType = orderedTypes[nextIndex]
    }
}

#Preview {
    let previewItems: [StoreItem] = [
        StoreItem(
            id: "sticker_ready",
            type: .sticker,
            price: 10,
            name: "Ready",
            description: "A quick motivational sticker.",
            assetName: "StickerReady"
        ),
        StoreItem(
            id: "sticker_idea",
            type: .sticker,
            price: 20,
            name: "Idea",
            description: "Celebrate your next spark.",
            assetName: "StickerIdea"
        ),
        StoreItem(
            id: "wallpaper_1",
            type: .wallpaper,
            price: 50,
            name: "Wallpaper 1",
            description: "Calm background theme.",
            assetName: "Wallpaper-1"
        ),
        StoreItem(
            id: "border_star",
            type: .profileBorder,
            price: 80,
            name: "Star Border",
            description: "Profile highlight border.",
            assetName: "StickerHalo"
        )
    ]

    return CollectionSheetView(items: previewItems)
}

