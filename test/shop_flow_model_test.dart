import 'package:excuse_me/domain/excuse_request.dart';
import 'package:excuse_me/domain/shop_selection.dart';
import 'package:flutter_test/flutter_test.dart';

ExcuseRequest _request({
  required ShopIntentOption intent,
  required ShopActionOption action,
  required ShopObligationOption obligation,
  ShopTimingOption? timing,
}) {
  return requestForV6Selections(
    intent: intent,
    action: action,
    context: shopContextOptions.singleWhere((o) => o.id == 'work-study'),
    timing: timing,
    relationship: shopRelationshipOptions.singleWhere((o) => o.id == 'formal'),
    obligation: obligation,
  );
}

ShopIntentOption _intent(String id) =>
    shopIntentOptions.singleWhere((o) => o.id == id);

ShopActionOption _action(ExcuseIntent intent, String id) =>
    shopActionOptionsFor(intent).singleWhere((o) => o.id == id);

ShopObligationOption _obligation(String id) =>
    shopObligationOptions.singleWhere((o) => o.id == id);

void main() {
  test('the v6 conversation exposes bounded beats with typed mappings', () {
    expect(shopIntentOptions.length, 3);
    expect(shopContextOptions.length, 4);
    expect(shopRelationshipOptions.length, 3);
    expect(shopObligationOptions.length, 3);
    for (final intent in ExcuseIntent.values.take(3)) {
      expect(shopActionOptionsFor(intent).length, 3);
    }

    final request = _request(
      intent: _intent('need-out'),
      action: _action(ExcuseIntent.getOutOfPlans, 'cancel'),
      timing: shopTimingOptionsFor(
        _action(ExcuseIntent.getOutOfPlans, 'cancel'),
      ).singleWhere((o) => o.id == 'today'),
      obligation: _obligation('low'),
    );

    expect(request.intent, ExcuseIntent.getOutOfPlans);
    expect(request.action, ExcuseAction.cancel);
    expect(request.context, ExcuseContext.workStudy);
    expect(request.timing, ExcuseTiming.today);
    expect(request.relationship, RelationshipKind.formal);
    expect(request.obligation, ObligationLevel.low);
    expect(request.repairPreference, RepairOption.none);
  });

  test('a beat that describes something already past skips timing', () {
    final acknowledge = _action(
      ExcuseIntent.recoverFromSituation,
      'acknowledge-miss',
    );
    expect(shopTimingOptionsFor(acknowledge), isEmpty);
    expect(
      _request(
        intent: _intent('already-messed-up'),
        action: acknowledge,
        obligation: _obligation('low'),
      ).timing,
      ExcuseTiming.alreadyHappened,
    );
  });

  test('repair is carried by the request the conversation builds', () {
    // A recovery earns one.
    expect(
      _request(
        intent: _intent('already-messed-up'),
        action: _action(
          ExcuseIntent.recoverFromSituation,
          'explain-what-happened',
        ),
        obligation: _obligation('low'),
      ).repairPreference,
      RepairOption.briefApology,
    );

    // So do high stakes, even when nothing has gone wrong yet.
    expect(
      _request(
        intent: _intent('need-out'),
        action: _action(ExcuseIntent.getOutOfPlans, 'cancel'),
        timing: shopTimingOptionsFor(
          _action(ExcuseIntent.getOutOfPlans, 'cancel'),
        ).singleWhere((o) => o.id == 'last-minute'),
        obligation: _obligation('high'),
      ).repairPreference,
      RepairOption.briefApology,
    );
  });
}
