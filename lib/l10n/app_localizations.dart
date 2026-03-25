import 'package:flutter/widgets.dart';

import '../app_constants.dart';

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

  // Passphrase
  String get hintPassphrase;
  String get errorPassphraseTooShort;
  String get errorPassphraseWrong;
  String get passphrasePrompt;
  String get showQrButton;
  String get passphraseSetMessage;

  // Errors
  String get errorEmptyInput;
  String get errorInvalidHex;
  String get errorQrDataTooLarge;
  String get errorTextTooLarge;
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
  String get hintText => 'Enter text for QR code';

  @override
  String get hintBinary => 'Enter hex string (e.g. BEEFFEEB01)';

  @override
  String get generateButton => 'Generate QR';

  @override
  String get enlargeTooltip => 'Enlarge';

  @override
  String get shrinkTooltip => 'Shrink';

  @override
  String get hintPassphrase => 'Passphrase (optional, min 6 chars)';

  @override
  String get errorPassphraseTooShort =>
      'Passphrase must be at least 6 characters.';

  @override
  String get errorPassphraseWrong => 'Incorrect passphrase.';

  @override
  String get passphrasePrompt =>
      'Enter the passphrase to view this QR code.';

  @override
  String get showQrButton => 'Show QR';

  @override
  String get passphraseSetMessage => 'Passphrase has been set.';

  @override
  String get errorEmptyInput => 'Please enter data.';

  @override
  String get errorInvalidHex =>
      'Invalid hex string. Use 0–9, A–F with an even number of characters.';

  @override
  String get errorQrDataTooLarge => 'Data is too large for a QR code.';

  @override
  String get errorTextTooLarge =>
      'Text exceeds ${AppConstants.maxQrContentBytes} bytes (QR limit).';

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
   - Text: Any UTF-8 text (up to ${AppConstants.maxQrContentBytes} bytes).
   - Binary: A hex string (e.g. BEEFFEEB01). Must be an even number of characters using 0–9 and A–F (up to ${AppConstants.maxBinaryHexChars} characters = ${AppConstants.maxQrContentBytes} bytes).
3. Optionally enter a passphrase (6 characters or more) to protect the QR code.
4. Tap "Generate QR" to create the QR code.

## Passphrase Protection
If you set a passphrase, the QR data in the URL cannot be decoded without it. Anyone who opens the URL will be prompted to enter the passphrase before the QR code is shown. Leave the passphrase field empty if you do not need protection.

## Adjusting QR Size
Use the + and − buttons on the QR Code screen to enlarge or shrink the displayed QR code. The image is regenerated at each step.

## Bookmarking a QR Code
The QR data is stored in the URL. Bookmark the current URL to save your QR code — opening the bookmark will restore it instantly. If a passphrase was set, you will need to enter it each time you open the bookmark.

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
  String get hintText => 'QRコードにするテキストを入力';

  @override
  String get hintBinary => '16進数文字列を入力 (例: BEEFFEEB01)';

  @override
  String get generateButton => 'QR生成';

  @override
  String get enlargeTooltip => '拡大';

  @override
  String get shrinkTooltip => '縮小';

  @override
  String get hintPassphrase => 'あいことば（任意・6文字以上）';

  @override
  String get errorPassphraseTooShort => 'あいことばは6文字以上入力してください。';

  @override
  String get errorPassphraseWrong => 'あいことばが違います。';

  @override
  String get passphrasePrompt => 'QRコードを表示するにはあいことばを入力してください。';

  @override
  String get showQrButton => 'QRを表示';

  @override
  String get passphraseSetMessage => 'あいことばが設定されました。';

  @override
  String get errorEmptyInput => 'データを入力してください。';

  @override
  String get errorInvalidHex =>
      '無効な16進数文字列です。0〜9、A〜Fの文字を偶数桁で入力してください。';

  @override
  String get errorQrDataTooLarge => 'データがQRコードの容量を超えています。';

  @override
  String get errorTextTooLarge =>
      'テキストが${AppConstants.maxQrContentBytes}バイトを超えています（QR上限）。';

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
   - テキスト：UTF-8テキストを入力してください（${AppConstants.maxQrContentBytes}バイトまで）。
   - バイナリ：16進数文字列を入力してください（例: BEEFFEEB01）。0〜9、A〜Fの文字を偶数桁で入力する必要があります（${AppConstants.maxBinaryHexChars}文字=${AppConstants.maxQrContentBytes}バイトまで）。
3. 必要に応じてあいことばを入力します（6文字以上、任意）。
4. 「QR生成」ボタンをタップしてQRコードを生成します。

## あいことば（パスフレーズ保護）
あいことばを設定すると、URLに含まれるQRデータはあいことばがないと復元できなくなります。URLを開いた人はあいことばの入力を求められ、正しく入力した場合のみQRコードが表示されます。保護が不要な場合はあいことば欄を空欄のままにしてください。

## QRコードのサイズ調整
QRコード画面の＋・−ボタンで表示サイズを拡大・縮小できます。ボタンを押すたびに画像が再生成されます。

## QRコードのブックマーク
QRデータはURLに格納されています。現在のURLをブックマークすることでQRコードを保存できます。ブックマークを開くと、QRコードが即座に表示されます。あいことばを設定した場合は、ブックマークを開くたびにあいことばの入力が必要です。

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
