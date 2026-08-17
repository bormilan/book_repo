import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Book.title, order: .forward) private var books: [Book]
    @State private var showsManualEntry = false
    @State private var showsScanner = false
    @State private var selectedBook: Book?

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
                        showsScanner = true
                    }
                }
                ToolbarItem(placement: .secondaryAction) {
                    Button("Add manually", systemImage: "plus") {
                        showsManualEntry = true
                    }
                }
            }
            .sheet(isPresented: $showsManualEntry) {
                NavigationStack {
                    ManualBookForm()
                }
            }
            .sheet(isPresented: $showsScanner) {
                NavigationStack {
                    BarcodeScannerView { isbn in
                        openScannedISBN(isbn)
                    }
                }
            }
            .navigationDestination(item: $selectedBook) { book in
                BookDetailView(book: book)
            }
        }
    }

    private var collectionActions: some View {
        VStack(spacing: 12) {
            Button("Scan book", systemImage: "barcode.viewfinder") {
                showsScanner = true
            }
            .buttonStyle(.borderedProminent)

            Button("Add manually") {
                showsManualEntry = true
            }
            .buttonStyle(.bordered)
        }
    }

    private func openScannedISBN(_ isbn: String) {
        let repository = BookRepository(modelContext: modelContext)
        showsScanner = false

        if let existingBook = try? repository.book(withISBN: isbn) {
            selectedBook = existingBook
        } else {
            showsManualEntry = true
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

#Preview {
    ContentView()
        .modelContainer(for: Book.self, inMemory: true)
}
