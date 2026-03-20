import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'l10n/app_localizations.dart';
import 'screens/license_screen.dart';
import 'screens/manual_screen.dart';
import 'screens/qr_display_screen.dart';
import 'screens/qr_generate_screen.dart';
import 'services/qr_url_service.dart';

void main() {
  runApp(const QrBookmarkApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        final encoded =
            state.uri.queryParameters[QrUrlService.paramName];
        if (encoded != null && encoded.isNotEmpty) {
          final sizeSteps = int.tryParse(
                state.uri.queryParameters[QrUrlService.sizeParamName] ?? '',
              ) ??
              0;
          return QrDisplayScreen(
            encodedData: encoded,
            initialSizeSteps: sizeSteps,
          );
        }
        return const QrGenerateScreen();
      },
    ),
    GoRoute(
      path: '/manual',
      builder: (context, state) => const ManualScreen(),
    ),
    GoRoute(
      path: '/license',
      builder: (context, state) => const LicenseScreen(),
    ),
  ],
);

class QrBookmarkApp extends StatelessWidget {
  const QrBookmarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ja'),
      ],
    );
  }
}
