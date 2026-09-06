import 'package:flutter_test/flutter_test.dart';
import 'package:excuse_me/data/curated_kernel_repository.dart';
import 'package:excuse_me/domain/excuse_kernel.dart';
import 'package:excuse_me/domain/user_profile.dart';
import 'package:excuse_me/services/local_excuse_engine.dart';

const _baseRequest = ExcuseRequest(
  intent: ExcuseIntent.getOutOfPlans,
  action: ExcuseAction.cancel,
  timing: ExcuseTiming.today,
  relationship: RelationshipKind.familiar,
  obligation: ObligationLevel.expected,
  context: ExcuseContext.workStudy,
);

ExcuseKernel _kernel({required String id, required CauseType cause}) {
  return ExcuseKernel(
    id: id,
    playfulName: id,
    family: cause == CauseType.workStudy
        ? ExcuseFamily.workStudy
        : ExcuseFamily.careFamily,
    causeType: cause,
    intents: const {ExcuseIntent.getOutOfPlans},
    actions: const {ExcuseAction.cancel},
    timings: const {ExcuseTiming.today},
    relationships: const {RelationshipKind.familiar},
    obligations: const {ObligationLevel.expected},
    contexts: const {ExcuseContext.workStudy},
    tones: const {ExcuseTone.lowKey},
    ideaDirection:
        'Idea: Use the confirmed responsibility as a bounded direction.',
  );
}

ExcuseKernel _fallbackKernel() {
  return const ExcuseKernel(
    id: 'fallback',
    isPlaceholder: true,
    isFallback: true,
    intents: {
      ExcuseIntent.getOutOfPlans,
      ExcuseIntent.buyTime,
      ExcuseIntent.recoverFromSituation,
    },
    actions: {
      ExcuseAction.cancel,
      ExcuseAction.decline,
      ExcuseAction.explainAbsence,
    },
    tones: {ExcuseTone.lowKey},
    ideaDirection: 'Placeholder: Use an honest boundary.',
  );
}

void main() {
  test(
    'working profile ranks a compatible work idea ahead of a generic care idea',
    () {
      final engine = LocalExcuseEngine(
        CuratedKernelRepository(
          version: 'test',
          kernels: [
            _kernel(id: 'generic', cause: CauseType.capacity),
            _kernel(id: 'work', cause: CauseType.workStudy),
            _fallbackKernel(),
          ],
        ),
      );

      final result = engine.generateSemantic(
        _baseRequest.copyWith(
          profile: const UserProfile(
            workStudyStatus: ProfileWorkStudyStatus.working,
          ),
        ),
      );

      expect(result.kernelId, 'work');
    },
  );

  test('having children alone does not unlock a care-related idea', () {
    final engine = LocalExcuseEngine(
      CuratedKernelRepository(
        version: 'test',
        kernels: [
          _kernel(id: 'care', cause: CauseType.householdCare),
          _fallbackKernel(),
        ],
      ),
    );

    final result = engine.generateSemantic(
      _baseRequest.copyWith(
        profile: const UserProfile(hasChildren: ProfileYesNo.yes),
      ),
    );

    expect(result.isPlaceholder, isTrue);
  });

  test('confirmed non-care responsibility does not unlock care ideas', () {
    final engine = LocalExcuseEngine(
      CuratedKernelRepository(
        version: 'test',
        kernels: [
          _kernel(id: 'care', cause: CauseType.householdCare),
          _fallbackKernel(),
        ],
      ),
    );

    final result = engine.generateSemantic(
      _baseRequest.copyWith(
        currentVisitContext: const CurrentVisitContext(
          responsibility: CurrentVisitResponsibility.existingCommitment,
        ),
      ),
    );

    expect(result.isPlaceholder, isTrue);
  });

  test('confirmed childcare context can unlock a care-related idea', () {
    final engine = LocalExcuseEngine(
      CuratedKernelRepository(
        version: 'test',
        kernels: [_kernel(id: 'care', cause: CauseType.householdCare)],
      ),
    );

    final result = engine.generateSemantic(
      _baseRequest.copyWith(
        profile: const UserProfile(hasChildren: ProfileYesNo.yes),
        currentVisitContext: const CurrentVisitContext(
          responsibility: CurrentVisitResponsibility.childcare,
        ),
      ),
    );

    expect(result.kernelId, 'care');
    expect(result.isPlaceholder, isFalse);
  });
}

extension on ExcuseRequest {
  ExcuseRequest copyWith({
    UserProfile? profile,
    CurrentVisitContext? currentVisitContext,
  }) {
    return ExcuseRequest(
      intent: intent,
      action: action,
      timing: timing,
      relationship: relationship,
      obligation: obligation,
      context: context,
      tone: tone,
      family: family,
      audienceSize: audienceSize,
      channel: channel,
      repairPreference: repairPreference,
      risk: risk,
      clarity: clarity,
      profile: profile ?? this.profile,
      currentVisitContext: currentVisitContext ?? this.currentVisitContext,
    );
  }
}
