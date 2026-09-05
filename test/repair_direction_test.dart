import 'package:excuse_me/app.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _RepairClient implements IdeaClient {
  @override
  Future<String> generate(request) async =>
      'Placeholder: a concise direction that needs the user\'s own wording.';
}

void main() {
  testWidgets('high-obligation conversation offers a repair direction', (
    tester,
  ) async {
    await tester.pumpWidget(ExcuseMeApp(client: _RepairClient()));
    await tester.pumpAndSettle();

    Future<void> choose(String label) async {
      final option = find.text(label);
      await tester.ensureVisible(option);
      await tester.pumpAndSettle();
      await tester.tap(option);
      await tester.pumpAndSettle();
    }

    await choose('A group work call');
    await choose('Last minute');
    await choose('Someone in charge');
    await choose('Dramatic voice note');
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('pixel-idea-card')), findsOneWidget);
    expect(find.byKey(const Key('repair-direction')), findsOneWidget);
    expect(find.text('Repair direction'), findsOneWidget);
    expect(find.textContaining('phrase in your own words'), findsOneWidget);
  });
}
