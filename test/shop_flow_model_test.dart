import 'package:excuse_me/domain/excuse_request.dart';
import 'package:excuse_me/domain/shop_selection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shop dialogue exposes four bounded beats with typed mappings', () {
    expect(shopDamageOptions.length, 5);
    expect(shopTimingOptions.length, 5);
    expect(shopAudienceOptions.length, 5);
    expect(shopDeliveryOptions.length, 5);

    final request = requestForShopSelections(
      damage: shopDamageOptions.singleWhere((option) => option.id == 'dinner'),
      timing: shopTimingOptions.singleWhere((option) => option.id == 'today'),
      audience: shopAudienceOptions.singleWhere(
        (option) => option.id == 'someone-close',
      ),
      delivery: shopDeliveryOptions.singleWhere(
        (option) => option.id == 'nice-text',
      ),
    );

    expect(request.intent, ExcuseIntent.getOutOfPlans);
    expect(request.action, ExcuseAction.cancel);
    expect(request.context, ExcuseContext.dinner);
    expect(request.timing, ExcuseTiming.today);
    expect(request.audienceSize, AudienceSize.individual);
    expect(request.relationship, RelationshipKind.close);
    expect(request.channel, ExcuseChannel.text);
    expect(request.tone, ExcuseTone.nice);
    expect(request.obligation, ObligationLevel.expected);
  });

  test('repair is offered for recovery and high-obligation requests', () {
    final recovery = requestForShopSelections(
      damage: shopDamageOptions.singleWhere((option) => option.id == 'missed'),
      timing: shopTimingOptions.singleWhere(
        (option) => option.id == 'already-missed',
      ),
      audience: shopAudienceOptions.singleWhere(
        (option) => option.id == 'work-contact',
      ),
      delivery: shopDeliveryOptions.singleWhere(
        (option) => option.id == 'low-key-text',
      ),
    );

    final highObligation = requestForShopSelections(
      damage: shopDamageOptions.singleWhere(
        (option) => option.id == 'group-work-call',
      ),
      timing: shopTimingOptions.singleWhere(
        (option) => option.id == 'last-minute',
      ),
      audience: shopAudienceOptions.singleWhere(
        (option) => option.id == 'someone-in-charge',
      ),
      delivery: shopDeliveryOptions.singleWhere(
        (option) => option.id == 'dramatic-voice-note',
      ),
    );

    expect(shouldOfferRepair(recovery), isTrue);
    expect(shouldOfferRepair(highObligation), isTrue);
  });
}
