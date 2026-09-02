import 'package:excuse_me/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows a generated idea and its actions', (tester) async {
    final client = FakeIdeaClient('Idea: Name a brief scheduling conflict and keep the explanation warm.');

    await tester.pumpWidget(ExcuseMeApp(client: client));

    await tester.enterText(find.byKey(const Key('situation-field')), 'Running late to dinner');
    await tester.pump();
    await tester.ensureVisible(find.byType(FilledButton));
    final generateButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(generateButton.onPressed, isNotNull);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Your idea'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Your idea'), findsOneWidget);
    expect(find.textContaining('Idea: Name a brief scheduling conflict'), findsOneWidget);
    expect(find.text('Regenerate'), findsNWidgets(2));
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
  });
}

class FakeIdeaClient implements IdeaClient {
  FakeIdeaClient(this.idea);

  final String idea;

  bool called = false;

  @override
  Future<String> generate(IdeaRequest request) async {
    called = true;
    return idea;
  }
}
