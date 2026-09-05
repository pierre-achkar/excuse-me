import 'package:excuse_me/domain/excuse_kernel.dart';
import 'package:excuse_me/data/curated_kernel_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('curated repository is versioned and uses unique stable kernel IDs', () {
    final repository = CuratedKernelRepository.englishAlpha();

    expect(repository.version, '1.1.0');
    expect(repository.kernels.length, greaterThanOrEqualTo(12));
    expect(
      repository.kernels.map((kernel) => kernel.id).toSet().length,
      repository.kernels.length,
    );
    expect(
      repository.kernels.every((kernel) => kernel.id.startsWith('en_')),
      isTrue,
    );
  });

  test('curated repository covers the supported product taxonomy', () {
    final kernels = CuratedKernelRepository.englishAlpha().kernels;

    expect(
      kernels.expand((kernel) => kernel.intents).toSet(),
      containsAll(ExcuseIntent.values),
    );
    expect(
      kernels.expand((kernel) => kernel.actions).toSet(),
      containsAll(ExcuseAction.values),
    );
    expect(
      kernels.expand((kernel) => kernel.tones).toSet(),
      containsAll(ExcuseTone.values),
    );
    expect(kernels.every((kernel) => kernel.isPlaceholder), isTrue);
    expect(
      kernels.every(
        (kernel) => kernel.ideaDirection.startsWith('Placeholder:'),
      ),
      isTrue,
    );
  });

  test('every specific kernel narrows compatibility metadata', () {
    final kernels = CuratedKernelRepository.englishAlpha().kernels.where(
      (kernel) => !kernel.isFallback,
    );

    expect(
      kernels.every(
        (kernel) =>
            kernel.timings.length < ExcuseTiming.values.length ||
            kernel.relationships.length < RelationshipKind.values.length ||
            kernel.obligations.length < ObligationLevel.values.length ||
            kernel.contexts.length < ExcuseContext.values.length,
      ),
      isTrue,
    );
  });

  test('budget kernel requires budget-relevant context and stakes', () {
    final kernel = CuratedKernelRepository.englishAlpha().kernels.singleWhere(
      (candidate) => candidate.id == 'en_budget_boundary',
    );

    expect(
      kernel.supports(
        const ExcuseRequest(
          intent: ExcuseIntent.getOutOfPlans,
          action: ExcuseAction.cancel,
          timing: ExcuseTiming.lastMinute,
          relationship: RelationshipKind.close,
          obligation: ObligationLevel.expected,
          context: ExcuseContext.family,
          tone: ExcuseTone.nice,
        ),
      ),
      isFalse,
    );
    expect(
      kernel.supports(
        const ExcuseRequest(
          intent: ExcuseIntent.getOutOfPlans,
          action: ExcuseAction.cancel,
          timing: ExcuseTiming.today,
          relationship: RelationshipKind.familiar,
          obligation: ObligationLevel.paidOrReserved,
          context: ExcuseContext.dinner,
          tone: ExcuseTone.nice,
        ),
      ),
      isTrue,
    );
  });

  test('every specific kernel carries the approved construction metadata', () {
    final kernels = CuratedKernelRepository.englishAlpha().kernels.where(
      (kernel) => !kernel.isFallback,
    );

    for (final kernel in kernels) {
      expect(kernel.playfulName.trim(), isNotEmpty, reason: kernel.id);
      expect(kernel.audienceSizes, isNotEmpty, reason: kernel.id);
      expect(kernel.linguisticFeatures, isNotEmpty, reason: kernel.id);
      expect(kernel.repairOptions, isNotEmpty, reason: kernel.id);
      expect(kernel.prohibitedRiskFlags, isNotEmpty, reason: kernel.id);
    }
  });
}
