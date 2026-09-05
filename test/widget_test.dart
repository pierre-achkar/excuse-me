import 'package:excuse_me/app.dart';
import 'package:excuse_me/domain/idea_request.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeShopIdeaClient implements IdeaClient {
  FakeShopIdeaClient(this.idea);

  final String idea;
  bool called = false;

  @override
  Future<String> generate(IdeaRequest request) async {
    called = true;
    return idea;
  }
}

void main() {
  testWidgets('excuse shop shows the conversation and result card', (
    tester,
  ) async {
    final client = FakeShopIdeaClient(
      'Idea: Use a simple capacity limit, keep the explanation low-detail, and offer a respectful alternative.',
    );

    await tester.pumpWidget(ExcuseMeApp(client: client));
    await tester.pumpAndSettle();

    expect(find.text('The Excuse Shop'), findsOneWidget);
    expect(find.text("What's the damage?"), findsOneWidget);

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

    expect(client.called, isTrue);
    expect(find.text('Your excuse'), findsOneWidget);
    expect(find.byKey(const Key('pixel-idea-card')), findsOneWidget);
    expect(find.text('Regenerate'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
  });
}
