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
    }

    var optionalPublicationDate: Date? {
        includesPublicationDate ? publicationDate : nil
    }

    func optionalValue(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
