import Foundation
import SwiftData

enum StoreSeeder {
    static func seed(context: ModelContext) {
        print("[StoreSeeder] seedIfNeeded called")

        let existing: [StoreItem]
        do {
            existing = try context.fetch(FetchDescriptor<StoreItem>())
            print("[StoreSeeder] existing items in DB: \(existing.count)")
        } catch {
            print("[StoreSeeder] ERROR fetching: \(error)")
            return
        }

        var existingById: [String: StoreItem] = Dictionary(
            uniqueKeysWithValues: existing.map { ($0.id, $0) }
        )
        print("[StoreSeeder] catalog total: \(StoreCatalog.all.count)")

        var inserted = 0
        var updated = 0
        for catalogItem in StoreCatalog.all {
            if let existingItem = existingById[catalogItem.id] {
                var didChange = false

                if existingItem.type != catalogItem.type {
                    existingItem.type = catalogItem.type
                    didChange = true
                }
                if existingItem.price != catalogItem.price {
                    existingItem.price = catalogItem.price
                    didChange = true
                }
                if existingItem.name != catalogItem.name {
                    existingItem.name = catalogItem.name
                    didChange = true
                }
                if existingItem.itemDescription != catalogItem.description {
                    existingItem.itemDescription = catalogItem.description
                    didChange = true
                }
                if existingItem.assetName != catalogItem.assetName {
                    existingItem.assetName = catalogItem.assetName
                    didChange = true
                }

                if didChange {
                    updated += 1
                    print("[StoreSeeder] updated: \(catalogItem.id)")
                }
                continue
            }

            let item = StoreItem(
                id: catalogItem.id,
                type: catalogItem.type,
                price: catalogItem.price,
                name: catalogItem.name,
                description: catalogItem.description,
                assetName: catalogItem.assetName
            )
            context.insert(item)
            existingById[catalogItem.id] = item
            inserted += 1
            print("[StoreSeeder] inserted: \(catalogItem.id)")
        }

        do {
            try context.save()
            print("[StoreSeeder] save OK — inserted \(inserted) items, updated \(updated) items")
        } catch {
            print("[StoreSeeder] ERROR saving: \(error)")
        }
    }
}
