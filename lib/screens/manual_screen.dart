import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/app_scaffold.dart';

/// Screen that displays usage instructions.
class ManualScreen extends StatelessWidget {
  const ManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.manualScreenTitle,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: SelectableText(
          l10n.manualContent,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
