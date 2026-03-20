import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app_constants.dart';
import '../l10n/app_localizations.dart';
import '../widgets/app_scaffold.dart';

/// Screen that displays open-source license information.
///
/// Loads licenses from [LicenseRegistry], filters to only those that legally
/// require attribution (i.e. have a copyright notice), groups by package name,
/// and displays one expandable entry per package (sorted alphabetically).
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
  late final Future<Map<String, List<LicenseEntry>>> _licensesFuture;

  @override
  void initState() {
    super.initState();
    _licensesFuture = _loadLicenses();
  }

  /// Returns true if [entry] legally requires attribution.
  ///
  /// Licenses that contain a copyright notice (MIT, BSD, Apache, etc.)
  /// require reproduction. Public domain / CC0 entries do not.
  static bool _requiresAttribution(LicenseEntry entry) {
    final text = entry.paragraphs
        .map((p) => p.text)
        .join(' ')
        .toLowerCase();
    // Explicit public domain / CC0 — no attribution needed.
    if (text.contains('public domain') && !text.contains('copyright')) {
      return false;
    }
    if (text.contains('creative commons zero') ||
        (text.contains('cc0') && !text.contains('copyright'))) {
      return false;
    }
    // A copyright notice is present → attribution required.
    return text.contains('copyright') || text.contains('©');
  }

  /// Reads all [LicenseEntry] objects, retains only those that require
  /// attribution, then groups them by package name (sorted alphabetically).
  static Future<Map<String, List<LicenseEntry>>> _loadLicenses() async {
    final entries = await LicenseRegistry.licenses
        .where(_requiresAttribution)
        .toList();

    final map = <String, List<LicenseEntry>>{};
    for (final entry in entries) {
      for (final package in entry.packages) {
        map.putIfAbsent(package, () => []).add(entry);
      }
    }

    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<LicenseEntry>>>(
      future: _licensesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final packages = snapshot.data!;
        final packageNames = packages.keys.toList();

        return ListView.separated(
          padding: const EdgeInsets.all(AppConstants.screenPadding),
          itemCount: packageNames.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final name = packageNames[index];
            return _PackageLicenseTile(
              packageName: name,
              entries: packages[name]!,
            );
          },
        );
      },
    );
  }
}

class _PackageLicenseTile extends StatelessWidget {
  final String packageName;
  final List<LicenseEntry> entries;

  const _PackageLicenseTile({
    required this.packageName,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final licenseCount = entries.length;
    final subtitle = licenseCount == 1 ? '1 license' : '$licenseCount licenses';

    return ExpansionTile(
      title: Text(
        packageName,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      children: [
        for (int i = 0; i < entries.length; i++) ...[
          if (entries.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'License ${i + 1}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SelectableText(
              _formatParagraphs(entries[i].paragraphs),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ],
    );
  }

  String _formatParagraphs(Iterable<LicenseParagraph> paragraphs) {
    final buffer = StringBuffer();
    for (final p in paragraphs) {
      if (buffer.isNotEmpty) buffer.write('\n\n');
      if (p.indent != LicenseParagraph.centeredIndent) {
        buffer.write('  ' * p.indent);
      }
      buffer.write(p.text);
    }
    return buffer.toString();
  }
}
