import '../models/qr_data.dart';
import 'crypto_service.dart';

/// Converts [QrData] to/from a URL query parameter value.
///
/// The parameter name is [paramName]. Its value is the encrypted
/// representation of the serialized [QrData].
class QrUrlService {
  static const String paramName = 'd';

  QrUrlService._();

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
