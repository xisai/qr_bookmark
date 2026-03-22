import 'package:qr/qr.dart';

/// Result type for [QrUrlService.decode].
sealed class DecodeResult {}

/// Decoding succeeded and [qrImage] is ready to display.
final class DecodeSuccess extends DecodeResult {
  final QrImage qrImage;
  DecodeSuccess(this.qrImage);
}

/// The data is passphrase-protected and no passphrase was supplied.
final class DecodePassphraseRequired extends DecodeResult {}

/// A passphrase was supplied but it did not match the stored MAC.
final class DecodePassphraseWrong extends DecodeResult {}

/// The encoded data is malformed or otherwise undecodable.
final class DecodeInvalid extends DecodeResult {}
