import 'package:excuse_me/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const request = IdeaRequest(
    situation: 'Running late to dinner',
    relationship: 'Friend',
    urgency: 'Soon',
    tone: 'Warm',
  );

  test('local generator returns an idea rather than a ready-to-send message', () {
    final idea = LocalIdeaGenerator().generate(request);

    expect(IdeaGuardrails.isSafeIdea(idea), isTrue);
    expect(idea, startsWith('Idea:'));
    expect(idea, isNot(contains(RegExp(r"\b(I|I'm|I am|my|me)\b", caseSensitive: false))));
  });

  test('local-only client is deterministic without a network transport', () async {
    final client = LocalIdeaClient();

    final first = await client.generate(request);
    final second = await client.generate(request);

    expect(first, second);
    expect(IdeaGuardrails.isSafeIdea(first), isTrue);
  });

  test('guardrails reject ready-to-send messages', () {
    expect(IdeaGuardrails.isSafeIdea('Hi Sam, I am running late. Thanks!'), isFalse);
  });
}
