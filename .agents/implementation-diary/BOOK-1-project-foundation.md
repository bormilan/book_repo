# BOOK-1 — Project foundation

## Work completed

- Created a reproducible XcodeGen project for an iOS 17+ SwiftUI app named
  Book Catalog.
- Added a SwiftData model container backed by a minimal app-settings model.
- Added an empty-state app screen and generated `BookCatalog.xcodeproj`.
- Added an Xcode and local-configuration `.gitignore`.
- Added configurable Open Library `User-Agent` build settings and an ignored
  configuration example.

## Tests

- Added `PersistenceControllerTests.testCreatesAnInMemoryModelContainer`.
- Ran the test before production sources existed; it failed because the
  `BookCatalog` module and persistence controller had not been implemented.
- Ran `xcodebuild test -project BookCatalog.xcodeproj -scheme BookCatalog
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.6'` after the
  implementation; it passed.
- Installed and launched the app in the iPhone 16 Pro simulator successfully.

## Notes and follow-up

- The book-specific SwiftData model intentionally belongs to BOOK-2.
- See [[.agents/decision-requests/BOOK-1-foundation-defaults]] for provisional
  bundle-identifier and Open Library contact configuration decisions.
