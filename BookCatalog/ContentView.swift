import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \Book.title, order: .forward) private var books: [Book]
    @State private var unavailableFeature: UnavailableFeature?
    @State private var showsManualEntry = false

    var body: some View {
        NavigationStack {
            Group {
                if books.isEmpty {
                    ContentUnavailableView {
                        Label("No books yet", systemImage: "books.vertical")
                    } description: {
                        Text("Add a book manually or scan its ISBN to begin your catalog.")
                    } actions: {
                        collectionActions
                    }
                } else {
                    List(books) { book in
                        NavigationLink {
                            BookDetailView(book: book)
                        } label: {
                            BookRow(book: book)
                        }
                    }
                }
            }
            .navigationTitle("My Books")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Scan book", systemImage: "barcode.viewfinder") {
                        unavailableFeature = .scanner
                    }
                }
                ToolbarItem(placement: .secondaryAction) {
                    Button("Add manually", systemImage: "plus") {
                        showsManualEntry = true
                    }
                }
            }
            .alert(item: $unavailableFeature) { feature in
                Alert(
                    title: Text("Coming soon"),
                    message: Text(feature.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showsManualEntry) {
                NavigationStack {
                    ManualBookForm()
                }
            }
        }
    }

    private var collectionActions: some View {
        VStack(spacing: 12) {
            Button("Scan book", systemImage: "barcode.viewfinder") {
                unavailableFeature = .scanner
            }
            .buttonStyle(.borderedProminent)

            Button("Add manually") {
                showsManualEntry = true
            }
            .buttonStyle(.bordered)
        }
    }
}

private struct BookRow: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(book.title)
                .font(.headline)
            if let authors = book.authors, !authors.isEmpty {
                Text(authors)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private enum UnavailableFeature: String, Identifiable {
    case scanner

    var id: String { rawValue }

    var message: String {
        switch self {
        case .scanner:
            "Barcode scanning will be available in a later step."
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Book.self, inMemory: true)
}
