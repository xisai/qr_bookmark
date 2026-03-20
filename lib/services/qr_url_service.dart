import '../models/qr_data.dart';
import 'crypto_service.dart';

/// Converts [QrData] to/from URL query parameters.
///
/// [paramName] holds the encrypted QR data.
/// [sizeParamName] holds the QR display size step (plain integer, not encrypted).
class QrUrlService {
  static const String paramName = 'd';
  static const String sizeParamName = 's';

  QrUrlService._();

  /// Builds the display URL path for the given [encodedData] and [sizeSteps].
  /// [sizeSteps] is omitted from the URL when it is 0 (default size).
  static String buildDisplayPath(String encodedData, int sizeSteps) {
    final sizeQuery =
        sizeSteps != 0 ? '&$sizeParamName=$sizeSteps' : '';
    return '/?$paramName=$encodedData$sizeQuery';
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
