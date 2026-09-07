import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:excuse_me/app.dart';
import 'package:excuse_me/services/shop_flow_controller.dart';
import 'package:excuse_me/ui/reference_shop_painter.dart';

import 'excuse_shop_test.dart' show FakeShopIdeaClient;

ReferenceShopPainter _painter(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(
    find
        .descendant(
          of: find.byKey(const ValueKey('shopkeeper-stage')),
          matching: find.byType(CustomPaint),
        )
        .first,
  );
  return paint.painter! as ReferenceShopPainter;
}

void main() {
  testWidgets('the shop keeps moving while it is on screen', (tester) async {
    await tester.pumpWidget(ExcuseMeApp(client: FakeShopIdeaClient('Idea')));
    await tester.pump();
    final first = _painter(tester).time;

    await tester.pump(const Duration(milliseconds: 300));
    final second = _painter(tester).time;

    expect(second, greaterThan(first));
    // Left alone it goes on ticking, so nothing here can pumpAndSettle.
    await tester.pump(const Duration(milliseconds: 300));
    expect(_painter(tester).time, greaterThan(second));
  });

  testWidgets('reduced motion holds the shop as a still frame', (tester) async {
    await tester.pumpWidget(
      ExcuseMeApp(client: FakeShopIdeaClient('Idea'), disableAnimations: true),
    );
    await tester.pumpAndSettle();

    expect(_painter(tester).time, 0);
    await tester.pump(const Duration(seconds: 1));
    expect(_painter(tester).time, 0);
  });

  testWidgets('the ambient event the shop names is the one it performs', (
    tester,
  ) async {
    await tester.pumpWidget(
      ExcuseMeApp(client: FakeShopIdeaClient('Idea'), disableAnimations: true),
    );
    await tester.pumpAndSettle();

    final painter = _painter(tester);
    expect(painter.ambientEvent, isNotNull);
    expect(shopAmbientEvents, contains(painter.ambientEvent));
  });

  test('the scene actually redraws differently as time passes', () async {
    Future<List<int>> frameAt(double time) async {
      final recorder = ui.PictureRecorder();
      ReferenceShopPainter(
        outfit: shopOutfits.first,
        mood: 1,
        completed: const [true, false, false],
        time: time,
        seed: 3,
        ambientEvent: shopAmbientEvents.first,
      ).paint(Canvas(recorder), const Size(400, 320));
      final image = await recorder.endRecording().toImage(400, 320);
      final bytes = await image.toByteData();
      return bytes!.buffer.asUint8List();
    }

    final still = await frameAt(0);
    final later = await frameAt(0.7);
    expect(still, isNot(equals(later)));

    // And the same moment always paints the same shop.
    expect(await frameAt(0.7), equals(later));
  });

  test('the stock is restocked between visits', () async {
    Future<List<int>> shopWithSeed(int seed) async {
      final recorder = ui.PictureRecorder();
      ReferenceShopPainter(
        outfit: shopOutfits.first,
        mood: 1,
        completed: const [],
        seed: seed,
      ).paint(Canvas(recorder), const Size(400, 320));
      final image = await recorder.endRecording().toImage(400, 320);
      return (await image.toByteData())!.buffer.asUint8List();
    }

    expect(await shopWithSeed(1), isNot(equals(await shopWithSeed(2))));
  });
}
