import SwiftUI
import SwiftData

struct StoreView: View {

    @Environment(DashboardViewModel.self) private var viewModel
    @Query private var allItems: [StoreItem]

    @State private var isCollectionPresented = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Store header
            storeHeader
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 10)

            // MARK: Item grid
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    ForEach(StoreItemType.allCases, id: \.self) { type in
                        let items = allItems.filter { $0.type == type }
                        if !items.isEmpty {
                            typeSection(type: type, items: items)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
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
                Text("\(viewModel.brainState?.spendablePoints ?? 0)")
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

    // MARK: - Type section

    private func typeSection(type: StoreItemType, items: [StoreItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: type.icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.baseBlacktoWhite.opacity(0.4))
                Text(type.displayName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.baseBlacktoWhite.opacity(0.4))
                    .textCase(.uppercase)
                    .tracking(0.8)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(items, id: \.id) { item in
                    StoreItemCard(
                        item: item,
                        spendablePoints: viewModel.brainState?.spendablePoints ?? 0,
                        onPurchase: { viewModel.purchaseItem(item) }
                    )
                }
            }
        }
    }
}

// MARK: - StoreItemCard

struct StoreItemCard: View {

    let item: StoreItem
    let spendablePoints: Int
    let onPurchase: () -> Void

    private var canAfford: Bool { spendablePoints >= item.price }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Asset placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.baseBlacktoWhite.opacity(0.05))
                    .frame(height: 90)

                Image(systemName: item.type.icon)
                    .font(.system(size: 28, weight: .thin))
                    .foregroundStyle(.baseBlacktoWhite.opacity(item.isPurchased ? 0.85 : 0.2))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(item.itemDescription)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.35))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 10)
            .padding(.top, 8)
            .padding(.bottom, 6)

            purchaseButton
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            item.isPurchased
                                ? Color.cyan.opacity(0.25)
                                : Color.white.opacity(0.07),
                            lineWidth: 1
                        )
                )
        )
    }

    @ViewBuilder
    private var purchaseButton: some View {
        if item.isPurchased {
            HStack(spacing: 4) {
                Image(systemName: "checkmark")
                    .font(.system(size: 9, weight: .bold))
                Text("Owned")
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(.cyan)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.cyan.opacity(0.1))
            )
        } else {
            Button(action: onPurchase) {
                HStack(spacing: 4) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 9, weight: .bold))
                    Text("\(item.price)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(canAfford ? .yellow : .white.opacity(0.25))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(canAfford ? Color.yellow.opacity(0.1) : Color.white.opacity(0.04))
                )
            }
            .disabled(!canAfford)
        }
    }
}
