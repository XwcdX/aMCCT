import SwiftUI
import SwiftData

struct StoreView: View {

    @Environment(DashboardViewModel.self) private var viewModel
    @Query private var allItems: [StoreItem]

    @State private var isCollectionPresented = false
    @State private var selectedType: StoreItemType = .wallpaper
    @State private var pendingPurchaseItem: StoreCatalogItem?

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

    private var purchasedItems: [StoreItem] {
        allItems
            .filter { $0.isPurchased }
            .sorted { ($0.purchasedAt ?? .distantPast) > ($1.purchasedAt ?? .distantPast) }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 15) {
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
        .alert(
            "Are you sure you want to buy \(pendingPurchaseItem?.name ?? "this item")?",
            isPresented: Binding(
                get: { pendingPurchaseItem != nil },
                set: { if !$0 { pendingPurchaseItem = nil } }
            ),
            presenting: pendingPurchaseItem
        ) { catalogItem in
            Button("Buy") {
                confirmPurchase(for: catalogItem)
            }
            Button("Cancel", role: .cancel) {
                pendingPurchaseItem = nil
            }
        } message: { catalogItem in
            Text("This will spend \(catalogItem.price) points.")
        }
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
            CollectionSheetView(items: purchasedItems) { item in
                viewModel.equipItem(item)
            }
            .presentationDetents([.medium, .large])
        }
    }

    private var storeHeader: some View {
        HStack {
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
            bodyText: catalogItem.price > 0 ? "\(catalogItem.price) points" : "Free",
            buyTitle: isPurchased ? "Bought" : "Buy",
            buyButtonColor: isPurchased ? .gray : .blue,
            isBuyEnabled: !isPurchased,
            isLocked: isPurchased
        ) {
            guard !isPurchased else { return }
            pendingPurchaseItem = catalogItem
        }
    }

    private func confirmPurchase(for catalogItem: StoreCatalogItem) {
        defer { pendingPurchaseItem = nil }

        viewModel.purchaseCatalogItem(catalogItem)
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
