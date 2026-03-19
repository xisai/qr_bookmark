import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/app_scaffold.dart';

/// Screen that displays open-source license information.
///
/// Uses Flutter's built-in [LicenseRegistry] to list all package licenses.
class LicenseScreen extends StatelessWidget {
  const LicenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.licenseScreenTitle,
      body: const _LicenseList(),
    );
  }
}

class _LicenseList extends StatefulWidget {
  const _LicenseList();

  @override
  State<_LicenseList> createState() => _LicenseListState();
}

class _LicenseListState extends State<_LicenseList> {
  late final Future<List<LicenseEntry>> _licensesFuture;

  @override
  void initState() {
    super.initState();
    _licensesFuture = LicenseRegistry.licenses.toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LicenseEntry>>(
      future: _licensesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final entries = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final entry = entries[index];
            final packageNames = entry.packages.join(', ');
            final paragraphs = entry.paragraphs
                .map((p) => p.text)
                .join('\n\n');
            return ExpansionTile(
              title: Text(
                packageNames,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SelectableText(
                    paragraphs,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
