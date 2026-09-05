import 'package:excuse_me/data/curated_kernel_repository.dart';
import 'package:excuse_me/domain/excuse_kernel.dart';
import 'package:excuse_me/domain/idea_request.dart';
import 'package:excuse_me/domain/shop_selection.dart';
import 'package:excuse_me/services/local_excuse_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v6 actions are scoped to the selected intent', () {
    expect(
      shopActionOptionsFor(ExcuseIntent.getOutOfPlans)
          .map((option) => option.action),
      containsAll(<ExcuseAction>[
        ExcuseAction.cancel,
        ExcuseAction.decline,
        ExcuseAction.leaveEarly,
      ]),
    );
    expect(
      shopActionOptionsFor(ExcuseIntent.buyTime).map((option) => option.action),
      containsAll(<ExcuseAction>[
        ExcuseAction.reschedule,
        ExcuseAction.delay,
        ExcuseAction.avoidCommitting,
      ]),
    );
    expect(
      shopActionOptionsFor(ExcuseIntent.recoverFromSituation)
          .map((option) => option.action),
      containsAll(<ExcuseAction>[
        ExcuseAction.explainLateness,
        ExcuseAction.explainAbsence,
        ExcuseAction.acknowledgeMiss,
      ]),
    );
  });

  test(
    'missed commitments skip visible timing and map to already happened',
    () {
      const intent = ShopIntentOption(
        id: 'recover',
        labelKey: 'intentAlreadyMessedUp',
        intent: ExcuseIntent.recoverFromSituation,
      );
      const action = ShopActionOption(
        id: 'acknowledge-miss',
        labelKey: 'actionAcknowledgeMiss',
        intent: ExcuseIntent.recoverFromSituation,
        action: ExcuseAction.acknowledgeMiss,
      );
      const context = ShopContextOption(
        id: 'work-study',
        labelKey: 'contextWorkStudy',
        context: ExcuseContext.workStudy,
      );
      const relationship = ShopRelationshipOption(
        id: 'formal',
        labelKey: 'relationshipFormal',
        relationship: RelationshipKind.formal,
      );
      const obligation = ShopObligationOption(
        id: 'high',
        labelKey: 'obligationHigh',
        obligation: ObligationLevel.high,
      );

      final request = requestForV6Selections(
        intent: intent,
        action: action,
        context: context,
        relationship: relationship,
        obligation: obligation,
      );

      expect(shopTimingOptionsFor(action), isEmpty);
      expect(request.timing, ExcuseTiming.alreadyHappened);
      expect(request.tone, ExcuseTone.lowKey);
      expect(request.context, ExcuseContext.workStudy);
      expect(request.relationship, RelationshipKind.formal);
      expect(request.obligation, ObligationLevel.high);
    },
  );

  test('post-result tone changes preserve the selected kernel', () {
    const kernel = ExcuseKernel(
      id: 'v6-tone-test',
      intents: {ExcuseIntent.getOutOfPlans},
      actions: {ExcuseAction.cancel},
      timings: {ExcuseTiming.today},
      relationships: {RelationshipKind.close},
      obligations: {ObligationLevel.low},
      contexts: {ExcuseContext.social},
      tones: {ExcuseTone.lowKey},
      ideaDirection:
          'Idea: Frame the capacity limit and leave the decision with them.',
      toneDirections: {
        ExcuseTone.lowKey:
            'Idea: Frame the capacity limit and leave the decision with them.',
        ExcuseTone.funny: 'Idea: Frame the capacity limit with a small, harmless theatrical flourish.',
      },
    );
    final engine = LocalExcuseEngine(
      const CuratedKernelRepository(version: 'v6-test', kernels: [kernel]),
    );
    final request = ExcuseRequest(
      intent: ExcuseIntent.getOutOfPlans,
      action: ExcuseAction.cancel,
      timing: ExcuseTiming.today,
      relationship: RelationshipKind.close,
      obligation: ObligationLevel.low,
      context: ExcuseContext.social,
    );

    final result = engine.generateSemantic(request);

    expect(result.kernelId, 'v6-tone-test');
    expect(result.ideaForTone(ExcuseTone.lowKey), contains('capacity limit'));
    expect(
      result.ideaForTone(ExcuseTone.funny),
      contains('theatrical flourish'),
    );
    expect(result.withTone(ExcuseTone.funny).kernelId, result.kernelId);
  });

  test('v6 requests use a semantic-only idea client boundary', () {
    const request = ExcuseRequest(
      intent: ExcuseIntent.buyTime,
      action: ExcuseAction.delay,
      timing: ExcuseTiming.today,
      relationship: RelationshipKind.casual,
      obligation: ObligationLevel.medium,
      context: ExcuseContext.personal,
    );

    final ideaRequest = IdeaRequest.fromV6ExcuseRequest(request);

    expect(ideaRequest.semanticFlow, isTrue);
    expect(ideaRequest.structuredRequest, same(request));
  });
}
