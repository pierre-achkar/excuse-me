import 'package:excuse_me/data/curated_kernel_repository.dart';
import 'package:excuse_me/domain/excuse_kernel.dart';
import 'package:excuse_me/services/local_excuse_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repository = CuratedKernelRepository.englishAlpha();

  test('engine selects a kernel compatible with the complete request', () {
    final engine = LocalExcuseEngine(repository);
    const request = ExcuseRequest(
      intent: ExcuseIntent.getOutOfPlans,
      action: ExcuseAction.cancel,
      timing: ExcuseTiming.lastMinute,
      relationship: RelationshipKind.close,
      obligation: ObligationLevel.expected,
      context: ExcuseContext.dinner,
      tone: ExcuseTone.nice,
    );

    final result = engine.generate(request);
    final kernel = repository.kernels.singleWhere(
      (candidate) => candidate.id == result.kernelId,
    );

    expect(kernel.intents, contains(request.intent));
    expect(kernel.actions, contains(request.action));
    expect(kernel.timings, contains(request.timing));
    expect(kernel.relationships, contains(request.relationship));
    expect(kernel.obligations, contains(request.obligation));
    expect(kernel.contexts, contains(request.context));
    expect(kernel.tones, contains(request.tone));
    expect(result.idea, kernel.ideaDirection);
  });

  test('regeneration excludes the immediately previous kernel', () {
    final engine = LocalExcuseEngine(repository);
    const request = ExcuseRequest(
      intent: ExcuseIntent.getOutOfPlans,
      action: ExcuseAction.cancel,
      timing: ExcuseTiming.today,
      relationship: RelationshipKind.familiar,
      obligation: ObligationLevel.casual,
      context: ExcuseContext.friends,
      tone: ExcuseTone.nice,
    );

    final first = engine.generate(request);
    final repeated = engine.generate(request);
    final regenerated = engine.generate(
      request,
      previousKernelId: first.kernelId,
    );

    expect(repeated.kernelId, first.kernelId);
    expect(regenerated.kernelId, isNot(first.kernelId));
  });

  test('engine returns the safe fallback when no specific kernel matches', () {
    final engine = LocalExcuseEngine(repository);
    const request = ExcuseRequest(
      intent: ExcuseIntent.recoverFromSituation,
      action: ExcuseAction.decline,
      timing: ExcuseTiming.recurring,
      relationship: RelationshipKind.authority,
      obligation: ObligationLevel.hardToReplace,
      context: ExcuseContext.work,
      tone: ExcuseTone.unhinged,
    );

    final result = engine.generate(request);

    expect(result.kernelId, 'en_honest_boundary_fallback');
    expect(result.idea, startsWith('Idea:'));
    expect(result.idea, contains('honest boundary'));
  });

  test('fallback regeneration avoids an immediate repeat', () {
    final engine = LocalExcuseEngine(repository);
    const request = ExcuseRequest(
      intent: ExcuseIntent.recoverFromSituation,
      action: ExcuseAction.decline,
      timing: ExcuseTiming.recurring,
      relationship: RelationshipKind.authority,
      obligation: ObligationLevel.hardToReplace,
      context: ExcuseContext.work,
      tone: ExcuseTone.unhinged,
    );

    final first = engine.generate(request);
    final regenerated = engine.generate(
      request,
      previousKernelId: first.kernelId,
    );

    expect(first.kernelId, startsWith('en_'));
    expect(regenerated.kernelId, isNot(first.kernelId));
  });

  test('high-risk fabrication requests use an honest fallback', () {
    final engine = LocalExcuseEngine(repository);
    const request = ExcuseRequest(
      intent: ExcuseIntent.getOutOfPlans,
      action: ExcuseAction.cancel,
      timing: ExcuseTiming.lastMinute,
      relationship: RelationshipKind.close,
      obligation: ObligationLevel.expected,
      context: ExcuseContext.family,
      tone: ExcuseTone.nice,
      risk: RequestRisk.highRiskFabrication,
    );

    final result = engine.generate(request);
    final kernel = repository.kernels.singleWhere(
      (candidate) => candidate.id == result.kernelId,
    );

    expect(kernel.isFallback, isTrue);
  });

  test('ambiguous requests use an honest fallback', () {
    final engine = LocalExcuseEngine(repository);
    const request = ExcuseRequest(
      intent: ExcuseIntent.getOutOfPlans,
      action: ExcuseAction.cancel,
      timing: ExcuseTiming.today,
      relationship: RelationshipKind.distant,
      obligation: ObligationLevel.expected,
      context: ExcuseContext.other,
      tone: ExcuseTone.nice,
      clarity: RequestClarity.ambiguous,
    );

    final result = engine.generate(request);
    final kernel = repository.kernels.singleWhere(
      (candidate) => candidate.id == result.kernelId,
    );

    expect(kernel.isFallback, isTrue);
  });

  test('each structured dimension independently affects eligibility', () {
    const targetId = 'en_exact_match';
    const independentRepository = CuratedKernelRepository(
      version: 'test',
      kernels: [
        ExcuseKernel(
          id: targetId,
          intents: {ExcuseIntent.buyTime},
          actions: {ExcuseAction.reschedule},
          timings: {ExcuseTiming.today},
          relationships: {RelationshipKind.familiar},
          obligations: {ObligationLevel.paidOrReserved},
          contexts: {ExcuseContext.dinner},
          tones: {ExcuseTone.nice},
          ideaDirection: 'Idea: Use a scheduling conflict and offer a realistic alternative.',
        ),
        ExcuseKernel(
          id: 'en_test_fallback_one',
          intents: {ExcuseIntent.buyTime},
          actions: {ExcuseAction.reschedule},
          tones: {ExcuseTone.nice},
          ideaDirection:
              'Idea: Use an honest boundary and offer a practical alternative.',
          isFallback: true,
        ),
        ExcuseKernel(
          id: 'en_test_fallback_two',
          intents: {ExcuseIntent.buyTime},
          actions: {ExcuseAction.reschedule},
          tones: {ExcuseTone.nice},
          ideaDirection: 'Idea: Acknowledge the constraint and suggest a proportionate repair.',
          isFallback: true,
        ),
      ],
    );
    final engine = LocalExcuseEngine(independentRepository);
    ExcuseRequest request({
      ExcuseIntent intent = ExcuseIntent.buyTime,
      ExcuseAction action = ExcuseAction.reschedule,
      ExcuseTiming timing = ExcuseTiming.today,
      RelationshipKind relationship = RelationshipKind.familiar,
      ObligationLevel obligation = ObligationLevel.paidOrReserved,
      ExcuseContext context = ExcuseContext.dinner,
      ExcuseTone tone = ExcuseTone.nice,
    }) => ExcuseRequest(
      intent: intent,
      action: action,
      timing: timing,
      relationship: relationship,
      obligation: obligation,
      context: context,
      tone: tone,
    );

    expect(engine.generate(request()).kernelId, targetId);
    final mismatches = [
      request(intent: ExcuseIntent.getOutOfPlans),
      request(action: ExcuseAction.cancel),
      request(timing: ExcuseTiming.plannedAhead),
      request(relationship: RelationshipKind.close),
      request(obligation: ObligationLevel.casual),
      request(context: ExcuseContext.family),
      request(tone: ExcuseTone.lowKey),
    ];
    for (final mismatch in mismatches) {
      expect(engine.generate(mismatch).kernelId, isNot(targetId));
    }
  });

  test('engine rejects a generic matching kernel', () {
    const genericRepository = CuratedKernelRepository(
      version: 'test',
      kernels: [
        ExcuseKernel(
          id: 'en_generic',
          intents: {ExcuseIntent.getOutOfPlans},
          actions: {ExcuseAction.cancel},
          tones: {ExcuseTone.nice},
          ideaDirection: 'Idea: Say something vague about the impact.',
        ),
      ],
    );
    final engine = LocalExcuseEngine(genericRepository);
    const request = ExcuseRequest(
      intent: ExcuseIntent.getOutOfPlans,
      action: ExcuseAction.cancel,
      timing: ExcuseTiming.today,
      relationship: RelationshipKind.close,
      obligation: ObligationLevel.expected,
      context: ExcuseContext.dinner,
      tone: ExcuseTone.nice,
    );

    expect(() => engine.generate(request), throwsStateError);
  });

  test('engine rejects an unsafe matching kernel', () {
    const unsafeRepository = CuratedKernelRepository(
      version: 'test',
      kernels: [
        ExcuseKernel(
          id: 'en_unsafe_test',
          intents: {ExcuseIntent.getOutOfPlans},
          actions: {ExcuseAction.cancel},
          tones: {ExcuseTone.nice},
          ideaDirection: 'Hi Sam, I am sick, so I cannot come tonight. Thanks!',
        ),
      ],
    );
    const request = ExcuseRequest(
      intent: ExcuseIntent.getOutOfPlans,
      action: ExcuseAction.cancel,
      timing: ExcuseTiming.today,
      relationship: RelationshipKind.close,
      obligation: ObligationLevel.casual,
      context: ExcuseContext.dinner,
      tone: ExcuseTone.nice,
    );

    expect(
      () => const LocalExcuseEngine(unsafeRepository).generate(request),
      throwsStateError,
    );
  });
}
