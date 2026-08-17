import Foundation
import SwiftData

enum PersistenceController {
    static func makeModelContainer(
        isStoredInMemoryOnly: Bool = false,
        storeURL: URL? = nil
    ) throws -> ModelContainer {
        let schema = Schema([Book.self])
        let configuration: ModelConfiguration

        if let storeURL {
            configuration = ModelConfiguration(
                "BookCatalog",
                schema: schema,
                url: storeURL,
                cloudKitDatabase: .none
            )
        } else {
            configuration = ModelConfiguration(
                "BookCatalog",
                schema: schema,
                isStoredInMemoryOnly: isStoredInMemoryOnly,
                cloudKitDatabase: .none
            )
        }

        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
