import Foundation

struct BookMetadata: Equatable {
    let title: String
    let authors: String?
    let isbn: String
    let publisher: String?
    let publicationDate: Date?
    let language: String?
    let descriptionText: String?
}

enum ScannedBookImportResult {
    case imported(Book)
    case manualEntry(isbn: String)

    var fallbackISBN: String? {
        guard case let .manualEntry(isbn) = self else { return nil }
        return isbn
    }
}

@MainActor
struct ScannedBookImporter {
    typealias Lookup = (String) async throws -> BookMetadata?

    private let repository: BookRepository
    private let lookup: Lookup

    init(
        repository: BookRepository,
        lookup: @escaping Lookup = { isbn in
            try await OpenLibraryClient().lookup(isbn: isbn)
        }
    ) {
        self.repository = repository
        self.lookup = lookup
    }

    func importBook(isbn: String) async -> ScannedBookImportResult {
        do {
            guard let metadata = try await lookup(isbn) else {
                return .manualEntry(isbn: isbn)
            }

            let book = try repository.create(
                title: metadata.title,
                authors: metadata.authors,
                isbn: metadata.isbn,
                publisher: metadata.publisher,
                publicationDate: metadata.publicationDate,
                language: metadata.language,
                descriptionText: metadata.descriptionText
            )
            return .imported(book)
        } catch {
            return .manualEntry(isbn: isbn)
        }
    }
}

struct OpenLibraryClient {
    private let session: URLSession
    private let userAgent: String

    init(session: URLSession = .shared, userAgent: String = OpenLibraryConfiguration.userAgent) {
        self.session = session
        self.userAgent = userAgent
    }

    func lookup(isbn: String) async throws -> BookMetadata? {
        let request = try Self.makeRequest(isbn: isbn, userAgent: userAgent)
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let result = try JSONDecoder().decode([String: ResponseBook].self, from: data)
        return result["ISBN:\(isbn)"].map { book in
            BookMetadata(
                title: book.title,
                authors: book.authors?.map(\.name).joined(separator: ", "),
                isbn: isbn,
                publisher: book.publishers?.first?.name,
                publicationDate: PublicationDateParser.date(from: book.publishDate),
                language: book.languages?.first?.key.split(separator: "/").last.map(String.init),
                descriptionText: book.description?.text
            )
        }
    }

    static func makeRequest(isbn: String, userAgent: String) throws -> URLRequest {
        var components = URLComponents(string: "https://openlibrary.org/api/books")
        components?.queryItems = [
            URLQueryItem(name: "bibkeys", value: "ISBN:\(isbn)"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "jscmd", value: "data")
        ]
        guard let url = components?.url else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        return request
    }
}

private struct ResponseBook: Decodable {
    let title: String
    let authors: [NamedValue]?
    let publishers: [NamedValue]?
    let publishDate: String?
    let languages: [Language]?
    let description: Description?

    enum CodingKeys: String, CodingKey {
        case title, authors, publishers, languages, description
        case publishDate = "publish_date"
    }
}

private struct NamedValue: Decodable { let name: String }
private struct Language: Decodable { let key: String }
private struct Description: Decodable { let text: String }

private enum PublicationDateParser {
    static func date(from text: String?) -> Date? {
        guard let text else { return nil }
        let formats = ["yyyy-MM-dd", "yyyy"]
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: text) { return date }
        }
        return nil
    }
}
