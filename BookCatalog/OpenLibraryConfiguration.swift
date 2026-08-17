import Foundation

enum OpenLibraryConfiguration {
    static var userAgent: String {
        Bundle.main.object(forInfoDictionaryKey: "OpenLibraryUserAgent") as? String
            ?? "BookCatalog/0.0.1 (contact: maintainer@example.com)"
    }
}
