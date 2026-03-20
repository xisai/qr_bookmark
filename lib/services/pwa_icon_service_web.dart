// ignore: deprecated_member_use
import 'dart:html' as html;
import 'dart:convert';

/// Updates PWA home screen metadata on web platforms.
class PwaIconService {
  PwaIconService._();

  /// Replaces the `apple-touch-icon` link element's href with [dataUrl].
  /// This takes effect the next time the user adds the page to their
  /// home screen on iOS. On Android, the manifest is used at install time.
  static void updateIcon(String dataUrl) {
    final links = html.document
        .querySelectorAll('link[rel="apple-touch-icon"]')
        .cast<html.LinkElement>();
    for (final link in links) {
      link.href = dataUrl;
    }
  }

  /// Updates the manifest's `start_url` to the current page URL so that
  /// iOS uses the correct URL (including QR data in the hash fragment) when
  /// launching the app from the home screen icon.
  ///
  /// The existing manifest.json is fetched, `start_url` is overwritten with
  /// the current [html.window.location.href], and the updated manifest is
  /// re-served as a Blob URL attached to `<link rel="manifest">`.
  /// Errors are silently ignored — this update is best-effort.
  static Future<void> updateManifestStartUrl() async {
    try {
      final currentUrl = html.window.location.href;
      final manifestStr =
          await html.HttpRequest.getString('manifest.json');
      final manifest =
          Map<String, dynamic>.from(jsonDecode(manifestStr) as Map);
      manifest['start_url'] = currentUrl;

      final blob =
          html.Blob([jsonEncode(manifest)], 'application/json');
      final blobUrl = html.Url.createObjectUrl(blob);

      final link = html.document.querySelector('link[rel="manifest"]')
          as html.LinkElement?;
      if (link != null) {
        final previous = link.href;
        if (previous.startsWith('blob:')) {
          html.Url.revokeObjectUrl(previous);
        }
        link.href = blobUrl;
      }
    } catch (_) {
      // Silently ignore — manifest update is best-effort.
    }
  }
}
