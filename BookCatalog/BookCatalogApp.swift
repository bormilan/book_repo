import SwiftUI
import SwiftData

@main
struct BookCatalogApp: App {
    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try PersistenceController.makeModelContainer()
        } catch {
            fatalError("Unable to create the local data store: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
