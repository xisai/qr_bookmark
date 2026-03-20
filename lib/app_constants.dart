/// App-wide layout and configuration constants.
///
/// UI調整が必要な場合はここの値を変更してください。
abstract final class AppConstants {
  // ---------------------------------------------------------------------------
  // QR表示画面
  // ---------------------------------------------------------------------------

  /// 拡大・縮小ボタン1回あたりのサイズ変化率（デフォルトサイズに対する割合）。
  static const double qrSizeStepFactor = 0.10;

  /// QRコードの最小表示サイズ（dp）。
  static const double qrMinSize = 80.0;

  /// QRコードのデフォルト表示サイズ（利用可能な最大幅に対する割合）。
  static const double qrDefaultSizeRatio = 0.7;

  /// QR表示領域の左右マージン合計（dp）。最大サイズの算出に使用。
  static const double qrHorizontalMargin = 32.0;

  /// QRコード周囲の余白（dp）。
  static const double qrPadding = 16.0;

  /// PWAアイコン用にQRコードをキャプチャする際のピクセル比。
  static const double pwaIconPixelRatio = 3.0;

  // ---------------------------------------------------------------------------
  // 共通レイアウト
  // ---------------------------------------------------------------------------

  /// 画面コンテンツの標準padding（dp）。
  static const double screenPadding = 16.0;

  /// 生成画面など、やや広めのpadding（dp）。
  static const double screenPaddingLarge = 24.0;

  /// フォーム要素間の標準的な縦スペース（dp）。
  static const double formSpacing = 16.0;

  /// フォームのボタン直前の縦スペース（dp）。
  static const double formButtonSpacing = 24.0;

  /// テキスト入力エリアの最小行数。
  static const int textInputMinLines = 4;

  /// 横並びボタン間のスペース（dp）。
  static const double buttonRowSpacing = 24.0;

  /// QRサイズ操作ボタンとQR画像の間の縦スペース（dp）。
  static const double qrButtonToImageSpacing = 16.0;
}
