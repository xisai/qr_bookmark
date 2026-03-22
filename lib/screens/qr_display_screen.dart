import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../app_constants.dart';
import '../l10n/app_localizations.dart';
import '../models/decode_result.dart';
import '../services/pwa_icon_service.dart';
import '../services/qr_url_service.dart';
import '../widgets/app_scaffold.dart';

enum _DisplayState { locked, unlocked, autoUnlocked }

/// Screen that displays a generated QR code.
///
/// Displayed when the URL contains a [QrUrlService.buildDisplayPath] path.
/// Redirects to the generate screen if the data cannot be decoded.
///
/// Three display states:
/// - [_DisplayState.locked]       — passphrase required; shows input UI.
/// - [_DisplayState.unlocked]     — decoded successfully via user input.
/// - [_DisplayState.autoUnlocked] — decoded automatically (passphrase passed
///                                  from generate screen); shows info banner.
class QrDisplayScreen extends StatefulWidget {
  final String encodedData;
  final int initialSizeSteps;

  const QrDisplayScreen({
    super.key,
    required this.encodedData,
    this.initialSizeSteps = 0,
  });

  @override
  State<QrDisplayScreen> createState() => _QrDisplayScreenState();
}

class _QrDisplayScreenState extends State<QrDisplayScreen> {
  QrImage? _qrImage;
  late int _sizeSteps;
  final GlobalKey _repaintKey = GlobalKey();
  _DisplayState _displayState = _DisplayState.unlocked;
  String? _activePassphrase;

  final _passphraseController = TextEditingController();
  String? _passphraseErrorText;
  bool _passphraseObscured = true;

