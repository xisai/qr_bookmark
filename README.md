# QR Bookmark

A Flutter PWA that generates QR codes from text or binary data and stores them in the URL — so you can bookmark any QR code and restore it instantly.

**Demo:** https://qrbookmark.astralsystem.com/

## Features

- **Text / Binary input** — encode UTF-8 text or hex strings (e.g. `BEEFFEEB01`)
- **URL-based persistence** — QR data is embedded in the page URL; bookmark it to save your QR code
- **Passphrase protection** — optionally encrypt the QR data with a passphrase (6+ chars); only users who know the passphrase can view the QR code
- **Resizable QR display** — enlarge or shrink the QR image with + / − buttons; size is preserved in the URL
- **PWA support** — installable on iOS / Android home screen; the QR image becomes the home screen icon

## Usage

1. Open the app and select input type (Text or Binary).
2. Enter the data to encode.
3. Optionally enter a passphrase to protect the QR code.
4. Tap **Generate QR**.
5. Bookmark the URL to save the QR code permanently.

## Development

```bash
flutter pub get          # Install dependencies
flutter run              # Run (Chrome recommended for web)
flutter test             # Run tests
flutter analyze          # Lint
flutter build web --release  # Production web build
```

## Deployment

The `web-pages` branch hosts the built web app (GitHub Pages).

```bash
flutter build web --release
git stash
git checkout web-pages
cp -r build/web/. .
git add -A
git commit -m "web build"
git push origin web-pages
git checkout main
git stash pop
```

## Tech Stack

- [Flutter](https://flutter.dev/) — cross-platform UI framework
- [go_router](https://pub.dev/packages/go_router) — URL-driven routing with path strategy
- [pretty_qr_code](https://pub.dev/packages/pretty_qr_code) — QR rendering
- Service Worker — intercepts `manifest.json` to set `start_url` dynamically; caches QR PNG as a virtual URL for Android home screen icon

## License

See [LICENSE](./LICENSE).
