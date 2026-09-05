import 'package:excuse_me/data/curated_kernel_repository.dart';
import 'package:excuse_me/domain/excuse_kernel.dart';
import 'package:excuse_me/services/idea_safety_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('approved v6 family directions are present and non-placeholder', () {
    final kernels = CuratedKernelRepository.englishAlpha().kernels;
    final expected = <ExcuseFamily, String>{
      ExcuseFamily.capacityWellbeing:
          'You do not have the bandwidth for it today.',
      ExcuseFamily.careFamily: 'Something personal needs your attention.',
      ExcuseFamily.workStudy:
          'Work has spilled into the time you thought you had.',
      ExcuseFamily.moneyLogistics: 'The logistics no longer work for you.',
      ExcuseFamily.planningFailure:
          'You misjudged the timing and cannot make it work.',
      ExcuseFamily.boundaryPreference: 'You need to pass this time.',
      ExcuseFamily.absurdDramatic: 'Your energy has mysteriously disappeared.',
    };

    for (final entry in expected.entries) {
      final kernel = kernels.firstWhere(
        (candidate) => candidate.family == entry.key,
      );
      expect(kernel.ideaDirection, 'Idea: ${entry.value}');
      expect(kernel.isPlaceholder, isFalse);
      expect(kernel.toneDirections[ExcuseTone.lowKey], 'Idea: ${entry.value}');
    }
  });

  test('every approved v6 direction has a safe warm and playful variant', () {
    final specific = CuratedKernelRepository.englishAlpha().kernels.where(
      (kernel) => !kernel.isFallback,
    );

    expect(specific, isNotEmpty);
    for (final kernel in specific) {
      expect(kernel.isPlaceholder, isFalse);
      expect(kernel.toneDirections[ExcuseTone.lowKey], isNotNull);
      expect(kernel.toneDirections[ExcuseTone.nice], isNotNull);
      expect(kernel.toneDirections[ExcuseTone.funny], isNotNull);
    }
  });

  test('every approved v6 direction passes safety checks', () {
    final kernels = CuratedKernelRepository.englishAlpha().kernels.where(
      (kernel) => !kernel.isFallback,
    );

    for (final kernel in kernels) {
      expect(
        IdeaSafetyPolicy.isSafeIdea(kernel.ideaDirection),
        isTrue,
        reason: kernel.id,
      );
      for (final direction in kernel.toneDirections.values) {
        expect(
          IdeaSafetyPolicy.isSafeIdea(direction),
          isTrue,
          reason: kernel.id,
        );
      }
    }
  });
}
