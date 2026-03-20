import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';

import 'l10n/app_localizations.dart';
import 'screens/manual_screen.dart';
import 'screens/qr_display_screen.dart';
import 'screens/qr_generate_screen.dart';

void main() {
  usePathUrlStrategy();
  runApp(const QrBookmarkApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const QrGenerateScreen(),
    ),
    GoRoute(
      path: '/qr/:encoded',
      builder: (context, state) => QrDisplayScreen(
        encodedData: state.pathParameters['encoded']!,
      ),
      routes: [
        GoRoute(
          path: ':s',
          builder: (context, state) => QrDisplayScreen(
            encodedData: state.pathParameters['encoded']!,
            initialSizeSteps:
                int.tryParse(state.pathParameters['s'] ?? '') ?? 0,
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/manual',
      builder: (context, state) => const ManualScreen(),
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
