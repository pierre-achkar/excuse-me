import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'analytics/analytics_client.dart';
import 'l10n/app_localizations.dart';
import 'services/idea_client.dart';
import 'services/card_collection.dart';
import 'services/user_profile_repository.dart';
import 'ui/excuse_me_shell.dart';
import 'ui/shop_theme.dart';

class ExcuseMeApp extends StatelessWidget {
  const ExcuseMeApp({
    super.key,
    required this.client,
    this.analytics = const NoOpAnalyticsClient(),
    this.disableAnimations = false,
    this.collection,
    this.profileRepository,
  });

  final IdeaClient client;
  final AnalyticsClient analytics;
  final bool disableAnimations;
  final CardCollection? collection;
  final UserProfileRepository? profileRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: ShopTheme.theme,
      darkTheme: ShopTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: ExcuseMeShell(
        client: client,
        analytics: analytics,
        disableAnimations: disableAnimations,
        collection: collection,
        profileRepository: profileRepository,
      ),
    );
  }
}
