import SwiftData

enum PersistenceController {
    static func makeModelContainer(isStoredInMemoryOnly: Bool = false) throws -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: isStoredInMemoryOnly)

        return try ModelContainer(for: AppSettings.self, configurations: configuration)
    }
}
