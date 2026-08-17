import Foundation
import SwiftData

@Model
final class Book {
    var title: String
    var authors: String?
    var isbn: String?
    var publisher: String?
    var publicationDate: Date?
    var language: String?
    var descriptionText: String?
    var dateAdded: Date

    init(
        title: String,
        authors: String? = nil,
        isbn: String? = nil,
        publisher: String? = nil,
        publicationDate: Date? = nil,
        language: String? = nil,
        descriptionText: String? = nil,
        dateAdded: Date = .now
    ) {
        self.title = title
        self.authors = authors
        self.isbn = Self.normalizedISBN(isbn)
        self.publisher = publisher
        self.publicationDate = publicationDate
        self.language = language
        self.descriptionText = descriptionText
        self.dateAdded = dateAdded
    }

    static func normalizedISBN(_ isbn: String?) -> String? {
        guard let isbn else { return nil }

        let normalized = isbn.uppercased().filter { $0.isLetter || $0.isNumber }
        return normalized.isEmpty ? nil : normalized
    }
}
