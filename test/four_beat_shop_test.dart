import 'package:excuse_me/app.dart';
import 'package:flutter/material.dart';
import 'package:excuse_me/domain/idea_request.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:flutter_test/flutter_test.dart';

class _ConversationClient implements IdeaClient {
  IdeaRequest? lastRequest;

  @override
  Future<String> generate(IdeaRequest request) async {
    lastRequest = request;
    return 'Idea: keep the explanation low-detail.';
  }
}

Future<void> _choose(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
}

void main() {
  testWidgets('shop conversation follows v6 order into a collectible card', (
    tester,
  ) async {
    final client = _ConversationClient();
    await tester.pumpWidget(
      ExcuseMeApp(client: client, disableAnimations: true),
    );

    await _choose(tester, 'v6-entry-cta');
    expect(find.byKey(const ValueKey('v6-step-intent')), findsOneWidget);
    await _choose(tester, 'v6-intent-buyTime');
    expect(find.byKey(const ValueKey('v6-step-action')), findsOneWidget);
    await _choose(tester, 'v6-action-delay');
    expect(find.byKey(const ValueKey('v6-step-context')), findsOneWidget);
    await _choose(tester, 'v6-context-practical');
    expect(find.byKey(const ValueKey('v6-step-timing')), findsOneWidget);
    await _choose(tester, 'v6-timing-happeningNow');
    expect(find.byKey(const ValueKey('v6-step-relationship')), findsOneWidget);
    await _choose(tester, 'v6-relationship-close');
    expect(find.byKey(const ValueKey('v6-step-obligation')), findsOneWidget);
    await _choose(tester, 'v6-obligation-medium');
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('collectible-result-card')),
      findsOneWidget,
    );
    expect(client.lastRequest?.semanticFlow, isTrue);
    expect(client.lastRequest?.structuredRequest?.context.name, 'practical');
  });

  testWidgets('recovery action proceeds from context to relationship', (
    tester,
  ) async {
    await tester.pumpWidget(
      ExcuseMeApp(client: _ConversationClient(), disableAnimations: true),
    );

    await _choose(tester, 'v6-entry-cta');
    await _choose(tester, 'v6-intent-recoverFromSituation');
    await _choose(tester, 'v6-action-explainLateness');
    await _choose(tester, 'v6-context-personal');

    expect(find.byKey(const ValueKey('v6-step-timing')), findsNothing);
    expect(find.byKey(const ValueKey('v6-step-relationship')), findsOneWidget);
  });
}
