import Foundation
import SwiftData

@Model
final class AppSettings {
    var createdAt: Date

    init(createdAt: Date = .now) {
        self.createdAt = createdAt
    }
}
