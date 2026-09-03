import 'package:flutter/material.dart';

import 'app.dart';
import 'services/idea_client.dart';

export 'app.dart' show ExcuseMeApp;
export 'domain/idea_request.dart' show IdeaRequest;
export 'services/idea_client.dart'
    show IdeaClient, LocalIdeaClient, LocalIdeaGenerator;
export 'services/idea_guardrails.dart' show IdeaGuardrails;

void main() {
  runApp(ExcuseMeApp(client: LocalIdeaClient()));
}
