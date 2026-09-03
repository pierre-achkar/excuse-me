import 'package:excuse_me/app.dart';
import 'package:excuse_me/domain/idea_request.dart';
import 'package:excuse_me/services/idea_client.dart';
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
  testWidgets('excuse shop shows mission choices and result', (tester) async {
    final client = FakeShopIdeaClient(
      'Idea: Use a simple capacity limit, keep the explanation low-detail, and offer a respectful alternative.',
    );

    await tester.pumpWidget(ExcuseMeApp(client: client));
    await tester.pumpAndSettle();

    expect(find.text('The Excuse Shop'), findsOneWidget);
    expect(find.text('Get out of plans'), findsOneWidget);

    await tester.tap(find.text('Get out of plans'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dinner'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Straightforward'));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    expect(find.text('Your excuse'), findsOneWidget);
    expect(find.text('Regenerate'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
  });
}
