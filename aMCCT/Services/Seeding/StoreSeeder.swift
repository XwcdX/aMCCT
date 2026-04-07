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

        let existingSet = Set(existing.map(\.id))
        print("[StoreSeeder] catalog total: \(StoreCatalog.all.count)")

        var inserted = 0
        for catalogItem in StoreCatalog.all {
            guard !existingSet.contains(catalogItem.id) else { continue }
            let item = StoreItem(
                id: catalogItem.id,
                type: catalogItem.type,
                price: catalogItem.price,
                name: catalogItem.name,
                description: catalogItem.description,
                assetName: catalogItem.assetName
            )
            context.insert(item)
            inserted += 1
            print("[StoreSeeder] inserted: \(catalogItem.id)")
        }

        do {
            try context.save()
            print("[StoreSeeder] save OK — inserted \(inserted) items")
        } catch {
            print("[StoreSeeder] ERROR saving: \(error)")
        }
    }
}
