import 'package:excuse_me/app.dart';
import 'package:excuse_me/domain/idea_request.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _ConversationClient implements IdeaClient {
  IdeaRequest? lastRequest;

  @override
  Future<String> generate(IdeaRequest request) async {
    lastRequest = request;
    return 'Placeholder: a concise low-detail direction.';
  }
}

void main() {
  testWidgets('shop conversation moves through four beats into a card', (
    tester,
  ) async {
    final client = _ConversationClient();
    await tester.pumpWidget(ExcuseMeApp(client: client));
    await tester.pumpAndSettle();

    Future<void> choose(String label) async {
      final option = find.text(label);
      await tester.ensureVisible(option);
      await tester.pumpAndSettle();
      await tester.tap(option);
      await tester.pumpAndSettle();
    }

    expect(find.text("What's the damage?"), findsOneWidget);
    await choose("A dinner I can't face");

    expect(find.text("When's the reckoning?"), findsOneWidget);
    await choose('Today');

    expect(find.text("Who's on the other end?"), findsOneWidget);
    await choose('Someone close');

    expect(find.text('How loud do you want this?'), findsOneWidget);
    await choose('Nice text');
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('pixel-idea-card')), findsOneWidget);
    expect(client.lastRequest, isNotNull);
    expect(client.lastRequest!.structuredRequest!.context.name, 'dinner');
    expect(client.lastRequest!.structuredRequest!.timing.name, 'today');
    expect(client.lastRequest!.structuredRequest!.relationship.name, 'close');
    expect(client.lastRequest!.structuredRequest!.tone.name, 'nice');
  });
}
