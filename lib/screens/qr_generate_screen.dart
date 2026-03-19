import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_constants.dart';
import '../l10n/app_localizations.dart';
import '../models/qr_data.dart';
import '../services/qr_url_service.dart';
import '../widgets/app_scaffold.dart';

/// Screen for entering data and generating a QR code.
///
/// Displays when the URL has no [QrUrlService.paramName] query parameter.
/// On successful generation, navigates to the QR display screen by
/// appending the encoded data as a query parameter.
class QrGenerateScreen extends StatefulWidget {
  const QrGenerateScreen({super.key});

  @override
  State<QrGenerateScreen> createState() => _QrGenerateScreenState();
}

class _QrGenerateScreenState extends State<QrGenerateScreen> {
  QrInputType _selectedType = QrInputType.text;
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTypeChanged(QrInputType? value) {
    if (value == null) return;
    setState(() {
      _selectedType = value;
      _errorText = null;
    });
  }

  String? _validate(AppLocalizations l10n) {
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

  void _generate(AppLocalizations l10n) {
    final error = _validate(l10n);
    if (error != null) {
      setState(() => _errorText = error);
      return;
    }

    final input = _controller.text.trim();
    final content =
        _selectedType == QrInputType.binary ? input.toUpperCase() : input;
    final data = QrData(type: _selectedType, content: content);

    try {
      final encoded = QrUrlService.encode(data);
      context.go('/?${QrUrlService.paramName}=$encoded');
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
              maxLines: _selectedType == QrInputType.text ? null : 1,
              keyboardType: _selectedType == QrInputType.binary
                  ? TextInputType.visiblePassword
                  : TextInputType.multiline,
              onChanged: (_) {
                if (_errorText != null) setState(() => _errorText = null);
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
