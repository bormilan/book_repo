# BOOK-3: Collection and book-details screens

## Task

Implemented GitHub issue #3, **BOOK-3: Build collection and book-details
screens**.

## What was implemented

- Made the collection the app home screen, backed by a SwiftData `@Query` in
  ascending title order.
- Added rows that show each book's title and author when present.
- Added the empty state with **Scan book** and **Add manually** actions. Those
  actions explain that their workflows arrive in later tasks rather than doing
  nothing.
- Added a read-only book-details screen showing saved metadata and date added.
- Added a destructive delete action that requires confirmation, saves the
  deletion, and returns to the collection.
- Made the repository's `fetchAll()` ordering deterministic so data-layer
  consumers receive books in ascending title order too.

## Tests

- Wrote `testFetchesBooksInAscendingTitleOrder` first; it failed before the
  sorting implementation because fetched books were in insertion order.
- Ran `xcodebuild test -project BookCatalog.xcodeproj -scheme BookCatalog
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.6'`.
- Result: 7 tests passed, including existing deletion and persistence coverage.
- Launched the app in the iPhone 16 Pro simulator and visually checked the
  empty collection state and its two actions.

## Notes

- The Scan book and Add manually controls intentionally show a short
  availability message until their respective implementation tasks are
  completed.
