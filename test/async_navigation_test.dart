import 'dart:async';

import 'package:excuse_me/app.dart';
import 'package:excuse_me/domain/idea_request.dart';
import 'package:excuse_me/services/card_collection.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _CountingDelayedClient implements IdeaClient, DetailedIdeaClient {
  int calls = 0;

  @override
  Future<String> generate(IdeaRequest request) async => 'unused';

  @override
  Future<GeneratedIdea> generateDetailed(IdeaRequest request) async {
    calls += 1;
    return const GeneratedIdea(
      idea: 'A delayed local idea',
      kernelId: 'delayed',
      playfulName: 'Delayed card',
    );
  }
}

class _AlternativeDelayedClient implements IdeaClient, DetailedIdeaClient {
  int calls = 0;
  final alternative = Completer<GeneratedIdea>();

  @override
  Future<String> generate(IdeaRequest request) async => 'unused';

  @override
  Future<GeneratedIdea> generateDetailed(IdeaRequest request) async {
    calls += 1;
    if (calls == 1) {
      return const GeneratedIdea(
        idea: 'The original idea',
        kernelId: 'original-card',
        playfulName: 'Original card',
      );
    }
    return alternative.future;
  }
}

Future<void> _tapKey(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  final scrollable = find.ancestor(
    of: finder,
    matching: find.byType(Scrollable),
  );
  if (scrollable.evaluate().isNotEmpty) {
    await tester.scrollUntilVisible(finder, 180, scrollable: scrollable.first);
  }
  await tester.tap(finder);
  await tester.pump();
}

Future<void> _startDelayedGeneration(
  WidgetTester tester,
  _CountingDelayedClient client,
) async {
  await tester.pumpWidget(
    ExcuseMeApp(client: client, disableAnimations: false),
  );
  await tester.pumpAndSettle();
  await _tapKey(tester, 'v6-entry-cta');
  await _tapKey(tester, 'v6-intent-getOutOfPlans');
  await _tapKey(tester, 'v6-action-cancel');
  await _tapKey(tester, 'v6-context-social');
  await _tapKey(tester, 'v6-timing-today');
  await _tapKey(tester, 'v6-relationship-casual');
  await _tapKey(tester, 'v6-obligation-low');
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('restart invalidates generation before the client is called', (
    tester,
  ) async {
    final client = _CountingDelayedClient();
    await _startDelayedGeneration(tester, client);
    await tester.pump(const Duration(milliseconds: 100));

    await _tapKey(tester, 'restart-shop');
    await tester.pump(const Duration(milliseconds: 700));

    expect(client.calls, 0);
    expect(find.byKey(const ValueKey('v6-entry-cta')), findsOneWidget);
  });

  testWidgets('leaving Shop invalidates pending generation', (tester) async {
    final client = _CountingDelayedClient();
    await _startDelayedGeneration(tester, client);
    await tester.pump(const Duration(milliseconds: 100));
    expect(client.calls, 0);

    await tester.tap(find.byKey(const ValueKey('nav-collection')));
    await tester.pump(const Duration(milliseconds: 700));

    expect(client.calls, 0);
    expect(find.byKey(const ValueKey('card-viewer')), findsNothing);
  });

  testWidgets('leaving during Another one restores the original saved card', (
    tester,
  ) async {
    final client = _AlternativeDelayedClient();
    final collection = CardCollection();
    await tester.pumpWidget(
      ExcuseMeApp(
        client: client,
        disableAnimations: true,
        collection: collection,
      ),
    );
    await tester.pumpAndSettle();
    for (final key in [
      'v6-entry-cta',
      'v6-intent-getOutOfPlans',
      'v6-action-cancel',
      'v6-context-social',
      'v6-timing-today',
      'v6-relationship-casual',
      'v6-obligation-low',
    ]) {
      await _tapKey(tester, key);
    }
    await tester.pumpAndSettle();
    await _tapKey(tester, 'v6-keep-card');
    await tester.pumpAndSettle();
    await _tapKey(tester, 'card-viewer-continue');
    await tester.pumpAndSettle();

    expect(collection.cards, hasLength(1));
    expect(collection.cards.single.kernelId, 'original-card');

    await _tapKey(tester, 'v6-another-card');
    expect(client.calls, 2);
    expect(find.byKey(const ValueKey('v6-search')), findsOneWidget);

    await _tapKey(tester, 'nav-collection');
    await _tapKey(tester, 'nav-shop');

    expect(find.byKey(const ValueKey('v6-result')), findsOneWidget);
    expect(find.text('Original card'), findsOneWidget);
    expect(find.textContaining('Kept.'), findsOneWidget);

    client.alternative.complete(
      const GeneratedIdea(
        idea: 'The late alternative idea',
        kernelId: 'late-alternative',
        playfulName: 'Late alternative',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Original card'), findsOneWidget);
    expect(find.text('Late alternative'), findsNothing);
    expect(find.textContaining('Kept.'), findsOneWidget);
  });
}
