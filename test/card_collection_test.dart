import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:excuse_me/app.dart';
import 'package:excuse_me/services/card_collection.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:excuse_me/domain/idea_request.dart';
import 'package:excuse_me/ui/excuse_card.dart';

import 'excuse_shop_test.dart' show completeV6Conversation;

class AlternativesClient implements IdeaClient, DetailedIdeaClient {
  final requests = <IdeaRequest>[];
  @override
  Future<String> generate(IdeaRequest request) async => 'Idea';
  @override
  Future<GeneratedIdea> generateDetailed(IdeaRequest request) async {
    requests.add(request);
    return GeneratedIdea(
      kernelId: 'card-${requests.length}',
      playfulName: 'Card ${requests.length}',
      idea: 'Idea ${requests.length}',
    );
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('saved wording persists across stores, duplicate IDs update instead of multiplying', () async {
    final store = CardCollection();
    await store.save(const GeneratedIdea(kernelId: 'a', idea: 'First wording'));
    await store.save(
      const GeneratedIdea(kernelId: 'a', idea: 'Chosen wording'),
    );
    final reopened = CardCollection();
    await reopened.load();
    expect(reopened.cards.length, 1);
    expect(reopened.cards.single.idea, 'Chosen wording');
  });
  testWidgets(
    'another card reuses answers and only the chosen card enters collection',
    (tester) async {
      final client = AlternativesClient();
      await tester.pumpWidget(
        ExcuseMeApp(client: client, disableAnimations: true),
      );
      await completeV6Conversation(tester);
      final store = CardCollection();
      await store.load();
      expect(store.cards, isEmpty);
      // The result's actions are pinned, so no scrolling is needed.
      final another = find.byKey(const ValueKey('v6-another-card'));
      expect(
        find.ancestor(of: another, matching: find.byType(Scrollable)),
        findsNothing,
      );
      await tester.tap(another);
      await tester.pumpAndSettle();
      expect(client.requests.length, 2);
      expect(
        client.requests[0].structuredRequest!.semanticSelectionKey,
        client.requests[1].structuredRequest!.semanticSelectionKey,
      );
      expect(find.text('Card 2'), findsOneWidget);

      // The alternative's reveal is where it gets kept.
      final keep = find.byKey(const ValueKey('v6-keep-card'));
      await tester.ensureVisible(keep);
      await tester.tap(keep);
      await tester.pumpAndSettle();
      expect(find.text('Saved to collection'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('card-viewer-continue')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('nav-collection')));
      await tester.pumpAndSettle();
      expect(find.text('Collection · 1'), findsOneWidget);
      expect(find.text('Card 2'), findsOneWidget);
      expect(find.text('Card 1'), findsNothing);
      expect(find.byType(ExcuseCard), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('nav-shop')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('v6-result')), findsOneWidget);
    },
  );
  testWidgets('empty collection explains how to choose a card', (tester) async {
    await tester.pumpWidget(
      ExcuseMeApp(client: AlternativesClient(), disableAnimations: true),
    );
    await tester.tap(find.byKey(const ValueKey('nav-collection')));
    await tester.pumpAndSettle();
    expect(find.text('Your shelf is waiting.'), findsOneWidget);
  });
}
