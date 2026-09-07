import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:excuse_me/app.dart';

import 'excuse_shop_test.dart' show FakeShopIdeaClient;

void main() {
  // Every other test runs with motion switched off, which is exactly the
  // configuration that hid a ticker being created twice. This one runs the
  // shop the way the device does.
  testWidgets('a whole session survives with the shop actually moving', (
    tester,
  ) async {
    await tester.pumpWidget(
      ExcuseMeApp(
        client: FakeShopIdeaClient('Idea: x.'),
        disableAnimations: false,
      ),
    );
    await tester.pump();
    for (final key in [
      'v6-entry-cta',
      'v6-intent-getOutOfPlans',
      'v6-action-cancel',
      'v6-context-social',
      'v6-timing-today',
      'v6-relationship-casual',
      'v6-obligation-low',
    ]) {
      final f = find.byKey(ValueKey(key));
      await tester.ensureVisible(f);
      await tester.tap(f);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(tester.takeException(), isNull, reason: 'during generation');

    await tester.tap(find.byKey(const ValueKey('card-viewer-continue')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull, reason: 'after continue');

    // Leaving and returning toggles TickerMode, which mutes and unmutes the
    // ticker. Recreating or restarting it here is what broke the shop.
    await tester.tap(find.byKey(const ValueKey('nav-collection')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull, reason: 'after leaving shop');

    await tester.tap(find.byKey(const ValueKey('nav-shop')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull, reason: 'after returning to shop');
  });
}
