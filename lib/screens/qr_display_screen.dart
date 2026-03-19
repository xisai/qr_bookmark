import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:qr/qr.dart' show InputTooLongException;

import '../app_constants.dart';
import '../l10n/app_localizations.dart';
import '../services/pwa_icon_service.dart';
import '../services/qr_url_service.dart';
import '../widgets/app_scaffold.dart';

/// Screen that displays a generated QR code.
///
/// Displayed when the URL contains a [QrUrlService.paramName] query parameter.
/// Redirects to the generate screen if the parameter cannot be decoded.
class QrDisplayScreen extends StatefulWidget {
  final String encodedData;

  const QrDisplayScreen({super.key, required this.encodedData});

  @override
  State<QrDisplayScreen> createState() => _QrDisplayScreenState();
}

class _QrDisplayScreenState extends State<QrDisplayScreen> {
  QrImage? _qrImage;
  int _sizeSteps = 0;
  final GlobalKey _repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _qrImage = _buildQrImage();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_qrImage == null) {
        context.go('/');
      } else {
        _captureAndUpdatePwaIcon();
      }
    });
  }

  QrImage? _buildQrImage() {
    final data = QrUrlService.decode(widget.encodedData);
    if (data == null) return null;
    try {
      return data.toQrImage();
    } on InputTooLongException {
      return null;
    } catch (_) {
      return null;
    }
  }

  void _enlarge(double maxSize, double defaultSize) {
    final current = _currentSize(defaultSize, maxSize);
    final next = _computeSize(_sizeSteps + 1, defaultSize, maxSize);
    if (next > current) setState(() => _sizeSteps++);
  }

  void _shrink(double maxSize, double defaultSize) {
    final current = _currentSize(defaultSize, maxSize);
    final next = _computeSize(_sizeSteps - 1, defaultSize, maxSize);
    if (next < current) setState(() => _sizeSteps--);
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
    PwaIconService.updateIcon('data:image/png;base64,$base64Str');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
                      decoration: const PrettyQrDecoration(),
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
