# BOOK-2 — Local book catalog data layer

## Work completed

- Replaced the temporary app-settings model with the SwiftData `Book` model.
- Added required title plus optional author text, ISBN, publisher, publication
  date, language, description, and date-added fields.
- Added `BookRepository` for creating, fetching, and deleting books.
- Normalized ISBNs before storage and rejected duplicate non-empty ISBNs.
- Updated the persistent model container to use the `Book` schema and support
  temporary on-disk stores for persistence tests.

## Tests

- Added failing tests first for title-only save, duplicate ISBN prevention, and
  persistence after reopening the store.
- Added coverage for optional metadata and deletion.
- Ran `xcodebuild test -project BookCatalog.xcodeproj -scheme BookCatalog
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.6'`.
- Result: 6 tests passed with 0 failures.

## Notes and follow-up

- Author data is stored as a single display string for this version. See
  [[.agents/decision-requests/BOOK-2-author-storage]] for the decision.
- The simulator was reset once because an earlier pre-release schema used an
  incompatible temporary author-array attribute; no user data existed.
