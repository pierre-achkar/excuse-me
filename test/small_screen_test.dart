import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:excuse_me/app.dart';

import 'excuse_shop_test.dart' show FakeShopIdeaClient;

void main() {
  testWidgets('a small screen reaches every step without scrolling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ExcuseMeApp(client: FakeShopIdeaClient('Idea'), disableAnimations: true),
    );

    // The way in is reachable without scrolling: nothing on the entry
    // screen hints that there is more below it.
    await tester.tap(find.byKey(const ValueKey('v6-entry-cta')));
    await tester.pumpAndSettle();

    for (final key in [
      'v6-intent-getOutOfPlans',
      'v6-action-cancel',
      'v6-context-social',
      'v6-timing-today',
      'v6-relationship-casual',
      'v6-obligation-low',
    ]) {
      final finder = find.byKey(ValueKey(key));
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byKey(const ValueKey('card-viewer-continue')));
    await tester.pumpAndSettle();

    // And the result's actions sit outside the scroll view, so a full-height
    // card cannot push them out of reach.
    final open = find.byKey(const ValueKey('v6-see-card'));
    expect(
      find.ancestor(of: open, matching: find.byType(Scrollable)),
      findsNothing,
    );
    await tester.tap(open);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('card-viewer')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a tall screen still gives the shop its full welcome', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ExcuseMeApp(client: FakeShopIdeaClient('Idea'), disableAnimations: true),
    );
    await tester.pumpAndSettle();

    final scene = tester.getSize(
      find.byKey(const ValueKey('shopkeeper-stage')),
    );
    expect(scene.height, greaterThan(360));
    await tester.tap(find.byKey(const ValueKey('v6-entry-cta')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('v6-step-intent')), findsOneWidget);
  });
}
