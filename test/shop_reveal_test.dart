import 'package:excuse_me/app.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _RevealClient implements IdeaClient {
  @override
  Future<String> generate(request) async => 'Idea: keep this brief.';
}

Future<void> _choose(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
}

void main() {
  testWidgets('successful generation opens the full-screen reveal', (
    tester,
  ) async {
    await tester.pumpWidget(
      ExcuseMeApp(client: _RevealClient(), disableAnimations: true),
    );
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

    expect(find.byKey(const ValueKey('card-viewer')), findsOneWidget);
    expect(find.byKey(const ValueKey('card-viewer-continue')), findsOneWidget);
    // Keeping, sharing and copying all live on the reveal itself.
    expect(find.byKey(const ValueKey('card-viewer-share')), findsOneWidget);
    expect(find.byKey(const ValueKey('v6-keep-card')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('card-viewer-continue')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('v6-result')), findsOneWidget);
    expect(find.byKey(const ValueKey('v6-see-card')), findsOneWidget);
  });
}
