import 'package:shared_preferences/shared_preferences.dart';
import 'package:excuse_me/app.dart';
import 'package:flutter/material.dart';
import 'package:excuse_me/domain/idea_request.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeShopIdeaClient implements IdeaClient {
  FakeShopIdeaClient(this.idea);

  final String idea;
  int callCount = 0;
  final receivedRequests = <IdeaRequest>[];

  @override
  Future<String> generate(IdeaRequest request) async {
    callCount++;
    receivedRequests.add(request);
    return idea;
  }
}

class DelayedShopIdeaClient implements IdeaClient {
  DelayedShopIdeaClient(this.idea, {this.delay = const Duration(seconds: 2)});

  final String idea;
  final Duration delay;

  @override
  Future<String> generate(IdeaRequest request) async {
    await Future<void>.delayed(delay);
    return idea;
  }
}

class FakeFailingClient implements IdeaClient {
  @override
  Future<String> generate(IdeaRequest request) async {
    throw Exception('generation failed');
  }
}

Future<void> _tapKey(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
}

Future<void> completeV6Conversation(
  WidgetTester tester, {
  bool settleFinal = true,
}) async {
  await _tapKey(tester, 'v6-entry-cta');
  await _tapKey(tester, 'v6-intent-getOutOfPlans');
  await _tapKey(tester, 'v6-action-cancel');
  await _tapKey(tester, 'v6-context-social');
  await _tapKey(tester, 'v6-timing-today');
  await _tapKey(tester, 'v6-relationship-casual');
  await _tapKey(tester, 'v6-obligation-low');
  if (settleFinal) {
    await tester.pumpAndSettle();
    final reveal = find.byKey(const ValueKey('card-viewer-continue'));
    if (reveal.evaluate().isNotEmpty) {
      await tester.tap(reveal);
      await tester.pumpAndSettle();
    }
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  group('Excuse Shop v6', () {
    testWidgets('entry presents Excusee, scene, paired opening, and CTA', (
      tester,
    ) async {
      await tester.pumpWidget(
        ExcuseMeApp(
          client: FakeShopIdeaClient('Idea: test'),
          disableAnimations: true,
        ),
      );
      await tester.pump();

      expect(find.text('Excuse Me'), findsOneWidget);
      expect(find.text('I need an excuse'), findsOneWidget);
      expect(find.byKey(const ValueKey('shopkeeper-stage')), findsOneWidget);
      expect(find.byKey(const ValueKey('shopkeeper-avatar')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('v6-entry')),
          matching: find.textContaining('What happened'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('action choices depend on the selected intent', (tester) async {
      await tester.pumpWidget(
        ExcuseMeApp(
          client: FakeShopIdeaClient('Idea: test'),
          disableAnimations: true,
        ),
      );
      await _tapKey(tester, 'v6-entry-cta');

      expect(
        find.byKey(const ValueKey('v6-intent-getOutOfPlans')),
        findsOneWidget,
      );
      await _tapKey(tester, 'v6-intent-buyTime');
      expect(
        find.byKey(const ValueKey('v6-action-reschedule')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('v6-action-cancel')), findsNothing);
    });

    testWidgets('typed six-beat request reaches the local client', (
      tester,
    ) async {
      final client = FakeShopIdeaClient('Idea: keep it brief.');
      await tester.pumpWidget(
        ExcuseMeApp(client: client, disableAnimations: true),
      );
      await completeV6Conversation(tester);

      final request = client.receivedRequests.single.structuredRequest!;
      expect(request.intent.name, 'getOutOfPlans');
      expect(request.action.name, 'cancel');
      expect(request.context.name, 'social');
      expect(request.timing.name, 'today');
      expect(request.relationship.name, 'casual');
      expect(request.obligation.name, 'low');
      expect(request.tone.name, 'lowKey');
    });

    testWidgets('recovery action skips timing and maps to already happened', (
      tester,
    ) async {
      final client = FakeShopIdeaClient('Idea: acknowledge the change.');
      await tester.pumpWidget(
        ExcuseMeApp(client: client, disableAnimations: true),
      );
      await _tapKey(tester, 'v6-entry-cta');
      await _tapKey(tester, 'v6-intent-recoverFromSituation');
      await _tapKey(tester, 'v6-action-acknowledgeMiss');
      await _tapKey(tester, 'v6-context-workStudy');

      expect(find.byKey(const ValueKey('v6-step-timing')), findsNothing);
      expect(
        find.byKey(const ValueKey('v6-relationship-formal')),
        findsOneWidget,
      );
      await _tapKey(tester, 'v6-relationship-formal');
      await _tapKey(tester, 'v6-obligation-high');
      await tester.pumpAndSettle();
      final reveal = find.byKey(const ValueKey('card-viewer-continue'));
      if (reveal.evaluate().isNotEmpty) {
        await tester.tap(reveal);
        await tester.pumpAndSettle();
      }

      final request = client.receivedRequests.single.structuredRequest!;
      expect(request.timing.name, 'alreadyHappened');
      expect(find.byKey(const ValueKey('repair-direction')), findsOneWidget);
    });

    testWidgets('delayed generation exposes the search state', (tester) async {
      final client = DelayedShopIdeaClient('Idea: wait briefly.');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await completeV6Conversation(tester, settleFinal: false);

      expect(find.byKey(const ValueKey('v6-search')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('collectible-result-card')),
        findsNothing,
      );

      await tester.pump(const Duration(seconds: 2));
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
    });

    testWidgets('plain client reveals the card and keeps it', (tester) async {
      await tester.pumpWidget(
        ExcuseMeApp(
          client: FakeShopIdeaClient('Idea: keep the explanation low-detail.'),
          disableAnimations: true,
        ),
      );
      await completeV6Conversation(tester);

      expect(
        find.byKey(const ValueKey('collectible-result-card')),
        findsOneWidget,
      );
      expect(find.text('The idea'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const ValueKey('v6-keep-card')));
      await tester.tap(find.byKey(const ValueKey('v6-keep-card')));
      await tester.pumpAndSettle();
      expect(find.text('Saved to collection'), findsOneWidget);
    });

    testWidgets(
      'generation failure stays inline and restart returns to entry',
      (tester) async {
        await tester.pumpWidget(
          ExcuseMeApp(client: FakeFailingClient(), disableAnimations: true),
        );
        await completeV6Conversation(tester);
        expect(find.byKey(const ValueKey('v6-error')), findsOneWidget);
        expect(find.textContaining('Unable to generate'), findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('restart-shop')));
        await tester.pump();
        expect(find.byKey(const ValueKey('v6-entry-cta')), findsOneWidget);
        expect(
          find.byKey(const ValueKey('collectible-result-card')),
          findsNothing,
        );
      },
    );

    testWidgets('short screens keep the v6 card usable', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ExcuseMeApp(
          client: FakeShopIdeaClient('Idea: test'),
          disableAnimations: true,
        ),
      );
      await completeV6Conversation(tester);

      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const ValueKey('collectible-result-card')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('v6-new-excuse')), findsOneWidget);
    });
  });
}
