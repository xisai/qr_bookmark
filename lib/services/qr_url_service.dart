import 'dart:typed_data';

import '../models/decode_result.dart';
import '../models/qr_data.dart';
import 'crypto_service.dart';

/// パスフレーズ保護の識別マーカーバイト。
const int _passphraseMarker = 0xFF;

/// HMAC長（バイト）。
const int _macLength = 8;

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
  ///
  /// When [passphrase] is provided (non-null, non-empty), the payload is
  /// protected with an 8-byte HMAC-SHA256 prefix and XOR-encrypted with
  /// the passphrase, then prefixed with [_passphraseMarker] (0xFF).
  static String encode(QrData data, {String? passphrase}) {
    final inner = data.toBytes();
    if (passphrase == null || passphrase.isEmpty) {
      return CryptoService.encrypt(inner);
    }
    final mac = CryptoService.computeHmac(inner, passphrase);
    final plaintext = Uint8List(mac.length + inner.length)
      ..setRange(0, mac.length, mac)
      ..setRange(mac.length, mac.length + inner.length, inner);
    final passphrased = CryptoService.xorWithPassphrase(plaintext, passphrase);
    final withMarker = Uint8List(1 + passphrased.length)
      ..[0] = _passphraseMarker
      ..setRange(1, 1 + passphrased.length, passphrased);
    return CryptoService.encrypt(withMarker);
  }

  /// Decodes a URL parameter value string back into a [DecodeResult].
  ///
  /// - [DecodeSuccess] — decoding succeeded.
  /// - [DecodePassphraseRequired] — data is passphrase-protected and no
  ///   [passphrase] was supplied.
  /// - [DecodePassphraseWrong] — [passphrase] was supplied but did not match.
  /// - [DecodeInvalid] — the data is malformed.
  static DecodeResult decode(String? paramValue, {String? passphrase}) {
    if (paramValue == null || paramValue.isEmpty) return DecodeInvalid();
    try {
      final bytes = CryptoService.decrypt(paramValue);
      if (bytes.isEmpty) return DecodeInvalid();

      if (bytes[0] == _passphraseMarker) {
        // Passphrase-protected payload.
        if (passphrase == null || passphrase.isEmpty) {
          return DecodePassphraseRequired();
        }
        final passphrased = bytes.sublist(1);
        final plaintext = CryptoService.xorWithPassphrase(passphrased, passphrase);
        if (plaintext.length <= _macLength) return DecodePassphraseWrong();
        final mac = plaintext.sublist(0, _macLength);
        final inner = plaintext.sublist(_macLength);
        if (!CryptoService.verifyHmac(mac, inner, passphrase)) {
          return DecodePassphraseWrong();
        }
        return _buildSuccess(inner);
      } else {
        // No passphrase — plain payload.
        return _buildSuccess(bytes);
      }
    } catch (_) {
      return DecodeInvalid();
    }
  }

  static DecodeResult _buildSuccess(Uint8List inner) {
    try {
      final data = QrData.fromBytes(inner);
      return DecodeSuccess(data.toQrImage());
    } catch (_) {
      return DecodeInvalid();
    }
  }
}
