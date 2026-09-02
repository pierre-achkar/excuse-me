import 'package:excuse_me/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const request = IdeaRequest(
    situation: 'Running late to dinner',
    relationship: 'Friend',
    urgency: 'Soon',
    tone: 'Warm',
  );

  test('local fallback returns an idea rather than a ready-to-send message', () {
    final idea = LocalIdeaGenerator().generate(request);

    expect(IdeaGuardrails.isSafeIdea(idea), isTrue);
    expect(idea, startsWith('Idea:'));
    expect(idea, isNot(contains(RegExp(r"\b(I|I'm|I am|my|me)\b", caseSensitive: false))));
  });

  test('client uses deterministic fallback when transport is unavailable', () async {
    final client = ApiIdeaClient(
      baseUrl: 'https://example.test',
      transport: (_) async => throw Exception('offline'),
    );

    final idea = await client.generate(request);

    expect(IdeaGuardrails.isSafeIdea(idea), isTrue);
  });

  test('guardrails reject ready-to-send messages', () {
    expect(IdeaGuardrails.isSafeIdea('Hi Sam, I am running late. Thanks!'), isFalse);
  });
}
