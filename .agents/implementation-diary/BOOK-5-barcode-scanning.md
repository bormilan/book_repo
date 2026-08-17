# BOOK-5: Barcode scanning

## Task

Implemented **BOOK-5: Implement barcode scanning**.

## What was implemented

- Added the camera privacy explanation to the generated app Info.plist.
- Added a scanner screen that requests camera access, displays a live camera
  preview with a visible scanning frame, and gives denied users a Settings
  link.
- Configured AVFoundation to receive EAN-13 barcodes only, then validated the
  ISBN prefix as `978` or `979`.
- Ignores unsupported values with a clear message and pauses the camera after
  the first valid ISBN in a scanning session.
- Added ISBN lookup to the local repository. An ISBN already in the catalog
  closes the scanner and opens that book's details. A new ISBN opens manual
  entry with the ISBN prefilled until metadata lookup is implemented.

## Tests

- Wrote validation tests first for accepted ISBN-13 values and malformed or
  unsupported barcodes.
- Added a malformed 14-character case that initially failed because the
  validator stripped non-digit characters; tightened validation to require
  exactly 13 digits.
- Ran `xcodebuild test -quiet -project BookCatalog.xcodeproj -scheme
  BookCatalog -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.6'`.
- Result: all 11 tests passed.

## Notes

- A simulator cannot exercise live camera capture. The physical-iPhone scan,
  permission-denial, and existing-ISBN flow remain explicitly tracked in the
  complete-flow testing task.
- The AVFoundation configuration follows Apple's documented EAN-13 metadata
  type filtering and explicit video-access request APIs.
