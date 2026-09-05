import 'package:excuse_me/app.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _DesignIdeaClient implements IdeaClient {
  @override
  Future<String> generate(request) async => 'Placeholder: design test idea.';
}

void main() {
  testWidgets('shop applies the supplied two-layer design system', (
    tester,
  ) async {
    await tester.pumpWidget(ExcuseMeApp(client: _DesignIdeaClient()));
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme!.scaffoldBackgroundColor, const Color(0xFFFBFAF7));
    expect(find.byKey(const Key('shopkeeper-stage')), findsOneWidget);
    expect(find.byKey(const Key('shopkeeper-sprite')), findsOneWidget);
    expect(find.byKey(const Key('reaction-chip-dinner')), findsOneWidget);
  });

  testWidgets('card reveal uses a stepped visible transition', (tester) async {
    await tester.pumpWidget(ExcuseMeApp(client: _DesignIdeaClient()));
    await tester.pumpAndSettle();

    for (final label in [
      "A dinner I can't face",
      'Today',
      'Someone close',
      'Nice text',
    ]) {
      final option = find.text(label);
      await tester.ensureVisible(option);
      await tester.pumpAndSettle();
      await tester.tap(option);
      await tester.pump();
    }

    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump();

    final opacity = find.ancestor(
      of: find.byKey(const Key('pixel-idea-card')),
      matching: find.byType(Opacity),
    );
    expect(opacity, findsOneWidget);
    expect(tester.widget<Opacity>(opacity).opacity, lessThan(1));

    await tester.pump(const Duration(milliseconds: 450));
    expect(tester.widget<Opacity>(opacity).opacity, 1);
  });

  testWidgets('result uses the pixel collectible card structure', (
    tester,
  ) async {
    await tester.pumpWidget(ExcuseMeApp(client: _DesignIdeaClient()));
    await tester.pumpAndSettle();

    for (final label in [
      "A dinner I can't face",
      'Today',
      'Someone close',
      'Nice text',
    ]) {
      final option = find.text(label);
      await tester.ensureVisible(option);
      await tester.pumpAndSettle();
      await tester.tap(option);
      await tester.pumpAndSettle();
    }

    expect(find.byKey(const Key('pixel-idea-card')), findsOneWidget);
    expect(find.text('the claim'), findsOneWidget);
    expect(find.byKey(const Key('pixel-card-art')), findsOneWidget);
  });
}
