import 'package:excuse_me/app.dart';
import 'package:flutter/material.dart';
import 'package:excuse_me/domain/idea_request.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:flutter_test/flutter_test.dart';

class _RepairClient implements IdeaClient {
  @override
  Future<String> generate(IdeaRequest request) async =>
      'Idea: acknowledge the change and leave the details to the user.';
}

Future<void> _choose(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
}

void main() {
  testWidgets('high-obligation recovery offers a repair direction', (
    tester,
  ) async {
    await tester.pumpWidget(
      ExcuseMeApp(client: _RepairClient(), disableAnimations: true),
    );

    for (final key in [
      'v6-entry-cta',
      'v6-intent-recoverFromSituation',
      'v6-action-acknowledgeMiss',
      'v6-context-workStudy',
      'v6-relationship-formal',
      'v6-obligation-high',
    ]) {
      await _choose(tester, key);
    }
    await tester.pumpAndSettle();
    final reveal = find.byKey(const ValueKey('card-viewer-continue'));
    if (reveal.evaluate().isNotEmpty) {
      await tester.tap(reveal);
      await tester.pumpAndSettle();
    }

    expect(
      find.byKey(const ValueKey('collectible-result-card')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('repair-direction')), findsOneWidget);
    expect(find.text('Repair direction'), findsOneWidget);
    expect(find.textContaining('phrase in your own words'), findsOneWidget);
  });

  testWidgets('a high-stakes cancellation also shows its repair direction', (
    tester,
  ) async {
    await tester.pumpWidget(
      ExcuseMeApp(client: _RepairClient(), disableAnimations: true),
    );
    // Not a recovery: the repair direction is earned by the stakes alone.
    for (final key in [
      'v6-entry-cta',
      'v6-intent-getOutOfPlans',
      'v6-action-cancel',
      'v6-context-workStudy',
      'v6-timing-lastMinute',
      'v6-relationship-formal',
      'v6-obligation-high',
    ]) {
      final finder = find.byKey(ValueKey(key));
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byKey(const ValueKey('card-viewer-continue')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('repair-direction')), findsOneWidget);
  });
}
