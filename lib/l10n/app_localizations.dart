import 'package:flutter/widgets.dart';

/// Provides localized strings for the app.
/// Supports English (default) and Japanese.
abstract class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'ja') return const _JaLocalizations();
    return const _EnLocalizations();
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // App
  String get appTitle;

  // Screen titles
  String get generateScreenTitle;
  String get displayScreenTitle;
  String get manualScreenTitle;
  String get licenseScreenTitle;

  // Input type
  String get typeText;
  String get typeBinary;

  // Input hints
  String get hintText;
  String get hintBinary;

  // Buttons
  String get generateButton;
  String get enlargeTooltip;
  String get shrinkTooltip;

  // Errors
  String get errorEmptyInput;
  String get errorInvalidHex;
  String get errorQrDataTooLarge;
  String get errorInvalidQrData;

  // Navigation drawer
  String get menuGenerate;
  String get menuManual;
  String get menuLicense;

  // Manual screen
  String get manualContent;
}

class _EnLocalizations implements AppLocalizations {
  const _EnLocalizations();

  @override
  String get appTitle => 'QR Bookmark';

  @override
  String get generateScreenTitle => 'Generate QR';

  @override
  String get displayScreenTitle => 'QR Code';

  @override
  String get manualScreenTitle => 'Manual';

  @override
  String get licenseScreenTitle => 'Licenses';

  @override
  String get typeText => 'Text';

  @override
  String get typeBinary => 'Binary';

  @override
  String get hintText => 'Enter text to encode';

  @override
  String get hintBinary => 'Enter hex string (e.g. BEEFFEEB01)';

  @override
  String get generateButton => 'Generate QR';

  @override
  String get enlargeTooltip => 'Enlarge';

  @override
  String get shrinkTooltip => 'Shrink';

  @override
  String get errorEmptyInput => 'Please enter data.';

  @override
  String get errorInvalidHex =>
      'Invalid hex string. Use 0–9, A–F with an even number of characters.';

  @override
  String get errorQrDataTooLarge => 'Data is too large for a QR code.';

  @override
  String get errorInvalidQrData => 'Invalid QR data.';

  @override
  String get menuGenerate => 'Generate QR';

  @override
  String get menuManual => 'Manual';

  @override
  String get menuLicense => 'Licenses';

  @override
  String get manualContent => '''How to Use

## Creating a QR Code
1. Select the input type: Text or Binary.
2. Enter the data you want to encode.
   - Text: Any UTF-8 text.
   - Binary: A hex string (e.g. BEEFFEEB01). Must be an even number of characters using 0–9 and A–F.
3. Tap "Generate QR" to create the QR code.

## Adjusting QR Size
Use the + and − buttons on the QR Code screen to enlarge or shrink the displayed QR code. The image is regenerated at each step.

## Bookmarking a QR Code
The QR data is stored in the URL. Bookmark the current URL to save your QR code — opening the bookmark will restore it instantly.

## Adding to Home Screen (PWA)
On iOS or Android, use your browser's "Add to Home Screen" option.
- If added after generating a QR code, that QR code becomes the home screen icon.
- If added from the Generate screen, the default app icon is used.''';
}

class _JaLocalizations implements AppLocalizations {
  const _JaLocalizations();

  @override
  String get appTitle => 'QRブックマーク';

  @override
  String get generateScreenTitle => 'QR生成';

  @override
  String get displayScreenTitle => 'QRコード';

  @override
  String get manualScreenTitle => 'マニュアル';

  @override
  String get licenseScreenTitle => '権利表記';

  @override
  String get typeText => 'テキスト';

  @override
  String get typeBinary => 'バイナリ';

  @override
  String get hintText => 'エンコードするテキストを入力';

  @override
  String get hintBinary => '16進数文字列を入力 (例: BEEFFEEB01)';

  @override
  String get generateButton => 'QR生成';

  @override
  String get enlargeTooltip => '拡大';

  @override
  String get shrinkTooltip => '縮小';

  @override
  String get errorEmptyInput => 'データを入力してください。';

  @override
  String get errorInvalidHex =>
      '無効な16進数文字列です。0〜9、A〜Fの文字を偶数桁で入力してください。';

  @override
  String get errorQrDataTooLarge => 'データがQRコードの容量を超えています。';

  @override
  String get errorInvalidQrData => 'QRデータが無効です。';

  @override
  String get menuGenerate => 'QR生成';

  @override
  String get menuManual => 'マニュアル';

  @override
  String get menuLicense => '権利表記';

  @override
  String get manualContent => '''使用方法

## QRコードの作成
1. 入力タイプを選択します（テキストまたはバイナリ）。
2. エンコードしたいデータを入力します。
   - テキスト：UTF-8テキストを入力してください。
   - バイナリ：16進数文字列を入力してください（例: BEEFFEEB01）。0〜9、A〜Fの文字を偶数桁で入力する必要があります。
3. 「QR生成」ボタンをタップしてQRコードを生成します。

## QRコードのサイズ調整
QRコード画面の＋・−ボタンで表示サイズを拡大・縮小できます。ボタンを押すたびに画像が再生成されます。

## QRコードのブックマーク
QRデータはURLに格納されています。現在のURLをブックマークすることでQRコードを保存できます。ブックマークを開くと、QRコードが即座に表示されます。

## ホーム画面への追加（PWA）
iOSまたはAndroidのブラウザで「ホーム画面に追加」を使用できます。
- QRコードを生成した後に追加すると、そのQRコードがホーム画面のアイコンになります。
- QR生成画面から追加した場合は、デフォルトのアプリアイコンが使用されます。''';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ja'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    if (locale.languageCode == 'ja') return const _JaLocalizations();
    return const _EnLocalizations();
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
