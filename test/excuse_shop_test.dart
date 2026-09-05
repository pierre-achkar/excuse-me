import 'package:excuse_me/app.dart';
import 'package:excuse_me/domain/excuse_request.dart';
import 'package:excuse_me/domain/idea_request.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeShopIdeaClient implements IdeaClient {
  FakeShopIdeaClient(this.idea);

  final String idea;
  int callCount = 0;
  List<IdeaRequest> receivedRequests = [];

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
  int callCount = 0;

  @override
  Future<String> generate(IdeaRequest request) async {
    callCount++;
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

Future<void> chooseShopOption(WidgetTester tester, String label) async {
  final option = find.text(label);
  await tester.ensureVisible(option);
  await tester.pumpAndSettle();
  await tester.tap(option);
  await tester.pumpAndSettle();
}

Future<void> completeShopConversation(
  WidgetTester tester, {
  String damage = "A dinner I can't face",
  String timing = 'Today',
  String audience = 'Someone close',
  String delivery = 'Nice text',
  bool settleFinal = true,
}) async {
  await chooseShopOption(tester, damage);
  await chooseShopOption(tester, timing);
  await chooseShopOption(tester, audience);

  final deliveryOption = find.text(delivery);
  await tester.ensureVisible(deliveryOption);
  await tester.pumpAndSettle();
  await tester.tap(deliveryOption);
  await tester.pump();
  if (settleFinal) {
    await tester.pumpAndSettle();
  }
}

void main() {
  group('Excuse Shop', () {
    testWidgets('shopkeeper opens the four-beat conversation', (tester) async {
      final client = FakeShopIdeaClient('Idea: test');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      expect(find.text('The Excuse Shop'), findsOneWidget);
      expect(find.textContaining('shopkeeper'), findsOneWidget);
      expect(find.text("What's the damage?"), findsOneWidget);
      expect(find.text("A dinner I can't face"), findsOneWidget);
      expect(find.text('A party I said yes to'), findsOneWidget);
      expect(find.text('A group work call'), findsOneWidget);
      expect(find.text('A date I\'m dreading'), findsOneWidget);
      expect(find.text('I missed something'), findsOneWidget);
      expect(find.byKey(const Key('shopkeeper-avatar')), findsOneWidget);
      expect(find.byKey(const Key('shopkeeper-stage')), findsOneWidget);
    });

    testWidgets('each beat replaces the previous response set', (tester) async {
      final client = FakeShopIdeaClient('Idea: test');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      expect(find.text('Step 1 of 4'), findsOneWidget);
      expect(
        find.bySemanticsLabel("Choose damage: A dinner I can't face"),
        findsOneWidget,
      );

      await chooseShopOption(tester, "A dinner I can't face");
      expect(find.text("When's the reckoning?"), findsOneWidget);
      expect(find.text('Step 2 of 4'), findsOneWidget);
      expect(find.text('Planned ahead'), findsOneWidget);
      expect(find.text('Already missed'), findsOneWidget);

      await chooseShopOption(tester, 'Today');
      expect(find.text("Who's on the other end?"), findsOneWidget);
      expect(find.text('Step 3 of 4'), findsOneWidget);
      expect(find.text('Someone close'), findsOneWidget);
      expect(find.text('Someone in charge'), findsOneWidget);

      await chooseShopOption(tester, 'Someone close');
      expect(find.text('How loud do you want this?'), findsOneWidget);
      expect(find.text('Step 4 of 4'), findsOneWidget);
      expect(find.text('Low-key text'), findsOneWidget);
      expect(find.text('Unhinged call'), findsOneWidget);
    });

    testWidgets('typed four-beat request reaches the local idea client', (
      tester,
    ) async {
      final client = FakeShopIdeaClient('Idea: test');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      await completeShopConversation(tester);

      final request = client.receivedRequests.single.structuredRequest!;
      expect(request.intent, ExcuseIntent.getOutOfPlans);
      expect(request.action, ExcuseAction.cancel);
      expect(request.context, ExcuseContext.dinner);
      expect(request.timing, ExcuseTiming.today);
      expect(request.relationship, RelationshipKind.close);
      expect(request.audienceSize, AudienceSize.individual);
      expect(request.channel, ExcuseChannel.text);
      expect(request.tone, ExcuseTone.nice);
    });

    testWidgets('delayed generation has a visible brewing state', (
      tester,
    ) async {
      final client = DelayedShopIdeaClient(
        'Idea: Use a low-detail capacity direction.',
      );
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      await completeShopConversation(tester, settleFinal: false);
      expect(find.text('Brewing your excuse...'), findsOneWidget);
      expect(find.text('Your excuse'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Your excuse'), findsOneWidget);
      expect(find.byKey(const Key('pixel-idea-card')), findsOneWidget);
    });

    testWidgets('result card exposes regenerate, copy, share, and new flow', (
      tester,
    ) async {
      final client = FakeShopIdeaClient(
        'Idea: Use a simple capacity limit and keep the explanation low-detail.',
      );
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      await completeShopConversation(tester);

      expect(find.byKey(const Key('pixel-idea-card')), findsOneWidget);
      expect(find.text('Regenerate'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('New excuse'), findsOneWidget);
      expect(
        find.textContaining('Use a simple capacity limit'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Regenerate excuse'), findsOneWidget);
      expect(find.bySemanticsLabel('Start new excuse'), findsOneWidget);
    });

    testWidgets('regenerate calls the local client again', (tester) async {
      final client = FakeShopIdeaClient('Idea: test');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();
      await completeShopConversation(tester);

      expect(client.callCount, 1);
      await tester.tap(find.text('Regenerate'));
      await tester.pumpAndSettle();
      expect(client.callCount, 2);
    });

    testWidgets('recovery path preserves typed metadata and repair direction', (
      tester,
    ) async {
      final client = FakeShopIdeaClient('Idea: planning mix-up direction');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      await completeShopConversation(
        tester,
        damage: 'I missed something',
        timing: 'Already missed',
        audience: 'Someone familiar',
        delivery: 'Funny text',
      );

      final request = client.receivedRequests.single.structuredRequest!;
      expect(request.intent, ExcuseIntent.recoverFromSituation);
      expect(request.action, ExcuseAction.explainAbsence);
      expect(request.context, ExcuseContext.work);
      expect(request.timing, ExcuseTiming.alreadyMissed);
      expect(request.relationship, RelationshipKind.familiar);
      expect(request.tone, ExcuseTone.funny);
      expect(find.byKey(const Key('repair-direction')), findsOneWidget);
    });

    testWidgets('generation failure stays inline and actionable', (
      tester,
    ) async {
      await tester.pumpWidget(ExcuseMeApp(client: FakeFailingClient()));
      await tester.pumpAndSettle();

      await completeShopConversation(tester);
      expect(find.textContaining('Unable to'), findsOneWidget);
      expect(find.text('New excuse'), findsOneWidget);
    });

    testWidgets('new excuse returns to the shop entrance', (tester) async {
      final client = FakeShopIdeaClient('Idea: test');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();
      await completeShopConversation(tester);

      await tester.tap(find.text('New excuse'));
      await tester.pumpAndSettle();

      expect(find.text("What's the damage?"), findsOneWidget);
      expect(find.text('Step 1 of 4'), findsOneWidget);
      expect(find.byKey(const Key('pixel-idea-card')), findsNothing);
    });

    testWidgets('legacy free-form form elements remain absent', (tester) async {
      await tester.pumpWidget(
        ExcuseMeApp(client: FakeShopIdeaClient('Idea: test')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('situation-field')), findsNothing);
      expect(find.text('What happened?'), findsNothing);
      expect(find.text('Find a way to explain it.'), findsNothing);
    });

    testWidgets('reduced motion still reaches a result', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: ExcuseMeApp(client: FakeShopIdeaClient('Idea: test')),
        ),
      );
      await tester.pumpAndSettle();

      await completeShopConversation(tester);
      expect(find.text('Your excuse'), findsOneWidget);
    });

    testWidgets('short screens keep the conversation and card usable', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ExcuseMeApp(client: FakeShopIdeaClient('Idea: test')),
      );
      await tester.pumpAndSettle();
      await completeShopConversation(tester);

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('pixel-idea-card')), findsOneWidget);
      expect(find.bySemanticsLabel('Start new excuse'), findsOneWidget);
    });
  });
}
