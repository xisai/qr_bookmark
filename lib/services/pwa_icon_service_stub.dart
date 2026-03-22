/// No-op implementation for non-web platforms.
class PwaIconService {
  PwaIconService._();

  static void updateIcon(String dataUrl) {
    // No-op on non-web platforms.
  }

  static void updateManifestIcon(String dataUrl) {
    // No-op on non-web platforms.
  }

  static Future<void> updateManifestStartUrl() async {
    // No-op on non-web platforms.
  }

  /// Returns `false` so the caller falls back to go_router navigation.
  static bool navigateToPath(String path) => false;

  static String? _pendingPassphrase;

  /// Saves [passphrase] so it can be retrieved after navigation.
  static void savePassphrase(String passphrase) {
    _pendingPassphrase = passphrase;
  }

  /// Returns the stored passphrase (if any) and clears it.
  static String? consumePassphrase() {
    final value = _pendingPassphrase;
    _pendingPassphrase = null;
    return value;
  }

  static String? _pendingResizePassphrase;

  /// Saves [passphrase] for size-change navigation.
  static void saveResizePassphrase(String passphrase) {
    _pendingResizePassphrase = passphrase;
  }

  /// Returns the resize passphrase (if any) and clears it.
  static String? consumeResizePassphrase() {
    final value = _pendingResizePassphrase;
    _pendingResizePassphrase = null;
    return value;
  }
}
