import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

/// Provides lightweight XOR-based encryption for URL parameter storage.
///
/// Encoding process:
///   1. Generate a random 8-character alphanumeric salt.
///   2. XOR each byte of the data with the corresponding byte of the
///      salt (cycling through the salt).
///   3. Base64URL-encode the XOR result.
///   4. Prepend the salt: `<salt><base64url>`.
///
/// Decoding reverses the process using the salt from the first 8 characters.
class CryptoService {
  static const int _saltLength = 8;
  static const String _saltChars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

  CryptoService._();

  /// Encrypts [data] and returns the encoded string (salt + base64url).
  static String encrypt(Uint8List data) {
    final salt = _generateSalt();
    final saltBytes = utf8.encode(salt);
    final xored = _xor(data, saltBytes);
    return salt + base64Url.encode(xored);
  }

  /// Decrypts an encoded string produced by [encrypt].
  /// Throws [FormatException] if the input is malformed.
  static Uint8List decrypt(String encoded) {
    if (encoded.length <= _saltLength) {
      throw const FormatException('Encoded data is too short');
    }
    final salt = encoded.substring(0, _saltLength);
    final base64Part = encoded.substring(_saltLength);
    final saltBytes = utf8.encode(salt);
    final xored = base64Url.decode(base64Part);
    return Uint8List.fromList(_xor(xored, saltBytes));
  }

  static List<int> _xor(List<int> data, List<int> key) {
    return List.generate(
      data.length,
      (i) => data[i] ^ key[i % key.length],
    );
  }

  static String _generateSalt() {
    final random = Random.secure();
    return String.fromCharCodes(
      List.generate(
        _saltLength,
        (_) => _saltChars.codeUnitAt(random.nextInt(_saltChars.length)),
      ),
    );
  }
}
