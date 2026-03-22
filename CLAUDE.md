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
flutter build web --release  # Build for web deployment
flutter build apk      # Build Android APK (also: ios, linux, macos, windows)
```

## Commit rules

- **コミット前にバージョンを更新すること。** `lib/app_version.dart` の `kAppVersion` を
  `yyyyMMdd-N` 形式でインクリメントする（同日なら N を +1、日付が変わったら日付更新・N=1）。
- **コミット・プッシュは明示的に指示があった場合のみ行うこと。**

## Web deployment (web-pages branch)

web-pages ブランチには `flutter build web --release` のビルド成果物のみを格納する。
デプロイ手順：

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

web-pages ブランチの `.gitignore` はホワイトリスト方式（`*` で全除外 → 必要なファイルだけ許可）。
新たなファイルが `build/web/` に追加された場合は web-pages の `.gitignore` にも追記すること。

## Architecture

Flutter PWA web app. Routing is URL-driven via `go_router` with `usePathUrlStrategy()`
(path-based, no hash). State management uses plain `setState` (no external state library).

**File structure:**
```
lib/
  main.dart                         # App entry, usePathUrlStrategy(), GoRouter setup, MaterialApp.router
  app_version.dart                  # kAppVersion 定数 (yyyyMMdd-N)
  app_constants.dart                # UI調整用の定数クラス
  l10n/
    app_localizations.dart          # EN/JA strings via abstract class + two impl classes
  models/
    qr_data.dart                    # QrData model (type + content → bytes ↔ QrImage)
  services/
    crypto_service.dart             # XOR encrypt/decrypt + Base64URL + HMAC-SHA256
    qr_url_service.dart             # Encode/decode QrData ↔ URL path segments (passphrase対応)
    pwa_icon_service.dart           # Conditional export (web/stub)
    pwa_icon_service_web.dart       # apple-touch-icon更新 + SWへのQR URL/アイコン通知 + passphrase引き渡し
    pwa_icon_service_stub.dart      # No-op for non-web (passphrase引き渡しのみ実装)
  widgets/
    app_scaffold.dart               # Scaffold + hamburger drawer (all screens share this)
  screens/
    qr_generate_screen.dart         # "/" → input form
    qr_display_screen.dart          # "/qr/<encoded>[/<sizeSteps>]" → QR display + size buttons
    manual_screen.dart              # "/manual"
web/
  index.html                        # GitHub Pages SPAパス復元スクリプト + setQrStartUrl() / setQrIcon() 含む
  404.html                          # GitHub Pages SPA用リダイレクト
  flutter_bootstrap.js              # カスタムブートストラップ (sw.js を登録)
  sw.js                             # Service Worker: manifest.json インターセプト + QRアイコン配信 + Flutter SW委譲
  manifest.json                     # PWAマニフェスト
```

**Routing:**
- `/` → `QrGenerateScreen`
- `/qr/<encoded>` → `QrDisplayScreen` (sizeSteps = 0)
- `/qr/<encoded>/<sizeSteps>` → `QrDisplayScreen` (with size steps)
- `/manual` → `ManualScreen`
- 存在しないパス → `web/404.html` が `/?/...` にリダイレクト → `index.html` でパス復元

**URL encoding (no passphrase):**
1. Serialize `QrData` to bytes (type byte + content bytes)
2. XOR with repeating 8-char random salt
3. Base64URL-encode
4. Prepend salt → path segment `<encoded>`

**URL encoding (with passphrase):**
1. Serialize `QrData` to bytes
2. Compute HMAC-SHA256(key=passphrase, msg=bytes) → take first 8 bytes as MAC
3. XOR (MAC + bytes) with passphrase (repeating)
4. Prepend marker byte `0xFF`
5. Apply salt-XOR + Base64URL (same as above) → path segment `<encoded>`

On decode: marker byte `0xFF` triggers passphrase prompt; HMAC is verified before returning data.

**Passphrase handoff between screens:**
- Generate → Display (full-page nav): passphrase saved to `sessionStorage['qr_bookmark_passphrase']`, consumed in `initState` → `_DisplayState.autoUnlocked` (shows banner)
- Display → Display (size change, `context.replace`): passphrase saved to `sessionStorage['qr_bookmark_resize_passphrase']`, consumed in `initState` → `_DisplayState.unlocked` (no banner)
- URL direct access without passphrase: → `_DisplayState.locked` (shows passphrase input form)

**QR size control (`qr_display_screen.dart`):**
- Default size = 70 % of available width (`AppConstants.qrDefaultSizeRatio`)
- Each button press changes size by ±10 % (`AppConstants.qrSizeStepFactor`)
- Clamped to `[AppConstants.qrMinSize, maxWidth − AppConstants.qrHorizontalMargin]`
- サイズステップは URL パスの第2セグメントとして保持される

**PWA ホーム画面（iOS / Android）:**
- QR表示画面を開くと `_captureAndUpdatePwaIcon()` が以下を実行する：
  - **iOS**: `<link rel="apple-touch-icon">` の href をQR data URL に更新
  - **Android**: SW に `SET_QR_ICON` メッセージを送りQR PNG を CacheStorage へキャッシュ。blob manifest の `icons` を仮想 URL `/icons/qr-dynamic-icon.png` に切り替える（`_qrIconMode = true`）
  - **共通**: SW に `SET_QR_URL` メッセージを送り `manifest.json` の `start_url` をQR URLに書き換える
- SW (`sw.js`) のフェッチインターセプト：
  - `destination === 'manifest'` → `start_url` を書き換え、QRアイコンがキャッシュ済みなら `icons` も書き換える
  - `/icons/qr-dynamic-icon.png` → CacheStorage のQR PNG を返す（なければ `Icon-512.png` にフォールバック）
- blob manifest (`index.html` の `updatePwaManifest()`) は `_qrIconMode` フラグで icons を切り替える
- パスベースURLにより iOSがホーム画面追加時のURLを保持しやすくなっている
- フルページナビゲーション（QR生成画面へ戻る等）で `index.html` が再実行され `_qrIconMode` は自動リセットされる

**Key dependencies:**
- `pretty_qr_code: ^3.6.0` — QR rendering (`PrettyQrView`)
- `qr: ^3.0.0` — `QrCode` / `QrImage` lower-level API
- `go_router: ^17.1.0` — URL-based routing for web
- `flutter_web_plugins` (SDK) — `usePathUrlStrategy()`
- `flutter_localizations` (SDK) — Material/Cupertino locale delegates
