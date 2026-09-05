import 'package:flutter/material.dart';

import 'analytics/analytics_client.dart';
import 'app.dart';
import 'services/idea_client.dart';

export 'analytics/analytics_client.dart'
    show AnalyticsClient, AnalyticsEvent, NoOpAnalyticsClient;
export 'app.dart' show ExcuseMeApp;
export 'domain/idea_request.dart' show IdeaRequest;
export 'services/idea_client.dart'
    show GeneratedIdea, IdeaClient, LocalIdeaClient, LocalIdeaGenerator;
export 'services/idea_guardrails.dart' show IdeaGuardrails;

void main() {
  runApp(
    ExcuseMeApp(
      client: LocalIdeaClient(),
      analytics: const NoOpAnalyticsClient(),
    ),
  );
}
