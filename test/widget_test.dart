import 'package:excuse_me/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows a generated idea and its actions', (tester) async {
    final client = FakeIdeaClient('Idea: Name a brief scheduling conflict and keep the explanation warm.');

    await tester.pumpWidget(ExcuseMeApp(client: client));

    await tester.enterText(find.byKey(const Key('situation-field')), 'Running late to dinner');
    await tester.tap(find.text('Generate idea'));
    await tester.pumpAndSettle();

    expect(find.text('Your idea'), findsOneWidget);
    expect(find.textContaining('Idea: Name a brief scheduling conflict'), findsOneWidget);
    expect(find.text('Regenerate'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
  });
}

class FakeIdeaClient implements IdeaClient {
  FakeIdeaClient(this.idea);

  final String idea;

  @override
  Future<String> generate(IdeaRequest request) async => idea;
}
