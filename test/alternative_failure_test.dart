import 'package:excuse_me/app.dart';
import 'package:excuse_me/domain/idea_request.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailsAlternativeClient implements IdeaClient, DetailedIdeaClient {
  var calls = 0;

  @override
  Future<String> generate(IdeaRequest request) async => 'Idea';

  @override
  Future<GeneratedIdea> generateDetailed(IdeaRequest request) async {
    calls += 1;
    if (calls > 1) throw StateError('alternative unavailable');
    return const GeneratedIdea(
      idea: 'Idea: keep the current explanation brief.',
      kernelId: 'first-card',
      playfulName: 'First card',
    );
  }
}

Future<void> _choose(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pump();
}

void main() {
  testWidgets('failed alternative keeps the current card available', (
    tester,
  ) async {
    final client = _FailsAlternativeClient();
    await tester.pumpWidget(
      ExcuseMeApp(client: client, disableAnimations: true),
    );
    for (final key in [
      'v6-entry-cta',
      'v6-intent-getOutOfPlans',
      'v6-action-cancel',
      'v6-context-social',
      'v6-timing-today',
      'v6-relationship-casual',
      'v6-obligation-low',
    ]) {
      await _choose(tester, key);
    }
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('card-viewer-continue')));
    await tester.pumpAndSettle();
    final another = find.byKey(const ValueKey('v6-another-card'));
    await tester.ensureVisible(another);
    await tester.tap(another);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('card-idea-body')), findsOneWidget);
    expect(find.text('First card'), findsOneWidget);
    expect(find.textContaining('alternative'), findsOneWidget);
  });
}
