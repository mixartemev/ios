# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

This is an Xcode project with no external dependencies. Open `qr.xcodeproj` in Xcode.

```bash
# Build from command line
xcodebuild -project qr.xcodeproj -scheme qr -sdk iphonesimulator build

# Build for device
xcodebuild -project qr.xcodeproj -scheme qr -sdk iphoneos build
```

No tests or linting are configured.

## Architecture

Minimal iOS QR code scanner — single-screen SwiftUI app using AVFoundation for camera capture.

- **`qr/ContentView.swift`** — Contains all app logic in one file:
  - `QRScannerApp` — App entry point (`@main`)
  - `ContentView` — Main screen with scan button and result display
  - `ScannerView` — `UIViewControllerRepresentable` bridge to UIKit camera
  - `ScannerVC` — `AVCaptureSession`-based QR code reader with `AVCaptureMetadataOutputObjectsDelegate`
- **`qr/qrApp.swift`** — Xcode-generated app entry point (unused; `@main` is in ContentView.swift)

## Key Details

- UI strings are in Russian
- Requires camera permission at runtime (no Info.plist `NSCameraUsageDescription` key yet — needed for App Store)
- Bundle ID: `com.xync.qr`
- Swift 5.0, strict concurrency (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`)
- Targets iPhone and iPad
