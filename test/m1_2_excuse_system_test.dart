import 'package:excuse_me/app.dart';
import 'package:flutter/material.dart';
import 'package:excuse_me/data/curated_kernel_repository.dart';
import 'package:excuse_me/domain/excuse_kernel.dart';
import 'package:excuse_me/domain/idea_request.dart';
import 'package:excuse_me/services/idea_client.dart';
import 'package:excuse_me/services/idea_safety_policy.dart';
import 'package:excuse_me/services/local_excuse_engine.dart';
import 'package:flutter_test/flutter_test.dart';

class _CapturingIdeaClient implements IdeaClient {
  IdeaRequest? request;

  @override
  Future<String> generate(IdeaRequest request) async {
    this.request = request;
    return 'Placeholder: content pending.';
  }
}

void main() {
  test('M1.2 repository covers every defined excuse family', () {
    final families = CuratedKernelRepository.englishAlpha().kernels
        .map((kernel) => kernel.family)
        .toSet();

    expect(families, containsAll(ExcuseFamily.values));
    expect(ExcuseFamily.values, hasLength(7));
  });

  test('family on a request filters compatible kernels', () {
    const capacityId = 'capacity';
    const boundaryId = 'boundary';
    const request = ExcuseRequest(
      intent: ExcuseIntent.getOutOfPlans,
      action: ExcuseAction.cancel,
      timing: ExcuseTiming.today,
      relationship: RelationshipKind.close,
      obligation: ObligationLevel.casual,
      context: ExcuseContext.dinner,
      tone: ExcuseTone.nice,
      family: ExcuseFamily.boundaryPreference,
    );
    final repository = CuratedKernelRepository(
      version: 'test',
      kernels: [
        const ExcuseKernel(
          id: capacityId,
          family: ExcuseFamily.capacityWellbeing,
          intents: {ExcuseIntent.getOutOfPlans},
          actions: {ExcuseAction.cancel},
          tones: {ExcuseTone.nice},
          ideaDirection: 'Placeholder: capacity content pending.',
          isPlaceholder: true,
        ),
        const ExcuseKernel(
          id: boundaryId,
          family: ExcuseFamily.boundaryPreference,
          intents: {ExcuseIntent.getOutOfPlans},
          actions: {ExcuseAction.cancel},
          tones: {ExcuseTone.nice},
          ideaDirection: 'Placeholder: boundary content pending.',
          isPlaceholder: true,
        ),
      ],
    );

    final result = LocalExcuseEngine(repository).generate(request);

    expect(result.kernelId, boundaryId);
    expect(result.family, ExcuseFamily.boundaryPreference);
  });

  test('audience, channel, and repair preference affect compatibility', () {
    const request = ExcuseRequest(
      intent: ExcuseIntent.buyTime,
      action: ExcuseAction.reschedule,
      timing: ExcuseTiming.today,
      relationship: RelationshipKind.professional,
      obligation: ObligationLevel.expected,
      context: ExcuseContext.work,
      tone: ExcuseTone.nice,
      audienceSize: AudienceSize.group,
      channel: ExcuseChannel.call,
      repairPreference: RepairOption.alternativePlan,
    );
    final repository = CuratedKernelRepository(
      version: 'test',
      kernels: [
        const ExcuseKernel(
          id: 'wrong-metadata',
          family: ExcuseFamily.workStudy,
          intents: {ExcuseIntent.buyTime},
          actions: {ExcuseAction.reschedule},
          tones: {ExcuseTone.nice},
          ideaDirection: 'Placeholder: wrong metadata.',
          isPlaceholder: true,
        ),
        const ExcuseKernel(
          id: 'matching-metadata',
          family: ExcuseFamily.workStudy,
          intents: {ExcuseIntent.buyTime},
          actions: {ExcuseAction.reschedule},
          timings: {ExcuseTiming.today},
          relationships: {RelationshipKind.professional},
          obligations: {ObligationLevel.expected},
          contexts: {ExcuseContext.work},
          audienceSizes: {AudienceSize.group},
          channels: {ExcuseChannel.call},
          tones: {ExcuseTone.nice},
          repairOptions: {RepairOption.alternativePlan},
          ideaDirection: 'Placeholder: matching metadata.',
          isPlaceholder: true,
        ),
      ],
    );

    final result = LocalExcuseEngine(repository).generate(request);

    expect(result.kernelId, 'matching-metadata');
  });

  test('curated kernels expose approved directions and explicit fallback placeholders', () {
    final kernels = CuratedKernelRepository.englishAlpha().kernels;
    final specificKernels = kernels.where((kernel) => !kernel.isFallback);
    final fallbackKernels = kernels.where((kernel) => kernel.isFallback);

    expect(specificKernels, isNotEmpty);
    expect(
      specificKernels,
      everyElement(
        predicate<ExcuseKernel>((kernel) {
          return !kernel.isPlaceholder &&
              !kernel.ideaDirection.startsWith('Placeholder:');
        }),
      ),
    );
    expect(
      fallbackKernels,
      everyElement(
        predicate<ExcuseKernel>((kernel) {
          return kernel.isPlaceholder &&
              kernel.ideaDirection.startsWith('Placeholder:');
        }),
      ),
    );
  });

  test('engine returns a family-aware placeholder result', () {
    const request = ExcuseRequest(
      intent: ExcuseIntent.getOutOfPlans,
      action: ExcuseAction.cancel,
      timing: ExcuseTiming.lastMinute,
      relationship: RelationshipKind.close,
      obligation: ObligationLevel.expected,
      context: ExcuseContext.dinner,
      tone: ExcuseTone.nice,
      family: ExcuseFamily.capacityWellbeing,
    );

    final result = LocalExcuseEngine(CuratedKernelRepository.englishAlpha())
        .generate(request);

    expect(result.family, ExcuseFamily.capacityWellbeing);
    expect(result.isPlaceholder, isFalse);
    expect(result.idea, startsWith('Idea:'));
  });

  test('placeholder format does not bypass prohibited-claim checks', () {
    expect(
      IdeaSafetyPolicy.isSafeIdea(
        'Placeholder: use a fake diagnosis as the reason.',
      ),
      isFalse,
    );
  });

  testWidgets('shop sends the typed v6 request to the idea client', (
    tester,
  ) async {
    final client = _CapturingIdeaClient();
    await tester.pumpWidget(
      ExcuseMeApp(client: client, disableAnimations: true),
    );

    Future<void> choose(String key) async {
      final option = find.byKey(ValueKey(key));
      await tester.ensureVisible(option);
      await tester.tap(option);
      await tester.pump();
    }

    for (final key in [
      'v6-entry-cta',
      'v6-intent-getOutOfPlans',
      'v6-action-cancel',
      'v6-context-social',
      'v6-timing-today',
      'v6-relationship-casual',
      'v6-obligation-medium',
    ]) {
      await choose(key);
    }
    await tester.pumpAndSettle();

    final request = client.request!.structuredRequest!;
    expect(request.intent, ExcuseIntent.getOutOfPlans);
    expect(request.action, ExcuseAction.cancel);
    expect(request.timing, ExcuseTiming.today);
    expect(request.relationship, RelationshipKind.casual);
    expect(request.obligation, ObligationLevel.medium);
    expect(request.context, ExcuseContext.social);
    expect(request.tone, ExcuseTone.lowKey);
    expect(request.family, isNull);
    expect(client.request!.semanticFlow, isTrue);
  });
}
