import 'package:flutter/material.dart';

import 'services/idea_client.dart';
import 'ui/excuse_me_page.dart';

class ExcuseMeApp extends StatelessWidget {
  const ExcuseMeApp({super.key, required this.client});

  final IdeaClient client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excuse Me',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff315c4b)),
        useMaterial3: false,
      ),
      home: ExcuseMePage(client: client),
    );
  }
}
