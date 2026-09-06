import 'package:excuse_me/app.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _DesignIdeaClient implements IdeaClient {
  @override
  Future<String> generate(request) async =>
      'Idea: The claim stays brief and leaves room for a clear answer.';
}

Future<void> _completeV6Conversation(WidgetTester tester) async {
  for (final key in [
    'v6-entry-cta',
    'v6-intent-getOutOfPlans',
    'v6-action-cancel',
    'v6-context-social',
    'v6-timing-today',
    'v6-relationship-casual',
    'v6-obligation-low',
  ]) {
    final option = find.byKey(ValueKey(key));
    await tester.ensureVisible(option);
    await tester.tap(option);
    await tester.pump();
  }
  await tester.pumpAndSettle();
  final reveal = find.byKey(const ValueKey('card-viewer-continue'));
  if (reveal.evaluate().isNotEmpty) {
    await tester.tap(reveal);
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('shop applies the v6 shop scene and entry contract', (
    tester,
  ) async {
    await tester.pumpWidget(
      ExcuseMeApp(client: _DesignIdeaClient(), disableAnimations: true),
    );
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme!.scaffoldBackgroundColor, const Color(0xFFFBFAF7));
    expect(find.byKey(const Key('shopkeeper-stage')), findsOneWidget);
    expect(find.byKey(const Key('shopkeeper-avatar')), findsOneWidget);
    expect(find.byKey(const Key('v6-entry-cta')), findsOneWidget);
  });

  testWidgets('v6 search hands over to the collectible result card', (
    tester,
  ) async {
    await tester.pumpWidget(
      ExcuseMeApp(client: _DesignIdeaClient(), disableAnimations: true),
    );

    await _completeV6Conversation(tester);

    expect(find.byKey(const Key('v6-result')), findsOneWidget);
    expect(find.byKey(const Key('collectible-result-card')), findsOneWidget);
    expect(find.text('The idea'), findsOneWidget);
  });

  testWidgets('v6 result uses the pixel collectible card structure', (
    tester,
  ) async {
    await tester.pumpWidget(
      ExcuseMeApp(client: _DesignIdeaClient(), disableAnimations: true),
    );

    await _completeV6Conversation(tester);

    expect(find.byKey(const Key('collectible-result-card')), findsOneWidget);
    expect(find.byKey(const Key('card-idea-body')), findsOneWidget);
    expect(find.byKey(const Key('pixel-card-art')), findsOneWidget);
  });
}
