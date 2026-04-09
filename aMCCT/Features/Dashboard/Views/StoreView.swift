import SwiftUI
import SwiftData

struct StoreView: View {

    @Environment(DashboardViewModel.self) private var viewModel
    @Query private var allItems: [StoreItem]

    @State private var isCollectionPresented = false
    @State private var selectedType: StoreItemType = .wallpaper

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var availableTypes: [StoreItemType] {
        StoreItemType.allCases.filter { type in
            StoreCatalog.all.contains(where: { $0.type == type })
        }
    }

    private var itemsById: [String: StoreItem] {
        Dictionary(uniqueKeysWithValues: allItems.map { ($0.id, $0) })
    }

    private var visibleCatalogItems: [StoreCatalogItem] {
        StoreCatalog.all.filter { $0.type == selectedType }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                storeHeader
                
                SegmentedControl(
                    selection: $selectedType,
                    options: availableTypes,
                    accessibilityLabel: "Store category",
                    title: { $0.displayName }
                )
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(visibleCatalogItems, id: \.id) { catalogItem in
                            storeGridCell(for: catalogItem)
                        }
                    }
                }
                
            }
            .padding(.horizontal, 20)
        }
        .background(.baseWhitetoblack)
        .onAppear {
            print("[StoreView] appeared — allItems count: \(allItems.count)")
            for item in allItems {
                print("[StoreView] item: \(item.id) type: \(item.type.rawValue)")
            }
            if allItems.isEmpty {
                print("[StoreView] WARNING — @Query returned 0 items. Check modelContainer is set at app root.")
            }
        }
        .sheet(isPresented: $isCollectionPresented) {
            // TODO: CollectionView — owned items
            Text("My Collection")
                .presentationDetents([.medium, .large])
        }
    }

    // MARK: - Store header

    private var storeHeader: some View {
        HStack {
            // Collection button — top left
            Button {
                isCollectionPresented = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "books.vertical")
                        .font(.system(size: 15, weight: .medium))
                    Text("Collection")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.baseBlacktoWhite.opacity(0.5))
                )
            }

            Spacer()

            // Points balance — top right
            HStack(spacing: 5) {
                Image(systemName: "sparkle")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.black)
                Text("\(viewModel.brainState?.points ?? 0)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.black)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.yellow)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.black.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }

    private func storeGridCell(for catalogItem: StoreCatalogItem) -> some View {
        let dbItem = itemsById[catalogItem.id]
        let isPurchased = dbItem?.isPurchased ?? false

        return StoreItemCard(
            imageName: catalogItem.assetName,
            title: catalogItem.name,
            bodyText: catalogItem.description,
            buyTitle: isPurchased ? "Owned" : "Buy"
        ) {
            guard !isPurchased else { return }
            guard let dbItem else {
                print("[StoreView] Missing DB item for catalog id: \(catalogItem.id)")
                return
            }
            viewModel.purchaseItem(dbItem)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: BrainState.self,
        StoreItem.self,
        configurations: config
    )

    let viewModel = DashboardViewModel(modelContext: container.mainContext)
    viewModel.load()

    return StoreView()
        .environment(viewModel)
        .modelContainer(container)
}
