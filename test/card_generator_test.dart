import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:excuse_me/ui/excuse_card.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:excuse_me/domain/excuse_request.dart';
import 'package:excuse_me/app.dart';

import 'excuse_shop_test.dart' show FakeShopIdeaClient;

void main() {
  test(
    '1,000 catalog IDs generate stable distinct editions without registration',
    () {
      final designs = List.generate(
        1000,
        (i) => CardDesignGenerator.generate(
          id: 'excuse-$i',
          family: ExcuseFamily.values[i % 7],
        ),
      );
      expect(designs.map((d) => d.edition).toSet().length, 1000);
      expect(designs.map((d) => d.color).toSet().length, greaterThan(6));
      expect(designs.map((d) => d.illustration).toSet().length, 13);
      for (var i = 0; i < 1000; i++) {
        expect(
          CardDesignGenerator.generate(
            id: 'excuse-$i',
            family: ExcuseFamily.values[i % 7],
          ).signature,
          designs[i].signature,
        );
      }
    },
  );
  test('tone changes keep the visual identity and illustration', () {
    const idea = GeneratedIdea(
      kernelId: 'card-902',
      idea: 'Quiet evening.',
      family: ExcuseFamily.capacityWellbeing,
      toneDirections: {ExcuseTone.nice: 'A little time to recharge.'},
    );
    expect(
      CardDesign.forIdea(idea).signature,
      CardDesign.forIdea(idea.withTone(ExcuseTone.nice)).signature,
    );
  });
  test('art overrides preserve identity', () {
    final auto = CardDesignGenerator.generate(id: 'new-card');
    final directed = CardDesignGenerator.generate(
      id: 'new-card',
      illustration: CardIllustration.wallet,
      color: Colors.teal,
    );
    expect(directed.edition, auto.edition);
    expect(directed.illustration, CardIllustration.wallet);
  });
  testWidgets('back allows changing intent without carrying old actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ExcuseMeApp(client: FakeShopIdeaClient('Idea'), disableAnimations: true),
    );
    for (final key in [
      'v6-entry-cta',
      'v6-intent-getOutOfPlans',
      'v6-action-cancel',
      'v6-back',
      'v6-back',
    ]) {
      final finder = find.byKey(ValueKey(key));
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }
    final newIntent = find.byKey(const ValueKey('v6-intent-buyTime'));
    await tester.ensureVisible(newIntent);
    await tester.tap(newIntent);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('v6-action-cancel')), findsNothing);
    expect(find.byKey(const ValueKey('v6-action-delay')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the result offers no Back that would discard the card', (
    tester,
  ) async {
    await tester.pumpWidget(
      ExcuseMeApp(client: FakeShopIdeaClient('Idea'), disableAnimations: true),
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
      final finder = find.byKey(ValueKey(key));
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byKey(const ValueKey('card-viewer-continue')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('v6-result')), findsOneWidget);
    expect(find.byKey(const ValueKey('v6-back')), findsNothing);
    // Leaving the result is deliberate: another card, or start over.
    expect(find.byKey(const ValueKey('restart-shop')), findsOneWidget);
    expect(find.byKey(const ValueKey('v6-another-card')), findsOneWidget);
  });

  testWidgets('the shop shows progress and repeats the last answer back', (
    tester,
  ) async {
    await tester.pumpWidget(
      ExcuseMeApp(client: FakeShopIdeaClient('Idea'), disableAnimations: true),
    );
    for (final key in [
      'v6-entry-cta',
      'v6-intent-getOutOfPlans',
      'v6-action-cancel',
      'v6-context-social',
    ]) {
      final finder = find.byKey(ValueKey(key));
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    // Progress, and Wick echoing the answer just given -- no tappable trail.
    expect(find.text('Step 4 of 6'), findsOneWidget);
    expect(find.text('Social plans.'), findsOneWidget);
    expect(find.byKey(const ValueKey('v6-answer-echo')), findsOneWidget);
    expect(find.byKey(const ValueKey('v6-answer-action')), findsNothing);

    // Back still walks the answers, and forgets the ones after it.
    await tester.tap(find.byKey(const ValueKey('v6-back')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('v6-step-context')), findsOneWidget);
    expect(find.text('Step 3 of 6'), findsOneWidget);
    expect(find.text('Cancel something.'), findsOneWidget);
  });

  testWidgets('the result shows neither progress nor an echo', (tester) async {
    await tester.pumpWidget(
      ExcuseMeApp(client: FakeShopIdeaClient('Idea'), disableAnimations: true),
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
      final finder = find.byKey(ValueKey(key));
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byKey(const ValueKey('card-viewer-continue')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('v6-result')), findsOneWidget);
    expect(find.byKey(const ValueKey('v6-step-indicator')), findsNothing);
    expect(find.byKey(const ValueKey('v6-answer-echo')), findsNothing);
  });
}
