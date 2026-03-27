import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Calls the global JS function `setQrStartUrl` defined in index.html.
@JS('setQrStartUrl')
external void _setQrStartUrl(String url);

/// Calls the global JS function `setQrIcon` defined in index.html.
@JS('setQrIcon')
external void _setQrIcon(String dataUrl);

/// Updates PWA home screen metadata on web platforms.
class PwaIconService {
  PwaIconService._();

  /// Replaces the `apple-touch-icon` link element's href with [dataUrl].
  static void updateIcon(String dataUrl) {
    final links = web.document.querySelectorAll('link[rel="apple-touch-icon"]');
    for (var i = 0; i < links.length; i++) {
      final el = links.item(i);
      if (el != null && el.isA<web.HTMLLinkElement>()) {
        (el as web.HTMLLinkElement).href = dataUrl;
      }
    }
  }

  /// SW に QR アイコンをキャッシュさせ、blob manifest の icons を切り替える（Android ホーム画面用）。
  static void updateManifestIcon(String dataUrl) {
    try {
      _setQrIcon(dataUrl);
    } catch (_) {
      // Silently ignore — manifest update is best-effort.
    }
  }

  /// Notifies the service worker of the current page URL so it can inject it
  /// as `start_url` in the manifest when the user adds the page to their
  /// home screen on iOS.
  static Future<void> updateManifestStartUrl() async {
    try {
      _setQrStartUrl(web.window.location.href);
    } catch (_) {
      // Silently ignore — manifest update is best-effort.
    }
  }

  /// Navigates to [path] via a full page load so that index.html re-runs and
  /// sets the correct manifest start_url immediately.
  /// Returns `true` to indicate navigation was handled by this method.
  static bool navigateToPath(String path) {
    web.window.location.href = path;
    return true;
  }

  /// Saves [passphrase] to sessionStorage so it survives a full-page reload.
  static void savePassphrase(String passphrase) {
    web.window.sessionStorage.setItem('qr_bookmark_passphrase', passphrase);
  }

  /// Returns the stored passphrase (if any) and removes it from sessionStorage.
  static String? consumePassphrase() {
    final value = web.window.sessionStorage.getItem('qr_bookmark_passphrase');
    web.window.sessionStorage.removeItem('qr_bookmark_passphrase');
    return value;
  }

  /// Saves [passphrase] for size-change navigation (separate key).
  static void saveResizePassphrase(String passphrase) {
    web.window.sessionStorage.setItem(
      'qr_bookmark_resize_passphrase',
      passphrase,
    );
  }

  /// Returns the resize passphrase (if any) and removes it from sessionStorage.
  static String? consumeResizePassphrase() {
    final value = web.window.sessionStorage.getItem(
      'qr_bookmark_resize_passphrase',
    );
    web.window.sessionStorage.removeItem('qr_bookmark_resize_passphrase');
    return value;
  }
}
