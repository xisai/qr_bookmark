import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_constants.dart';
import '../l10n/app_localizations.dart';
import '../models/qr_data.dart';
import '../services/pwa_icon_service.dart';
import '../services/qr_url_service.dart';
import '../widgets/app_scaffold.dart';

/// Screen for entering data and generating a QR code.
///
/// Displayed at `/`. On successful generation, navigates to the QR display
/// screen at `/qr/<encodedData>`.
class QrGenerateScreen extends StatefulWidget {
  const QrGenerateScreen({super.key});

  @override
  State<QrGenerateScreen> createState() => _QrGenerateScreenState();
}

class _QrGenerateScreenState extends State<QrGenerateScreen> {
  QrInputType _selectedType = QrInputType.text;
  final _controller = TextEditingController();
  String? _errorText;
  final _passphraseController = TextEditingController();
  String? _passphraseErrorText;
  bool _passphraseObscured = true;

  @override
  void dispose() {
    _controller.dispose();
    _passphraseController.dispose();
    super.dispose();
  }

  void _onTypeChanged(QrInputType? value) {
    if (value == null) return;
    setState(() {
      _selectedType = value;
      _errorText = null;
    });
  }

  String? _validateContent(AppLocalizations l10n) {
    final input = _controller.text.trim();
    if (input.isEmpty) return l10n.errorEmptyInput;
    if (_selectedType == QrInputType.binary) {
      if (!RegExp(r'^[0-9A-Fa-f]+$').hasMatch(input)) {
        return l10n.errorInvalidHex;
      }
      if (input.length.isOdd) return l10n.errorInvalidHex;
    }
    return null;
  }

  String? _validatePassphrase(AppLocalizations l10n) {
    final text = _passphraseController.text;
    if (text.isEmpty) return null;
    if (text.length < 6) return l10n.errorPassphraseTooShort;
    return null;
  }

  void _generate(AppLocalizations l10n) {
    final contentError = _validateContent(l10n);
    final passphraseError = _validatePassphrase(l10n);
    if (contentError != null || passphraseError != null) {
      setState(() {
        _errorText = contentError;
        _passphraseErrorText = passphraseError;
      });
      return;
    }

    final input = _controller.text.trim();
    final content =
        _selectedType == QrInputType.binary ? input.toUpperCase() : input;
    final data = QrData(type: _selectedType, content: content);
    final passphrase = _passphraseController.text;

    try {
      final encoded = QrUrlService.encode(
        data,
        passphrase: passphrase.isEmpty ? null : passphrase,
      );
      final path = QrUrlService.buildDisplayPath(encoded, 0);
      if (passphrase.isNotEmpty) PwaIconService.savePassphrase(passphrase);
      // Web: フルページナビゲーションで index.html を再実行し
      // manifest の start_url を QR URL に確実に設定する。
      // Non-web: go_router のクライアントサイドナビゲーション。
      if (!PwaIconService.navigateToPath(path)) {
        context.go(path);
      }
    } catch (_) {
      setState(() => _errorText = l10n.errorQrDataTooLarge);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.generateScreenTitle,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.screenPaddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TypeSelector(
              selected: _selectedType,
              onChanged: _onTypeChanged,
              l10n: l10n,
            ),
            const SizedBox(height: AppConstants.formSpacing),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: _selectedType == QrInputType.text
                    ? l10n.hintText
                    : l10n.hintBinary,
                errorText: _errorText,
                border: const OutlineInputBorder(),
              ),
              minLines: _selectedType == QrInputType.text
                  ? AppConstants.textInputMinLines
                  : 1,
              maxLines: _selectedType == QrInputType.text ? null : 1,
              keyboardType: _selectedType == QrInputType.binary
                  ? TextInputType.visiblePassword
                  : TextInputType.multiline,
              onChanged: (_) {
                if (_errorText != null) setState(() => _errorText = null);
              },
            ),
            const SizedBox(height: AppConstants.formSpacing),
            TextField(
              controller: _passphraseController,
              obscureText: _passphraseObscured,
              decoration: InputDecoration(
                hintText: l10n.hintPassphrase,
                errorText: _passphraseErrorText,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passphraseObscured
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _passphraseObscured = !_passphraseObscured);
                  },
                ),
              ),
              onChanged: (_) {
                if (_passphraseErrorText != null) {
                  setState(() => _passphraseErrorText = null);
                }
              },
            ),
            const SizedBox(height: AppConstants.formButtonSpacing),
            ElevatedButton(
              onPressed: () => _generate(l10n),
              child: Text(l10n.generateButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final QrInputType selected;
  final ValueChanged<QrInputType?> onChanged;
  final AppLocalizations l10n;

  const _TypeSelector({
    required this.selected,
    required this.onChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<QrInputType>(
      value: selected,
      decoration: const InputDecoration(border: OutlineInputBorder()),
      items: [
        DropdownMenuItem(
          value: QrInputType.text,
          child: Text(l10n.typeText),
        ),
        DropdownMenuItem(
          value: QrInputType.binary,
          child: Text(l10n.typeBinary),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
