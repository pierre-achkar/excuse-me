import 'package:excuse_me/app.dart';
import 'package:flutter/material.dart';
import 'package:excuse_me/domain/idea_request.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeShopIdeaClient implements IdeaClient {
  bool called = false;

  @override
  Future<String> generate(IdeaRequest request) async {
    called = true;
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
  testWidgets('v6 app shows the shop conversation and result card', (
    tester,
  ) async {
    final client = FakeShopIdeaClient();
    await tester.pumpWidget(
      ExcuseMeApp(client: client, disableAnimations: true),
    );

    expect(find.text('I need an excuse'), findsOneWidget);
    for (final key in [
      'v6-entry-cta',
      'v6-intent-getOutOfPlans',
      'v6-action-cancel',
      'v6-context-social',
      'v6-timing-today',
      'v6-relationship-casual',
      'v6-obligation-low',
    ]) {
      await _choose(tester, key);
    }
    await tester.pumpAndSettle();
    final reveal = find.byKey(const ValueKey('card-viewer-continue'));
    expect(reveal, findsOneWidget);
    expect(find.byKey(const ValueKey('v6-copy-card')), findsOneWidget);
    await tester.tap(reveal);
    await tester.pumpAndSettle();

    expect(client.called, isTrue);
    expect(
      find.byKey(const ValueKey('collectible-result-card')),
      findsOneWidget,
    );
  });
}
