# BOOK-11 — Home-screen app version

## Task

GitHub issue #18: show the installed app version on the home screen.

## What was implemented

- Configured marketing version `0.0.2` and build number `1` in the XcodeGen
  source configuration and generated Xcode project.
- Added a small bottom label that remains visible for empty and populated
  collections.
- Read the displayed marketing version and build number from the app bundle.
- Added a VoiceOver label and a deterministic fallback when bundle version
  values are unavailable.

## Tests

- Added tests for version/build formatting and missing-value fallback.
- Ran the full simulator suite with `xcodebuild test`; all 21 tests passed.
- Inspected the built app's Info.plist and verified version `0.0.2`, build `1`.

## Design choices and limitations

- The version label shares the bottom safe-area inset with transient Open
  Library import feedback, keeping both controls visible without covering the
  collection.
- Final physical-iPhone verification remains in the version 0.0.2 release
  checklist.
