import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_version.dart';
import '../l10n/app_localizations.dart';

/// Common scaffold that provides an AppBar and a navigation drawer
/// (hamburger menu) linking to all top-level screens.
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: _AppDrawer(l10n: l10n),
      body: body,
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final AppLocalizations l10n;

  const _AppDrawer({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Text(
                    l10n.appTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.qr_code),
                  title: Text(l10n.menuGenerate),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: Text(l10n.menuManual),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/manual');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.menuLicense),
                  onTap: () {
                    Navigator.of(context).pop();
                    showLicensePage(
                      context: context,
                      applicationName: l10n.appTitle,
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              kAppVersion,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
