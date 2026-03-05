# SOS Light (iOS)

SOS Light is an emergency-focused iOS app with a one-tap SOS Morse light signal, compass/location tools, direction guidance, SOS diary notes, and a relax section with jokes. It is designed to keep core safety features fast and simple in stressful situations.

## 2-Minute Quick Start
1. Open `/Users/pieteryoshua/Desktop/Pieter iOS App/SOS Light/SOS Light.xcodeproj` in Xcode.
2. Select scheme `SOS Light`.
3. Choose an iPhone simulator (or physical iPhone for flashlight testing).
4. Press `Run`.

## Requirements
- macOS with Xcode 15.3+
- iOS deployment target: 15.3+
- SwiftUI + StoreKit 2 + CoreLocation

## What The App Does
- Sends SOS Morse distress signal using screen flash + device torch.
- Provides compass, location details, and direction-to-saved-location tools.
- Lets users write/export SOS diary notes and use a calm-down joke feature.

## Project Structure
- `SOS Light/App`: app entry and tab shell
- `SOS Light/Features/SOS`: SOS signal UI, sheet, view model, signal service
- `SOS Light/Features/Compass`: compass UI + compass location manager
- `SOS Light/Features/Direction`: direction UI + direction location handler
- `SOS Light/Features/Diary`: diary UI, model, persistence, info sheet
- `SOS Light/Features/Jokes`: joke model, relax UI, subscription/legal sheets
- `SOS Light/Features/Map`: map/location feature
- `SOS Light/Services/Store`: StoreKit subscription management

## Configuration
This project does not require API keys or `.env` files.

### In-App Purchase
- Product ID used in code: `com.soslight.fullversion`
- File: `/Users/pieteryoshua/Desktop/Pieter iOS App/SOS Light/SOS Light/Services/Store/SubscriptionManager.swift`
- Make sure this product exists in App Store Connect for full purchase flow tests.

### External Joke API
- Endpoint: `https://official-joke-api.appspot.com/random_joke`
- Used directly from app code (no API key required).

### Permissions
- Location permission is required for Compass/Direction.
- Usage description is defined in project build settings (`INFOPLIST_KEY_NSLocationWhenInUseUsageDescription`).

## How To Run (Detailed)
1. Open project in Xcode.
2. Set a Team under Signing if testing on physical device.
3. Run app.
4. On first run, allow Location permission for compass/direction features.
5. For flashlight SOS behavior, test on a physical iPhone (simulator has no torch).

## Quick Manual Test Flow (60 seconds)
1. SOS tab: start/stop SOS signal.
2. Compass tab: verify heading updates and copy details works.
3. Diary tab: create one note, then export.
4. Location tab: save location and verify distance/arrow updates.
5. Relax tab: fetch joke, show answer, open subscription sheet.

## Common Issues / Troubleshooting
- App builds but torch does not work:
  - Torch only works on a physical device with flash hardware.
- Compass/Direction not updating:
  - Check Location permission in iOS Settings for SOS Light.
- Subscription product not loading:
  - Confirm `com.soslight.fullversion` exists and is active in App Store Connect.
  - Use Sandbox test account for purchase/restore testing.
- Xcode error about simulator runtimes:
  - Install at least one iOS Simulator runtime from Xcode Settings > Platforms.
- Signing/provisioning errors on device:
  - Set your Apple Team in target Signing & Capabilities.

## Known Limitations
- Torch, heading quality, and location accuracy depend on device hardware/sensors.
- Joke fetching requires internet access.
- In-app purchase behavior depends on App Store Connect + Sandbox configuration.
