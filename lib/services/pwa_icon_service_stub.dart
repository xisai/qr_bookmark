/// No-op implementation for non-web platforms.
class PwaIconService {
  PwaIconService._();

  static void updateIcon(String dataUrl) {
    // No-op on non-web platforms.
  }

  static Future<void> updateManifestStartUrl() async {
    // No-op on non-web platforms.
  }

  /// Returns `false` so the caller falls back to go_router navigation.
  static bool navigateToPath(String path) => false;
}
