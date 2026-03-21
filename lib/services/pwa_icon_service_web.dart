// ignore: deprecated_member_use
import 'dart:html' as html;
import 'dart:js_interop';

/// Calls the global JS function `setQrStartUrl` defined in index.html.
@JS('setQrStartUrl')
external void _setQrStartUrl(String url);

/// Updates PWA home screen metadata on web platforms.
class PwaIconService {
  PwaIconService._();

  /// Replaces the `apple-touch-icon` link element's href with [dataUrl].
  static void updateIcon(String dataUrl) {
    final links = html.document
        .querySelectorAll('link[rel="apple-touch-icon"]')
        .cast<html.LinkElement>();
    for (final link in links) {
      link.href = dataUrl;
    }
  }

  /// Notifies the service worker of the current page URL so it can inject it
  /// as `start_url` in the manifest when the user adds the page to their
  /// home screen on iOS.
  static Future<void> updateManifestStartUrl() async {
    try {
      _setQrStartUrl(html.window.location.href);
    } catch (_) {
      // Silently ignore — manifest update is best-effort.
    }
  }

  /// Navigates to [path] via a full page load so that index.html re-runs and
  /// sets the correct manifest start_url immediately.
  /// Returns `true` to indicate navigation was handled by this method.
  static bool navigateToPath(String path) {
    html.window.location.href = path;
    return true;
  }
}