  @override
  void initState() {
    super.initState();
    _sizeSteps = widget.initialSizeSteps;

    final pending = PwaIconService.consumePassphrase();
    final resizePending = PwaIconService.consumeResizePassphrase();
    final passphrase = pending ?? resizePending;
    final result = QrUrlService.decode(widget.encodedData, passphrase: passphrase);

    switch (result) {
      case DecodeSuccess(:final qrImage):
        _qrImage = qrImage;
        _activePassphrase = passphrase;
        _displayState =
            pending != null ? _DisplayState.autoUnlocked : _DisplayState.unlocked;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) _captureAndUpdatePwaIcon();
        });
      case DecodePassphraseRequired():
        _displayState = _DisplayState.locked;
      case DecodePassphraseWrong():
        // Stored passphrase was wrong (shouldn't normally happen); ask again.
        _displayState = _DisplayState.locked;
      case DecodeInvalid():
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.go('/');
        });
    }
  }

  @override
  void dispose() {
    _passphraseController.dispose();
    super.dispose();
  }

  void _submitPassphrase(AppLocalizations l10n) {
    final passphrase = _passphraseController.text;
    final result =
        QrUrlService.decode(widget.encodedData, passphrase: passphrase);
    switch (result) {
      case DecodeSuccess(:final qrImage):
        setState(() {
          _qrImage = qrImage;
          _activePassphrase = passphrase;
          _displayState = _DisplayState.unlocked;
          _passphraseErrorText = null;
        });
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) _captureAndUpdatePwaIcon();
        });
      case DecodePassphraseWrong():
        setState(() => _passphraseErrorText = l10n.errorPassphraseWrong);
      case DecodePassphraseRequired():
        setState(() => _passphraseErrorText = l10n.errorPassphraseWrong);
      case DecodeInvalid():
        context.go('/');
    }
  }

  void _enlarge(double maxSize, double defaultSize) {
    final current = _currentSize(defaultSize, maxSize);
    final next = _computeSize(_sizeSteps + 1, defaultSize, maxSize);
    if (next > current) {
      setState(() => _sizeSteps++);
      _updateUrl();
    }
  }

  void _shrink(double maxSize, double defaultSize) {
    final current = _currentSize(defaultSize, maxSize);
    final next = _computeSize(_sizeSteps - 1, defaultSize, maxSize);
    if (next < current) {
      setState(() => _sizeSteps--);
      _updateUrl();
    }
  }

  void _updateUrl() {
    if (_activePassphrase != null) {
      PwaIconService.saveResizePassphrase(_activePassphrase!);
    }
    context.replace(
      QrUrlService.buildDisplayPath(widget.encodedData, _sizeSteps),
    );
  }

  double _currentSize(double defaultSize, double maxSize) =>
      _computeSize(_sizeSteps, defaultSize, maxSize);

  double _computeSize(int steps, double defaultSize, double maxSize) =>
      (defaultSize * (1 + steps * AppConstants.qrSizeStepFactor))
          .clamp(AppConstants.qrMinSize, maxSize);

  Future<void> _captureAndUpdatePwaIcon() async {
    final boundary = _repaintKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image =
        await boundary.toImage(pixelRatio: AppConstants.pwaIconPixelRatio);
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final base64Str = base64Encode(byteData.buffer.asUint8List());
    final dataUrl = 'data:image/png;base64,$base64Str';
    PwaIconService.updateIcon(dataUrl);           // iOS: apple-touch-icon
    PwaIconService.updateManifestIcon(dataUrl);   // Android: SW キャッシュ + blob manifest 切り替え
    await PwaIconService.updateManifestStartUrl(); // start_url を現在の URL に更新
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_displayState == _DisplayState.locked) {
      return AppScaffold(
        title: l10n.displayScreenTitle,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.screenPaddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.passphrasePrompt),
              const SizedBox(height: AppConstants.formSpacing),
              TextField(
                controller: _passphraseController,
                obscureText: _passphraseObscured,
                autofocus: true,
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
                      setState(
                        () => _passphraseObscured = !_passphraseObscured,
                      );
                    },
                  ),
                ),
                onChanged: (_) {
                  if (_passphraseErrorText != null) {
                    setState(() => _passphraseErrorText = null);
                  }
                },
                onSubmitted: (_) => _submitPassphrase(l10n),
              ),
              const SizedBox(height: AppConstants.formButtonSpacing),
              ElevatedButton(
                onPressed: () => _submitPassphrase(l10n),
                child: Text(l10n.showQrButton),
              ),
            ],
          ),
        ),
      );
    }

    if (_qrImage == null) {
      return AppScaffold(
        title: l10n.displayScreenTitle,
        body: const SizedBox.shrink(),
      );
    }

    return AppScaffold(
      title: l10n.displayScreenTitle,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxSize =
              constraints.maxWidth - AppConstants.qrHorizontalMargin;
          final defaultSize = maxSize * AppConstants.qrDefaultSizeRatio;
          final currentSize = _computeSize(_sizeSteps, defaultSize, maxSize);
          final canEnlarge = currentSize < maxSize;
          final canShrink = currentSize > AppConstants.qrMinSize;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.screenPadding),
            child: Column(
              children: [
                if (_displayState == _DisplayState.autoUnlocked)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppConstants.formSpacing,
                    ),
                    child: Material(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_open, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(l10n.passphraseSetMessage)),
                          ],
                        ),
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filled(
                      onPressed: canShrink
                          ? () => _shrink(maxSize, defaultSize)
                          : null,
                      icon: const Icon(Icons.remove),
                      tooltip: l10n.shrinkTooltip,
                    ),
                    const SizedBox(width: AppConstants.buttonRowSpacing),
                    IconButton.filled(
                      onPressed: canEnlarge
                          ? () => _enlarge(maxSize, defaultSize)
                          : null,
                      icon: const Icon(Icons.add),
                      tooltip: l10n.enlargeTooltip,
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.qrButtonToImageSpacing),
                RepaintBoundary(
                  key: _repaintKey,
                  child: Container(
                    width: currentSize,
                    height: currentSize,
                    color: Colors.white,
                    padding: const EdgeInsets.all(AppConstants.qrPadding),
                    child: PrettyQrView(
                      qrImage: _qrImage!,
                      decoration: const PrettyQrDecoration(
                        shape: PrettyQrSmoothSymbol(roundFactor: 0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
