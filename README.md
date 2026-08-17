# Book Catalog

An iPhone app for cataloging personal books by ISBN barcode. It stores the
catalog locally, uses Open Library for metadata lookup, and does not store
cover images.

## Requirements

- macOS with Xcode 16 or later
- iOS 17 or later Simulator or iPhone
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

## First-time setup

1. Copy the local configuration template:

   ```bash
   cp Config.xcconfig.example Config.xcconfig
   ```

2. In `Config.xcconfig`, replace `your-email@example.com` with an address you
   are comfortable sending to Open Library as part of the HTTP `User-Agent`.
   This file is ignored by Git and must not be committed.

3. Generate the Xcode project:

   ```bash
   xcodegen generate
   ```

4. Open `BookCatalog.xcodeproj` in Xcode.

5. Select an iPhone Simulator and press `⌘R` to build and run.

## Running on an iPhone

1. Connect and unlock your iPhone, then trust the Mac when prompted.
2. In Xcode, select the **BookCatalog** target → **Signing & Capabilities**.
3. Enable **Automatically manage signing** and select your development team.
4. Choose the iPhone as the run destination and press `⌘R`.
5. Enable Developer Mode on the iPhone if iOS requests it, then trust your
   personal development certificate under **Settings → General → VPN & Device
   Management**.

The camera scanner requires a physical iPhone; the Simulator cannot validate
live camera capture.

## Tests

Run the automated suite from Xcode with `⌘U`, or from Terminal:

```bash
xcodebuild test -project BookCatalog.xcodeproj -scheme BookCatalog \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.6'
```

## Planning notes

The product notes and versioned specifications start at [root.md](root.md).
