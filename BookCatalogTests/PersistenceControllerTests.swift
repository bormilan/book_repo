import SwiftData
import XCTest
@testable import BookCatalog

final class PersistenceControllerTests: XCTestCase {
    @MainActor
    func testCreatesAnInMemoryModelContainer() throws {
        let container = try PersistenceController.makeModelContainer(isStoredInMemoryOnly: true)

        XCTAssertNotNil(container.mainContext)
    }

    @MainActor
    func testSavesATitleOnlyBook() throws {
        let container = try PersistenceController.makeModelContainer(isStoredInMemoryOnly: true)
        let repository = BookRepository(modelContext: container.mainContext)

        let savedBook = try repository.create(title: "The Left Hand of Darkness")

        XCTAssertEqual(savedBook.title, "The Left Hand of Darkness")
        XCTAssertNil(savedBook.isbn)
        XCTAssertEqual(try repository.fetchAll().map(\.title), [savedBook.title])
    }

    @MainActor
    func testFetchesBooksInAscendingTitleOrder() throws {
        let container = try PersistenceController.makeModelContainer(isStoredInMemoryOnly: true)
        let repository = BookRepository(modelContext: container.mainContext)

        _ = try repository.create(title: "Zoo")
        _ = try repository.create(title: "A Wizard of Earthsea")
        _ = try repository.create(title: "Dune")

        XCTAssertEqual(
            try repository.fetchAll().map(\.title),
            ["A Wizard of Earthsea", "Dune", "Zoo"]
        )
    }

    @MainActor
    func testRejectsDuplicateNonEmptyISBNs() throws {
        let container = try PersistenceController.makeModelContainer(isStoredInMemoryOnly: true)
        let repository = BookRepository(modelContext: container.mainContext)

        _ = try repository.create(title: "Dune", isbn: "978-0-441-17271-9")

        XCTAssertThrowsError(
            try repository.create(title: "Dune: Duplicate", isbn: "9780441172719")
        ) { error in
            XCTAssertEqual(error as? BookRepositoryError, .duplicateISBN("9780441172719"))
        }
        XCTAssertEqual(try repository.fetchAll().count, 1)
    }

    @MainActor
    func testStoresOptionalBookMetadata() throws {
        let container = try PersistenceController.makeModelContainer(isStoredInMemoryOnly: true)
        let repository = BookRepository(modelContext: container.mainContext)
        let publicationDate = Date(timeIntervalSince1970: 1_000_000)

        let savedBook = try repository.create(
            title: "The Dispossessed",
            authors: "Ursula K. Le Guin",
            isbn: "978-0-06-105488-4",
            publisher: "Harper & Row",
            publicationDate: publicationDate,
            language: "en",
            descriptionText: "A science-fiction novel."
        )

        XCTAssertEqual(savedBook.authors, "Ursula K. Le Guin")
        XCTAssertEqual(savedBook.isbn, "9780061054884")
        XCTAssertEqual(savedBook.publisher, "Harper & Row")
        XCTAssertEqual(savedBook.publicationDate, publicationDate)
        XCTAssertEqual(savedBook.language, "en")
        XCTAssertEqual(savedBook.descriptionText, "A science-fiction novel.")
    }

    @MainActor
    func testDeletesABook() throws {
        let container = try PersistenceController.makeModelContainer(isStoredInMemoryOnly: true)
        let repository = BookRepository(modelContext: container.mainContext)
        let book = try repository.create(title: "Parable of the Sower")

        try repository.delete(book)

        XCTAssertTrue(try repository.fetchAll().isEmpty)
    }

    @MainActor
    func testPersistsBooksWhenTheStoreIsReopened() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let storeURL = directory.appendingPathComponent("BookCatalog.store")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        do {
            let firstContainer = try PersistenceController.makeModelContainer(storeURL: storeURL)
            let repository = BookRepository(modelContext: firstContainer.mainContext)
            _ = try repository.create(title: "A Wizard of Earthsea")
        }

        let reopenedContainer = try PersistenceController.makeModelContainer(storeURL: storeURL)
        let reopenedRepository = BookRepository(modelContext: reopenedContainer.mainContext)

        XCTAssertEqual(try reopenedRepository.fetchAll().map(\.title), ["A Wizard of Earthsea"])
    }
}
