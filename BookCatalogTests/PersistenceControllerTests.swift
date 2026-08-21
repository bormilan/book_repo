import SwiftData
import XCTest
@testable import BookCatalog

final class PersistenceControllerTests: XCTestCase {
    func testFormatsAppVersionAndBuildFromBundleValues() {
        let version = AppVersion.displayText(
            infoDictionary: [
                "CFBundleShortVersionString": "0.0.2",
                "CFBundleVersion": "11"
            ]
        )

        XCTAssertEqual(version, "Version 0.0.2 (11)")
    }

    func testAppVersionFallsBackWhenBundleValuesAreUnavailable() {
        XCTAssertEqual(AppVersion.displayText(infoDictionary: [:]), "Version unavailable")
    }

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

    func testManualBookDraftRequiresANonEmptyTitle() {
        var draft = ManualBookDraft()

        XCTAssertFalse(draft.canSave)

        draft.title = "   "
        XCTAssertFalse(draft.canSave)

        draft.title = "Kindred"
        XCTAssertTrue(draft.canSave)
    }

    func testManualBookDraftKeepsAPrefilledISBN() {
        let draft = ManualBookDraft(prefilledISBN: "978-0-8070-8369-7")

        XCTAssertEqual(draft.isbn, "978-0-8070-8369-7")
    }

    func testAcceptsISBN13BookBarcodes() {
        XCTAssertEqual(
            ISBNBarcodeValidator.isbn(from: "9780807083697"),
            "9780807083697"
        )
        XCTAssertEqual(
            ISBNBarcodeValidator.isbn(from: "9791234567896"),
            "9791234567896"
        )
    }

    func testValidatesISBN10AndISBN13CheckDigits() {
        XCTAssertTrue(ISBNValidator.isValid("0-306-40615-2"))
        XCTAssertTrue(ISBNValidator.isValid("978-0-306-40615-7"))
        XCTAssertFalse(ISBNValidator.isValid("978-0-306-40615-8"))
        XCTAssertFalse(ISBNValidator.isValid("0-306-40615-3"))
    }

    func testTreatsAnEmptyOptionalISBNAsValid() {
        XCTAssertTrue(ISBNValidator.isValidOptional(""))
        XCTAssertTrue(ISBNValidator.isValidOptional("   "))
    }

    func testRejectsUnsupportedOrMalformedBarcodes() {
        XCTAssertNil(ISBNBarcodeValidator.isbn(from: "0123456789012"))
        XCTAssertNil(ISBNBarcodeValidator.isbn(from: "978080708369"))
        XCTAssertNil(ISBNBarcodeValidator.isbn(from: "978080708369X"))
        XCTAssertNil(ISBNBarcodeValidator.isbn(from: "9780807083697X"))
    }

    func testOpenLibraryRequestUsesIdentifyingUserAgent() throws {
        let request = try OpenLibraryClient.makeRequest(
            isbn: "9780807083697",
            userAgent: "BookCatalog/0.0.1 (contact: test@example.com)"
        )

        XCTAssertEqual(request.url?.host, "openlibrary.org")
        XCTAssertEqual(request.value(forHTTPHeaderField: "User-Agent"), "BookCatalog/0.0.1 (contact: test@example.com)")
    }

    func testOpenLibraryLookupReturnsNilForNoMatchingBook() async throws {
        MockURLProtocol.responseData = Data("{}".utf8)
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let client = OpenLibraryClient(
            session: URLSession(configuration: configuration),
            userAgent: "BookCatalogTests/1.0"
        )

        let result = try await client.lookup(isbn: "9789999999991")

        XCTAssertNil(result)
    }

    func testOpenLibraryLookupDecodesAllSupportedMetadata() async throws {
        MockURLProtocol.responseData = Data(
            #"""
            {
              "ISBN:9780061054884": {
                "title": "The Dispossessed",
                "authors": [{"name": "Ursula K. Le Guin"}],
                "publishers": [{"name": "Harper & Row"}],
                "publish_date": "1974-05-01",
                "languages": [{"key": "/languages/eng"}],
                "description": {"text": "An ambiguous utopia."}
              }
            }
            """#.utf8
        )
        let client = makeOpenLibraryClient()

        let result = try await client.lookup(isbn: "9780061054884")

        XCTAssertEqual(result?.title, "The Dispossessed")
        XCTAssertEqual(result?.authors, "Ursula K. Le Guin")
        XCTAssertEqual(result?.isbn, "9780061054884")
        XCTAssertEqual(result?.publisher, "Harper & Row")
        XCTAssertEqual(result?.language, "eng")
        XCTAssertEqual(result?.descriptionText, "An ambiguous utopia.")
        XCTAssertNotNil(result?.publicationDate)
    }

    @MainActor
    func testScanImportSavesTheFirstReturnedBookAutomatically() async throws {
        let container = try PersistenceController.makeModelContainer(isStoredInMemoryOnly: true)
        let repository = BookRepository(modelContext: container.mainContext)
        let importer = ScannedBookImporter(repository: repository) { isbn in
            BookMetadata(
                title: "Kindred",
                authors: "Octavia E. Butler",
                isbn: isbn,
                publisher: "Doubleday",
                publicationDate: nil,
                language: "eng",
                descriptionText: "A novel."
            )
        }

        let result = await importer.importBook(isbn: "9780807083697")

        guard case let .imported(book) = result else {
            return XCTFail("Expected the first lookup result to be imported")
        }
        XCTAssertIdentical(try repository.fetchAll().first, book)
        XCTAssertEqual(book.title, "Kindred")
    }

    @MainActor
    func testScanImportFallsBackToManualEntryForEmptyAndFailedLookups() async throws {
        let container = try PersistenceController.makeModelContainer(isStoredInMemoryOnly: true)
        let repository = BookRepository(modelContext: container.mainContext)
        let emptyImporter = ScannedBookImporter(repository: repository) { _ in nil }
        let failedImporter = ScannedBookImporter(repository: repository) { _ in
            throw URLError(.notConnectedToInternet)
        }

        let emptyResult = await emptyImporter.importBook(isbn: "9780807083697")
        let failedResult = await failedImporter.importBook(isbn: "9780807083697")

        XCTAssertEqual(emptyResult.fallbackISBN, "9780807083697")
        XCTAssertEqual(failedResult.fallbackISBN, "9780807083697")
        XCTAssertTrue(try repository.fetchAll().isEmpty)
    }

    @MainActor
    func testImportFeedbackNamesTheTitleAndSourceAndSupportsViewAndUndo() throws {
        let container = try PersistenceController.makeModelContainer(isStoredInMemoryOnly: true)
        let repository = BookRepository(modelContext: container.mainContext)
        let book = try repository.create(title: "Kindred", isbn: "9780807083697")
        var feedback = ImportFeedbackState(importedBook: book)

        XCTAssertEqual(feedback.message, "Kindred was added from Open Library.")

        feedback.viewImportedBook()
        XCTAssertIdentical(feedback.selectedBook, book)

        try feedback.undo(using: repository)
        XCTAssertNil(feedback.importedBook)
        XCTAssertNil(feedback.selectedBook)
        XCTAssertTrue(try repository.fetchAll().isEmpty)
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

private func makeOpenLibraryClient() -> OpenLibraryClient {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockURLProtocol.self]
    return OpenLibraryClient(
        session: URLSession(configuration: configuration),
        userAgent: "BookCatalogTests/1.0"
    )
}

private final class MockURLProtocol: URLProtocol {
    static var responseData = Data()

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let response = HTTPURLResponse(
            url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Self.responseData)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
