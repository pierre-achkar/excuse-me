import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:excuse_me/domain/excuse_request.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:excuse_me/ui/card_viewer.dart';

const testIdea = GeneratedIdea(
  idea: 'Idea: Use a clear boundary for this visit.',
  kernelId: 'viewer-test-card',
  playfulName: 'Boundary Card',
  family: ExcuseFamily.capacityWellbeing,
);

void main() {
  testWidgets('reveal stays open until Continue', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CardViewerPage(
          idea: testIdea,
          mode: CardViewerMode.reveal,
          disableAnimations: true,
        ),
      ),
    );

    await tester.pump();
    expect(find.byKey(const ValueKey('card-viewer')), findsOneWidget);
    expect(find.byKey(const ValueKey('card-viewer-expanded')), findsOneWidget);
    expect(find.byKey(const ValueKey('card-viewer-continue')), findsOneWidget);
    expect(find.byKey(const ValueKey('card-viewer-another')), findsNothing);

    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const ValueKey('card-viewer')), findsOneWidget);
  });

  testWidgets('system reduced motion skips expansion', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: const CardViewerPage(
            idea: testIdea,
            mode: CardViewerMode.reveal,
          ),
        ),
      ),
    );
    await tester.pump();

    final fade = tester.widget<FadeTransition>(
      find.byKey(const ValueKey('card-viewer-expanded')),
    );
    expect(fade.opacity.value, 1);
  });

  testWidgets('Continue dismisses reveal', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => const CardViewerPage(
                  idea: testIdea,
                  mode: CardViewerMode.reveal,
                  disableAnimations: true,
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('card-viewer-continue')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('card-viewer')), findsNothing);
  });

  testWidgets('share receives the visible control anchor', (tester) async {
    Rect? origin;
    await tester.pumpWidget(
      MaterialApp(
        home: CardViewerPage(
          idea: testIdea,
          mode: CardViewerMode.reveal,
          disableAnimations: true,
          onShare:
              (context, idea, repaintBoundaryKey, sharePositionOrigin) async {
                origin = sharePositionOrigin;
              },
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(origin, isNotNull);
    expect(origin!.width, greaterThan(0));
    expect(origin!.height, greaterThan(0));
  });

  testWidgets('saved viewer offers Close and Share but not Another one', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CardViewerPage(
          idea: testIdea,
          mode: CardViewerMode.saved,
          disableAnimations: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('card-viewer-close')), findsOneWidget);
    expect(find.byKey(const ValueKey('card-viewer-share')), findsOneWidget);
    expect(find.byKey(const ValueKey('card-viewer-another')), findsNothing);
  });
}
