import Foundation

struct ManualBookDraft {
    var title = ""
    var authors = ""
    var isbn: String
    var publisher = ""
    var publicationDate = Date()
    var includesPublicationDate = false
    var language = ""
    var descriptionText = ""

    init(prefilledISBN: String? = nil) {
        isbn = prefilledISBN ?? ""
    }

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && ISBNValidator.isValidOptional(isbn)
    }

    var isbnValidationMessage: String? {
        let value = isbn.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty || ISBNValidator.isValid(value)
            ? nil
            : "Enter a valid ISBN-10 or ISBN-13, or leave this field empty."
    }

    var optionalPublicationDate: Date? {
        includesPublicationDate ? publicationDate : nil
    }

    func optionalValue(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
