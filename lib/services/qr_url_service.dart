import '../models/qr_data.dart';
import 'crypto_service.dart';

/// Converts [QrData] to/from URL path segments.
///
/// Display path format: `/qr/<encodedData>` or `/qr/<encodedData>/<sizeSteps>`
class QrUrlService {
  QrUrlService._();

  /// Builds the display URL path for the given [encodedData] and [sizeSteps].
  /// [sizeSteps] is omitted from the URL when it is 0 (default size).
  static String buildDisplayPath(String encodedData, int sizeSteps) {
    return sizeSteps != 0 ? '/qr/$encodedData/$sizeSteps' : '/qr/$encodedData';
  }

  /// Encodes [data] into a URL parameter value string.
  static String encode(QrData data) {
    return CryptoService.encrypt(data.toBytes());
  }

  /// Decodes a URL parameter value string back into [QrData].
  /// Returns `null` if decoding fails (invalid or tampered data).
  static QrData? decode(String? paramValue) {
    if (paramValue == null || paramValue.isEmpty) return null;
    try {
      final bytes = CryptoService.decrypt(paramValue);
      return QrData.fromBytes(bytes);
    } catch (_) {
      return null;
    }
  }
}
