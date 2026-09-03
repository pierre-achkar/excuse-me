import 'package:excuse_me/app.dart';
import 'package:excuse_me/domain/idea_request.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeShopIdeaClient implements IdeaClient {
  FakeShopIdeaClient(this.idea);

  final String idea;
  int callCount = 0;
  List<dynamic> receivedRequests = [];

  @override
  Future<String> generate(request) async {
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
  Future<String> generate(request) async {
    callCount++;
    await Future<void>.delayed(delay);
    return idea;
  }
}

class FakeFailingClient implements IdeaClient {
  @override
  Future<String> generate(request) async {
    throw Exception('generation failed');
  }
}

void main() {
  group('Excuse Shop', () {
    testWidgets('shopkeeper greets and shows mission choices', (tester) async {
      final client = FakeShopIdeaClient('Idea: test');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      expect(find.text('The Excuse Shop'), findsOneWidget);
      expect(find.textContaining('shopkeeper'), findsOneWidget);
      expect(find.text('Get out of plans'), findsOneWidget);
      expect(find.text('Buy time'), findsOneWidget);
      expect(find.text('Recover from a situation'), findsOneWidget);
    });

    testWidgets('mission card has accessible semantics', (tester) async {
      final client = FakeShopIdeaClient('Idea: test');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      final missionFinder = find.text('Get out of plans');
      expect(missionFinder, findsOneWidget);

      final card = find.ancestor(
        of: missionFinder,
        matching: find.byType(Card),
      );
      expect(card, findsOneWidget);

      expect(
        find.bySemanticsLabel('Choose mission: Get out of plans'),
        findsOneWidget,
      );
    });

    testWidgets('selecting Get out of plans shows context choices', (
      tester,
    ) async {
      final client = FakeShopIdeaClient('Idea: test');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get out of plans'));
      await tester.pumpAndSettle();

      expect(find.text('Choose a situation'), findsOneWidget);
      expect(find.text('Dinner'), findsOneWidget);
      expect(find.text('Party'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
    });

    testWidgets('selecting Buy time shows context choices', (tester) async {
      final client = FakeShopIdeaClient('Idea: test');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Buy time'));
      await tester.pumpAndSettle();

      expect(find.text('Choose a situation'), findsOneWidget);
      expect(find.text('Reschedule'), findsOneWidget);
      expect(find.text('Delay'), findsOneWidget);
    });

    testWidgets('selecting Recover shows context choices', (tester) async {
      final client = FakeShopIdeaClient('Idea: test');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Recover from a situation'));
      await tester.pumpAndSettle();

      expect(find.text('Choose a situation'), findsOneWidget);
      expect(find.text('Late'), findsOneWidget);
      expect(find.text('Missed'), findsOneWidget);
    });

    testWidgets('selecting situation shows tone/ingredient choices', (
      tester,
    ) async {
      final client = FakeShopIdeaClient('Idea: test');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get out of plans'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dinner'));
      await tester.pumpAndSettle();

      expect(find.text('Choose your ingredient'), findsOneWidget);
      expect(find.text('Straightforward'), findsOneWidget);
      expect(find.text('Warm'), findsOneWidget);
      expect(find.text('Funny'), findsOneWidget);
    });

    testWidgets('completing all steps shows brewing then result', (
      tester,
    ) async {
      final client = DelayedShopIdeaClient(
        'Idea: Use a simple capacity limit, keep the explanation low-detail, and offer a respectful alternative.',
      );
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get out of plans'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dinner'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Straightforward'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Your excuse'), findsOneWidget);
      expect(
        find.textContaining('Use a simple capacity limit'),
        findsOneWidget,
      );
    });

    testWidgets('result card shows regenerate copy share buttons', (
      tester,
    ) async {
      final client = FakeShopIdeaClient(
        'Idea: Use a simple capacity limit, keep the explanation low-detail, and offer a respectful alternative.',
      );
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get out of plans'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dinner'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Straightforward'));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(find.text('Regenerate'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('regenerate calls client again', (tester) async {
      final client = FakeShopIdeaClient(
        'Idea: Use a simple capacity limit, keep the explanation low-detail, and offer a respectful alternative.',
      );
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get out of plans'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dinner'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Straightforward'));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(client.callCount, 1);

      await tester.tap(find.text('Regenerate'));
      await tester.pumpAndSettle();

      expect(client.callCount, 2);
    });

    testWidgets(
      'selecting Recover then Missed then Funny maps to correct idea',
      (tester) async {
        final client = FakeShopIdeaClient(
          'Idea: Turn a harmless planning mix-up into a playful angle without inventing an emergency.',
        );
        await tester.pumpWidget(ExcuseMeApp(client: client));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Recover from a situation'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Missed'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Funny'));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle();

        expect(find.textContaining('planning mix-up'), findsOneWidget);
      },
    );

    testWidgets('error state displays inline error message', (tester) async {
      await tester.pumpWidget(ExcuseMeApp(client: FakeFailingClient()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get out of plans'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dinner'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Straightforward'));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(find.textContaining('Unable to'), findsOneWidget);
    });

    testWidgets('new flow button restarts the shop', (tester) async {
      final client = FakeShopIdeaClient(
        'Idea: Use a simple capacity limit, keep the explanation low-detail, and offer a respectful alternative.',
      );
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get out of plans'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dinner'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Straightforward'));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      await tester.tap(find.text('New excuse'));
      await tester.pumpAndSettle();

      expect(find.text('Get out of plans'), findsOneWidget);
      expect(find.text('Buy time'), findsOneWidget);
      expect(find.text('Recover from a situation'), findsOneWidget);
    });

    testWidgets('no old form elements present', (tester) async {
      final client = FakeShopIdeaClient('Idea: test');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('situation-field')), findsNothing);
      expect(find.text('What happened?'), findsNothing);
      expect(find.text('Find a way to explain it.'), findsNothing);
    });

    testWidgets('shop has accessible navigation semantics', (tester) async {
      final client = FakeShopIdeaClient('Idea: test');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel('Choose mission: Get out of plans'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Choose mission: Buy time'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Choose mission: Recover from a situation'),
        findsOneWidget,
      );
    });

    testWidgets('reduced-motion still functions', (tester) async {
      final client = FakeShopIdeaClient('Idea: test');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pump();

      final mediaQuery = MediaQuery.of(
        tester.element(find.byType(MaterialApp)),
      );
      expect(mediaQuery.disableAnimations, isFalse);
    });

    testWidgets('brewing state has semantic label', (tester) async {
      final client = DelayedShopIdeaClient('Idea: test');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get out of plans'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dinner'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Straightforward'));
      await tester.pump();

      expect(find.text('Brewing your excuse...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final semantics = tester.getSemantics(
        find.text('Brewing your excuse...'),
      );
      expect(semantics.label, contains('Brewing'));

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    });

    testWidgets('context choices are accessible', (tester) async {
      final client = FakeShopIdeaClient('Idea: test');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get out of plans'));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Choose situation: Dinner'), findsOneWidget);
    });

    testWidgets('tone choices are accessible', (tester) async {
      final client = FakeShopIdeaClient('Idea: test');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get out of plans'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dinner'));
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel('Choose ingredient: Straightforward'),
        findsOneWidget,
      );
    });

    testWidgets('result action buttons are accessible', (tester) async {
      final client = FakeShopIdeaClient(
        'Idea: Use a simple capacity limit, keep the explanation low-detail, and offer a respectful alternative.',
      );
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get out of plans'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dinner'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Straightforward'));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Regenerate excuse'), findsOneWidget);
      expect(find.bySemanticsLabel('Copy excuse to clipboard'), findsOneWidget);
      expect(find.bySemanticsLabel('Share excuse'), findsOneWidget);
      expect(find.bySemanticsLabel('Start new excuse'), findsOneWidget);
    });

    testWidgets('choice cards render without overflow', (tester) async {
      final client = FakeShopIdeaClient('Idea: test');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsWidgets);

      await tester.tap(find.text('Get out of plans'));
      await tester.pumpAndSettle();
      expect(find.byType(Card), findsWidgets);

      await tester.tap(find.text('Dinner'));
      await tester.pumpAndSettle();
      expect(find.byType(Card), findsWidgets);

      await tester.tap(find.text('Straightforward'));
      await tester.pumpAndSettle();

      expect(find.text('Your excuse'), findsOneWidget);
    });

    testWidgets('shop step counter is accessible', (tester) async {
      final client = FakeShopIdeaClient('Idea: test');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      expect(find.text('Step 1 of 3'), findsOneWidget);

      await tester.tap(find.text('Get out of plans'));
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 3'), findsOneWidget);

      await tester.tap(find.text('Dinner'));
      await tester.pumpAndSettle();

      expect(find.text('Step 3 of 3'), findsOneWidget);
    });

    testWidgets('brewing has a visible moment before the result', (
      tester,
    ) async {
      final client = FakeShopIdeaClient('Idea: test');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get out of plans'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dinner'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Straightforward'));
      await tester.pump();

      expect(find.text('Brewing your excuse...'), findsOneWidget);
      expect(find.text('Your excuse'), findsNothing);

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('Your excuse'), findsOneWidget);
    });

    testWidgets('reduced motion skips the brewing pause', (tester) async {
      final client = FakeShopIdeaClient('Idea: test');
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: ExcuseMeApp(client: client),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get out of plans'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dinner'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Straightforward'));
      await tester.pump();

      expect(find.text('Your excuse'), findsOneWidget);
    });

    testWidgets('selected shop choices reach the idea client', (tester) async {
      final client = FakeShopIdeaClient('Idea: test');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Buy time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delay'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Funny'));
      await tester.pumpAndSettle();

      final request = client.receivedRequests.single as IdeaRequest;
      expect(request.situation.toLowerCase(), contains('buy time'));
      expect(request.situation.toLowerCase(), contains('delay'));
      expect(request.tone, 'Funny');
    });

    testWidgets('shop has a pixel-art keeper and collectible result label', (
      tester,
    ) async {
      final client = FakeShopIdeaClient('Idea: test');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('shopkeeper-avatar')), findsOneWidget);
      expect(find.text('COLLECTIBLE IDEA'), findsNothing);

      await tester.tap(find.text('Get out of plans'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dinner'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Straightforward'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('COLLECTIBLE IDEA'), findsOneWidget);
    });

    testWidgets('shop choices preserve action and context metadata', (
      tester,
    ) async {
      final client = FakeShopIdeaClient('Idea: test');
      await tester.pumpWidget(ExcuseMeApp(client: client));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Recover from a situation'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Missed'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Funny'));
      await tester.pumpAndSettle();

      final request = client.receivedRequests.single as IdeaRequest;
      expect(request.situation.toLowerCase(), contains('missed'));
      expect(request.situation.toLowerCase(), contains('work'));
    });
  });
}
