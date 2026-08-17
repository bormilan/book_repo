# BOOK-4: Manual book creation

## Task

Implemented **BOOK-4: Add manual book creation**.

## What was implemented

- Added `ManualBookDraft`, which contains the form values, title validation,
  optional-value handling, and a prefilled ISBN initializer.
- Added a manual book form for title, author(s), ISBN, publisher, optional
  publication date, language, and description.
- Wired **Add manually** from both the empty collection state and the
  collection toolbar to present the form.
- Disabled Save until a nonblank title is provided. Save creates a local book,
  dismisses the form, and lets the alphabetically sorted collection update.
- Added Cancel and duplicate-ISBN error handling.

## Tests

- Wrote failing tests first for nonblank-title validation and retaining a
  prefilled ISBN.
- Ran `xcodebuild test -quiet -project BookCatalog.xcodeproj -scheme
  BookCatalog -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.6'`.
- Result: all 9 tests passed.

## Notes

- The prefilled-ISBN initializer is ready for the barcode lookup fallback in
  a later task, even though scanning has not been implemented yet.
