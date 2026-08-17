# BOOK-6: Open Library integration

## Task

Implemented **BOOK-6: Integrate Open Library metadata lookup**.

## What was implemented

- Added an isolated `OpenLibraryClient` for Open Library ISBN requests.
- Requests use the configured identifying `User-Agent`.
- Decoded title, author names, publisher, publication date when parseable,
  language, and description from the first matching response.
- Connected unknown scanned ISBNs to the client with a visible loading state.
- Automatically saves the first successful result and returns to the updated
  collection without a confirmation screen.
- Opens manual entry with the scanned ISBN prefilled after a lookup error or no
  result.

## Tests

- Wrote the request test first, verifying the Open Library host and configured
  User-Agent before adding the client implementation.
- Ran `xcodebuild test -quiet -project BookCatalog.xcodeproj -scheme
  BookCatalog -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.6'`.
- Result: all 12 tests passed.

## Notes

- The physical-device scan-and-lookup path remains part of the complete-flow
  test task, along with offline behavior.
