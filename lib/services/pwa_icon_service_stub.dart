/// No-op implementation for non-web platforms.
class PwaIconService {
  PwaIconService._();

  static void updateIcon(String dataUrl) {
    // No-op on non-web platforms.
  }

  static Future<void> updateManifestStartUrl() async {
    // No-op on non-web platforms.
  }
}
