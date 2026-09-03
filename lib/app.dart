import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'analytics/analytics_client.dart';
import 'l10n/app_localizations.dart';
import 'services/idea_client.dart';
import 'ui/excuse_shop_page.dart';
import 'ui/shop_theme.dart';

class ExcuseMeApp extends StatelessWidget {
  const ExcuseMeApp({
    super.key,
    required this.client,
    this.analytics = const NoOpAnalyticsClient(),
  });

  final IdeaClient client;
  final AnalyticsClient analytics;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: ShopTheme.theme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: ExcuseShopPage(client: client, analytics: analytics),
    );
  }
}
