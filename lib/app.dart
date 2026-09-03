import 'package:flutter/material.dart';

import 'services/idea_client.dart';
import 'ui/excuse_shop_page.dart';
import 'ui/shop_theme.dart';

class ExcuseMeApp extends StatelessWidget {
  const ExcuseMeApp({super.key, required this.client});

  final IdeaClient client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excuse Me',
      theme: ShopTheme.theme,
      home: ExcuseShopPage(client: client),
    );
  }
}
