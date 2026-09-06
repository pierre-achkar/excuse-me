import 'package:excuse_me/domain/excuse_request.dart';
import 'package:excuse_me/services/shop_flow_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v6 stages preserve the agreed conversation order', () {
    expect(shopFlowStages, <ShopFlowStage>[
      ShopFlowStage.entry,
      ShopFlowStage.intent,
      ShopFlowStage.action,
      ShopFlowStage.context,
      ShopFlowStage.timing,
      ShopFlowStage.relationship,
      ShopFlowStage.obligation,
      ShopFlowStage.visitContext,
      ShopFlowStage.search,
      ShopFlowStage.result,
      ShopFlowStage.error,
    ]);
  });

  test(
    'fresh sessions rotate outfit palettes without immediate repetition',
    () {
      final controller = ShopFlowController();
      final first = controller.startSession();
      final second = controller.startSession();

      expect(second.outfit.id, isNot(first.outfit.id));
      expect(second.outfit.paletteName, isNot(first.outfit.paletteName));
    },
  );

  test('starting a new session invalidates the previous operation ticket', () {
    final controller = ShopFlowController();
    controller.startSession();
    final ticket = controller.beginOperation();

    expect(controller.accepts(ticket), isTrue);
    controller.startSession();

    expect(controller.accepts(ticket), isFalse);
  });

  test('missed actions are the only actions that skip timing', () {
    expect(skipsTimingFor(ExcuseAction.explainLateness), isTrue);
    expect(skipsTimingFor(ExcuseAction.explainAbsence), isTrue);
    expect(skipsTimingFor(ExcuseAction.acknowledgeMiss), isTrue);
    expect(skipsTimingFor(ExcuseAction.cancel), isFalse);
  });
}
