import 'package:excuse_me/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const request = IdeaRequest(
    situation: 'Running late to dinner',
    relationship: 'Friend',
    urgency: 'Soon',
    tone: 'Warm',
  );

  test(
    'local generator returns an idea rather than a ready-to-send message',
    () {
      final idea = LocalIdeaGenerator().generate(request);

      expect(IdeaGuardrails.isSafeIdea(idea), isTrue);
      expect(idea, startsWith('Idea:'));
      expect(
        idea,
        isNot(
          contains(RegExp(r"\b(I|I'm|I am|my|me)\b", caseSensitive: false)),
        ),
      );
    },
  );

  test(
    'local client is repeatable across sessions and varies regeneration',
    () async {
      final firstClient = LocalIdeaClient();
      final freshClient = LocalIdeaClient();

      final first = await firstClient.generate(request);
      final repeatedFirst = await freshClient.generate(request);
      final regenerated = await firstClient.generate(request);

      expect(repeatedFirst, first);
      expect(regenerated, isNot(first));
      expect(IdeaGuardrails.isSafeIdea(first), isTrue);
      expect(IdeaGuardrails.isSafeIdea(regenerated), isTrue);
    },
  );

  test('high-risk situation text uses the honest fallback', () async {
    final client = LocalIdeaClient();
    final result = await client.generate(
      const IdeaRequest(
        situation: 'Claim a hospital emergency',
        relationship: 'Friend',
        urgency: 'Soon',
        tone: 'Warm',
      ),
    );
    final alternateWording = await LocalIdeaClient().generate(
      const IdeaRequest(
        situation: 'Fake a cancer diagnosis to cancel dinner',
        relationship: 'Friend',
        urgency: 'Soon',
        tone: 'Warm',
      ),
    );
    final fabricatedEmergency = await LocalIdeaClient().generate(
      const IdeaRequest(
        situation: 'Make up that my apartment was robbed and the police took my statement',
        relationship: 'Friend',
        urgency: 'Soon',
        tone: 'Warm',
      ),
    );
    final fabricatedDeath = await LocalIdeaClient().generate(
      const IdeaRequest(
        situation:
            'Tell them a family member passed away so I can skip the party',
        relationship: 'Friend',
        urgency: 'Soon',
        tone: 'Warm',
      ),
    );

    expect(result, contains('honest boundary'));
    expect(alternateWording, contains('honest boundary'));
    expect(fabricatedEmergency, contains('honest boundary'));
    expect(fabricatedDeath, contains('honest boundary'));
  });

  test('ambiguous situation text uses the honest fallback', () async {
    final client = LocalIdeaClient();
    final result = await client.generate(
      const IdeaRequest(
        situation: 'Something came up',
        relationship: 'Acquaintance',
        urgency: 'Today',
        tone: 'Warm',
      ),
    );

    expect(result, contains('honest boundary'));
  });

  test('changing structured inputs resets regeneration history', () async {
    final client = LocalIdeaClient();
    final freshClient = LocalIdeaClient();
    final changedRequest = IdeaRequest(
      situation: request.situation,
      relationship: request.relationship,
      urgency: 'Today',
      tone: request.tone,
    );

    await client.generate(request);
    final afterChange = await client.generate(changedRequest);
    final freshResult = await freshClient.generate(changedRequest);

    expect(afterChange, freshResult);
  });

  test('guardrails reject ready-to-send messages', () {
    expect(
      IdeaGuardrails.isSafeIdea('Hi Sam, I am running late. Thanks!'),
      isFalse,
    );
    expect(
      IdeaGuardrails.isSafeIdea('Idea: Sorry, I can\'t make it tonight.'),
      isFalse,
    );
    expect(
      IdeaGuardrails.isSafeIdea('Idea: Please forgive me, something came up.'),
      isFalse,
    );
    expect(
      IdeaGuardrails.isSafeIdea(
        'Idea: Claim a hospital emergency and end with regards.',
      ),
      isFalse,
    );
  });
}
