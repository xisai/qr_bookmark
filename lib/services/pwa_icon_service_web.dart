// ignore: deprecated_member_use
import 'dart:html' as html;

/// Updates the PWA home screen icon on web platforms.
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
}
