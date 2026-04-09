import SwiftUI
import SwiftData

struct StoreView: View {

    @Environment(DashboardViewModel.self) private var viewModel
    @Query private var allItems: [StoreItem]

    @State private var isCollectionPresented = false
    @State private var selectedRange = "wallpaper"

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                storeHeader
                
                SegmentedControl(
                    selection: $selectedRange,
                    accessibilityLabel: "Graph range",
                    "wallpaper",
                    "sticker",
                    "booster"
                )
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        let filteredItems = allItems.filter { $0.type.rawValue == selectedRange }

                        if filteredItems.isEmpty {
                            ForEach(0..<6, id: \.self) { _ in
                                placeholderSquareCard
                            }
                        } else {
                            ForEach(filteredItems, id: \.id) { item in
                                storeGridCell(for: item)
                            }
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

    private func storeGridCell(for item: StoreItem) -> some View {
        placeholderSquareCard
    }


    private var placeholderSquareCard: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(Color(.secondarySystemBackground))
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.baseBlacktoWhite.opacity(0.2), lineWidth: 1)
        )
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
