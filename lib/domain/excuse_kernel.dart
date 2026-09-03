export 'excuse_request.dart';

import 'excuse_request.dart';

enum ExcuseFamily {
  capacityWellbeing,
  careFamily,
  workStudy,
  moneyLogistics,
  planningFailure,
  boundaryPreference,
  absurdDramatic,
}

enum AudienceSize { individual, group }

enum CauseType {
  capacity,
  priorCommitment,
  schedulingConflict,
  logistics,
  budget,
  workStudy,
  householdCare,
  planningFailure,
  preference,
}

enum ResponsibilityStrategy {
  limitedControl,
  honestBoundary,
  acknowledgeMistake,
  repair,
}

enum LinguisticFeature {
  minimalDetail,
  acknowledgement,
  alternative,
  playfulExaggeration,
}

enum RepairOption {
  briefApology,
  offerAnotherTime,
  alternativePlan,
  acknowledgeInconvenience,
}

enum RiskFlag {
  medicalClaim,
  familyEmergency,
  legalClaim,
  financialClaim,
  identityClaim,
}

const allAudienceSizes = {AudienceSize.individual, AudienceSize.group};
const defaultLinguisticFeatures = {LinguisticFeature.minimalDetail};
const defaultRepairOptions = {RepairOption.briefApology};
const allProhibitedRiskFlags = {
  RiskFlag.medicalClaim,
  RiskFlag.familyEmergency,
  RiskFlag.legalClaim,
  RiskFlag.financialClaim,
  RiskFlag.identityClaim,
};

const allExcuseTimings = {
  ExcuseTiming.plannedAhead,
  ExcuseTiming.today,
  ExcuseTiming.lastMinute,
  ExcuseTiming.alreadyLate,
  ExcuseTiming.alreadyMissed,
  ExcuseTiming.recurring,
};
const allRelationshipKinds = {
  RelationshipKind.close,
  RelationshipKind.familiar,
  RelationshipKind.distant,
  RelationshipKind.professional,
  RelationshipKind.authority,
};
const allObligationLevels = {
  ObligationLevel.casual,
  ObligationLevel.expected,
  ObligationLevel.important,
  ObligationLevel.paidOrReserved,
  ObligationLevel.hardToReplace,
};
const allExcuseContexts = {
  ExcuseContext.celebration,
  ExcuseContext.party,
  ExcuseContext.dinner,
  ExcuseContext.date,
  ExcuseContext.family,
  ExcuseContext.work,
  ExcuseContext.friends,
  ExcuseContext.hobby,
  ExcuseContext.travel,
  ExcuseContext.other,
};

class ExcuseKernel {
  const ExcuseKernel({
    required this.id,
    this.playfulName = 'Untitled idea',
    this.family = ExcuseFamily.boundaryPreference,
    this.causeType = CauseType.preference,
    this.responsibilityStrategy = ResponsibilityStrategy.honestBoundary,
    required this.intents,
    required this.actions,
    required this.tones,
    required this.ideaDirection,
    this.isFallback = false,
    this.timings = allExcuseTimings,
    this.relationships = allRelationshipKinds,
    this.obligations = allObligationLevels,
    this.contexts = allExcuseContexts,
    this.audienceSizes = allAudienceSizes,
    this.linguisticFeatures = defaultLinguisticFeatures,
    this.repairOptions = defaultRepairOptions,
    this.prohibitedRiskFlags = allProhibitedRiskFlags,
  });

  final String id;
  final String playfulName;
  final ExcuseFamily family;
  final CauseType causeType;
  final ResponsibilityStrategy responsibilityStrategy;
  final Set<ExcuseIntent> intents;
  final Set<ExcuseAction> actions;
  final Set<ExcuseTiming> timings;
  final Set<RelationshipKind> relationships;
  final Set<ObligationLevel> obligations;
  final Set<ExcuseContext> contexts;
  final Set<AudienceSize> audienceSizes;
  final Set<ExcuseTone> tones;
  final Set<LinguisticFeature> linguisticFeatures;
  final Set<RepairOption> repairOptions;
  final Set<RiskFlag> prohibitedRiskFlags;
  final String ideaDirection;
  final bool isFallback;

  bool supports(ExcuseRequest request) {
    return intents.contains(request.intent) &&
        actions.contains(request.action) &&
        timings.contains(request.timing) &&
        relationships.contains(request.relationship) &&
        obligations.contains(request.obligation) &&
        contexts.contains(request.context) &&
        tones.contains(request.tone);
  }
}
