# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

See [PROJECT.md](./PROJECT.md) for project overview and goals.
生成するコードはメンテナンス性を重視すること.

## Commands

```bash
flutter pub get        # Install dependencies
flutter run            # Run the app
flutter test           # Run all tests
flutter test test/widget_test.dart  # Run a single test file
flutter analyze        # Lint (uses flutter_lints)
flutter build apk      # Build Android APK (also: ios, web, linux, macos, windows)
```

## Architecture

Flutter PWA web app. Routing is URL-driven via `go_router`. State management uses plain `setState` (no external state library).

**File structure:**
```
lib/
  main.dart                         # App entry, GoRouter setup, MaterialApp.router
  l10n/
    app_localizations.dart          # EN/JA strings via abstract class + two impl classes
  models/
    qr_data.dart                    # QrData model (type + content → bytes ↔ QrImage)
  services/
    crypto_service.dart             # XOR encrypt/decrypt + Base64URL
    qr_url_service.dart             # Encode/decode QrData ↔ URL query param "d"
    pwa_icon_service.dart           # Conditional export (web/stub)
    pwa_icon_service_web.dart       # dart:html: update <link rel="apple-touch-icon">
    pwa_icon_service_stub.dart      # No-op for non-web
  widgets/
    app_scaffold.dart               # Scaffold + hamburger drawer (all screens share this)
  screens/
    qr_generate_screen.dart         # "/" with no param → input form
    qr_display_screen.dart          # "/?d=<encoded>" → QR display + size buttons
    manual_screen.dart              # "/manual"
    license_screen.dart             # "/license" — uses LicenseRegistry
```

**Routing:**
- `/` (no `d` param) → `QrGenerateScreen`
- `/?d=<encoded>` → `QrDisplayScreen`
- `/manual` → `ManualScreen`
- `/license` → `LicenseScreen`

**URL parameter encoding:**
1. Serialize `QrData` to bytes (type byte + content bytes)
2. XOR with repeating 8-char random salt
3. Base64URL-encode
4. Prepend salt → value of query param `d`

**QR size control (`qr_display_screen.dart`):**
- Default size = 70 % of available width
- Each button press multiplies by `(1 ± _kSizeStepFactor)` — currently `0.10` (10 %)
- Clamped to `[_kMinQrSize, maxWidth − 32]`
- Change `_kSizeStepFactor` at the top of the file to adjust step size

**Key dependencies:**
- `pretty_qr_code: ^3.6.0` — QR rendering (`PrettyQrView`)
- `qr: ^3.0.0` — `QrCode` / `QrImage` lower-level API
- `go_router: ^14.0.0` — URL-based routing for web
- `flutter_localizations` (SDK) — Material/Cupertino locale delegates
