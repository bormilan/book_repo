import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Book.title, order: .forward) private var books: [Book]
    @State private var showsManualEntry = false
    @State private var showsScanner = false
    @State private var importFeedback = ImportFeedbackState()
    @State private var manualEntryISBN: String?
    @State private var isLookingUpISBN = false

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
            .overlay {
                if isLookingUpISBN {
                    ProgressView("Looking up book…")
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
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
                    ManualBookForm(prefilledISBN: manualEntryISBN)
                }
            }
            .sheet(isPresented: $showsScanner) {
                NavigationStack {
                    BarcodeScannerView { isbn in
                        handleScannedISBN(isbn)
                    }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: 0) {
                    if importFeedback.importedBook != nil {
                        importConfirmation
                    }

                    Text(AppVersion.currentDisplayText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(.bar)
                        .accessibilityLabel("App \(AppVersion.currentDisplayText)")
                }
            }
            .task(id: importFeedback.importedBook?.persistentModelID) {
                guard let importedBook = importFeedback.importedBook else { return }
                try? await Task.sleep(for: .seconds(10))
                guard !Task.isCancelled, importFeedback.importedBook === importedBook else { return }
                importFeedback.importedBook = nil
            }
            .navigationDestination(item: $importFeedback.selectedBook) { book in
                BookDetailView(book: book)
            }
        }
    }

    private var importConfirmation: some View {
        HStack(spacing: 12) {
            Text(importFeedback.message ?? "Book added from Open Library.")
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("View") {
                importFeedback.viewImportedBook()
            }
            .fontWeight(.semibold)

            Button("Undo", role: .destructive) {
                let repository = BookRepository(modelContext: modelContext)
                try? importFeedback.undo(using: repository)
            }
            .fontWeight(.semibold)
        }
        .padding()
        .background(.regularMaterial)
        .accessibilityElement(children: .contain)
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

    private func handleScannedISBN(_ isbn: String) {
        let repository = BookRepository(modelContext: modelContext)
        showsScanner = false

        if let existingBook = try? repository.book(withISBN: isbn) {
            importFeedback.selectedBook = existingBook
        } else {
            isLookingUpISBN = true
            Task {
                defer { isLookingUpISBN = false }
                let importer = ScannedBookImporter(repository: repository)
                switch await importer.importBook(isbn: isbn) {
                case let .imported(book):
                    importFeedback.importedBook = book
                case let .manualEntry(fallbackISBN):
                    openManualEntry(with: fallbackISBN)
                }
            }
        }
    }

    private func openManualEntry(with isbn: String) {
        manualEntryISBN = isbn
        showsManualEntry = true
    }
}

enum AppVersion {
    static var currentDisplayText: String {
        displayText(infoDictionary: Bundle.main.infoDictionary ?? [:])
    }

    static func displayText(infoDictionary: [String: Any]) -> String {
        guard
            let version = infoDictionary["CFBundleShortVersionString"] as? String,
            !version.isEmpty,
            let build = infoDictionary["CFBundleVersion"] as? String,
            !build.isEmpty
        else {
            return "Version unavailable"
        }

        return "Version \(version) (\(build))"
    }
}

struct ImportFeedbackState {
    var importedBook: Book?
    var selectedBook: Book?

    init(importedBook: Book? = nil, selectedBook: Book? = nil) {
        self.importedBook = importedBook
        self.selectedBook = selectedBook
    }

    var message: String? {
        importedBook.map { "\($0.title) was added from Open Library." }
    }

    mutating func viewImportedBook() {
        selectedBook = importedBook
    }

    @MainActor
    mutating func undo(using repository: BookRepository) throws {
        guard let importedBook else { return }
        try repository.delete(importedBook)
        self.importedBook = nil
        selectedBook = nil
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
