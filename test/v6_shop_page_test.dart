import 'package:shared_preferences/shared_preferences.dart';
import 'package:excuse_me/app.dart';
import 'package:excuse_me/domain/excuse_kernel.dart';
import 'package:excuse_me/domain/idea_request.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _V6Client implements IdeaClient, DetailedIdeaClient {
  @override
  Future<String> generate(IdeaRequest request) async =>
      'Idea: Keep the answer brief.';

  @override
  Future<GeneratedIdea> generateDetailed(IdeaRequest request) async {
    return const GeneratedIdea(
      idea: 'Idea: Keep the answer brief.',
      kernelId: 'v6-test-kernel',
      playfulName: 'The Brief Lantern',
      family: ExcuseFamily.boundaryPreference,
      toneDirections: {
        ExcuseTone.lowKey: 'Idea: Keep the answer brief.',
        ExcuseTone.nice: 'Idea: Keep the answer warm.',
        ExcuseTone.funny: 'Idea: Keep the answer lightly absurd.',
      },
    );
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets('v6 shop completes the six-beat conversation and keeps locally', (
    tester,
  ) async {
    await tester.pumpWidget(
      ExcuseMeApp(client: _V6Client(), disableAnimations: true),
    );

    expect(find.text('I NEED AN EXCUSE'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('v6-entry-cta')));
    await tester.pump();
    expect(find.text("Now then... what's the situation?"), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('v6-intent-getOutOfPlans')));
    await tester.pump();
    expect(find.text("Ah. An escape. What's the plan?"), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('v6-action-cancel')));
    await tester.pump();
    expect(find.text('Where is this trouble taking place?'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('v6-context-social')));
    await tester.pump();
    expect(find.text('When does the clock start complaining?'), findsOneWidget);

    final timing = find.byKey(const ValueKey('v6-timing-today'));
    await tester.ensureVisible(timing);
    await tester.tap(timing);
    await tester.pump();
    expect(find.text('Who is waiting for an answer?'), findsOneWidget);

    final relationship = find.byKey(const ValueKey('v6-relationship-casual'));
    await tester.ensureVisible(relationship);
    await tester.tap(relationship);
    await tester.pump();
    expect(find.text('How much does this one matter?'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('v6-obligation-low')));
    await tester.pumpAndSettle();
    final reveal = find.byKey(const ValueKey('card-viewer-continue'));
    if (reveal.evaluate().isNotEmpty) {
      await tester.tap(reveal);
      await tester.pumpAndSettle();
    }

    expect(
      find.byKey(const ValueKey('collectible-result-card')),
      findsOneWidget,
    );
    expect(find.text('THE IDEA'), findsOneWidget);
    expect(find.text('KEEP CARD'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('v6-keep-card')));
    await tester.tap(find.byKey(const ValueKey('v6-keep-card')));
    await tester.pumpAndSettle();
    expect(find.text('SAVED TO COLLECTION'), findsOneWidget);
  });
}
