import Foundation
import SwiftData

enum BookRepositoryError: Error, Equatable {
    case duplicateISBN(String)
}

@MainActor
struct BookRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func create(
        title: String,
        authors: String? = nil,
        isbn: String? = nil,
        publisher: String? = nil,
        publicationDate: Date? = nil,
        language: String? = nil,
        descriptionText: String? = nil
    ) throws -> Book {
        let normalizedISBN = Book.normalizedISBN(isbn)

        if let normalizedISBN, try book(withISBN: normalizedISBN) != nil {
            throw BookRepositoryError.duplicateISBN(normalizedISBN)
        }

        let book = Book(
            title: title,
            authors: authors,
            isbn: normalizedISBN,
            publisher: publisher,
            publicationDate: publicationDate,
            language: language,
            descriptionText: descriptionText
        )
        modelContext.insert(book)
        try modelContext.save()
        return book
    }

    func fetchAll() throws -> [Book] {
        try modelContext.fetch(FetchDescriptor<Book>())
    }

    func delete(_ book: Book) throws {
        modelContext.delete(book)
        try modelContext.save()
    }

    private func book(withISBN isbn: String) throws -> Book? {
        let predicate = #Predicate<Book> { book in
            book.isbn == isbn
        }
        var descriptor = FetchDescriptor<Book>(predicate: predicate)
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
}
