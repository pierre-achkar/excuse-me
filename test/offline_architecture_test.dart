import 'dart:io';

import 'package:excuse_me/domain/idea_request.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:excuse_me/services/idea_guardrails.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'offline service surface stays independent from the app entrypoint',
    () async {
      const request = IdeaRequest(
        situation: 'Running late to dinner',
        relationship: 'Friend',
        urgency: 'Soon',
        tone: 'Warm',
      );

      final idea = await LocalIdeaClient().generate(request);

      expect(IdeaGuardrails.isSafeIdea(idea), isTrue);
      expect(idea, startsWith('Idea:'));
    },
  );

  test('release Android manifest requests no network access', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();

    expect(manifest, isNot(contains('android.permission.INTERNET')));
    expect(manifest, isNot(contains('usesCleartextTraffic')));
  });
}
