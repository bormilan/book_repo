import SwiftData
import XCTest
@testable import BookCatalog

final class PersistenceControllerTests: XCTestCase {
    @MainActor
    func testCreatesAnInMemoryModelContainer() throws {
        let container = try PersistenceController.makeModelContainer(isStoredInMemoryOnly: true)

        XCTAssertNotNil(container.mainContext)
    }
}
