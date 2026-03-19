import 'dart:convert';
import 'dart:typed_data';

import 'package:qr/qr.dart';

enum QrInputType { text, binary }

/// Holds the data used to generate a QR code.
///
/// [type] determines whether [content] is a plain UTF-8 string (text)
/// or a hex string representing raw bytes (binary).
class QrData {
  final QrInputType type;
  final String content;

  const QrData({required this.type, required this.content});

  /// Serializes this object to bytes for encryption and URL storage.
  /// Format: first byte = type marker (0x00 = text, 0x01 = binary),
  /// followed by the content bytes.
  Uint8List toBytes() {
    if (type == QrInputType.text) {
      return Uint8List.fromList([0x00, ...utf8.encode(content)]);
    } else {
      return Uint8List.fromList([0x01, ..._hexToBytes(content)]);
    }
  }

  /// Restores a [QrData] from previously serialized bytes.
  factory QrData.fromBytes(Uint8List bytes) {
    if (bytes.isEmpty) throw const FormatException('Empty data');
    final isText = bytes[0] == 0x00;
    final payload = bytes.sublist(1);
    if (isText) {
      return QrData(type: QrInputType.text, content: utf8.decode(payload));
    } else {
      return QrData(type: QrInputType.binary, content: _bytesToHex(payload));
    }
  }

  /// Creates a [QrImage] for rendering.
  ///
  /// Text uses [QrCode.fromData]; binary uses [QrCode.fromUint8List] so that
  /// raw bytes are stored as-is in QR byte mode.
  /// Throws [InputTooLongException] if the data exceeds QR capacity.
  QrImage toQrImage() {
    final QrCode qrCode;
    if (type == QrInputType.text) {
      qrCode = QrCode.fromData(
        data: content,
        errorCorrectLevel: QrErrorCorrectLevel.M,
      );
    } else {
      qrCode = QrCode.fromUint8List(
        data: Uint8List.fromList(_hexToBytes(content)),
        errorCorrectLevel: QrErrorCorrectLevel.M,
      );
    }
    return QrImage(qrCode);
  }

  static List<int> _hexToBytes(String hex) {
    final result = <int>[];
    for (int i = 0; i < hex.length; i += 2) {
      result.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return result;
  }

  static String _bytesToHex(List<int> bytes) {
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join();
  }
}
