export 'excuse_request.dart';

import 'excuse_request.dart';

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

enum RiskFlag {
  medicalClaim,
  familyEmergency,
  legalClaim,
  financialClaim,
  identityClaim,
}

const allAudienceSizes = {AudienceSize.individual, AudienceSize.group};
const allExcuseChannels = {
  ExcuseChannel.text,
  ExcuseChannel.voiceNote,
  ExcuseChannel.call,
  ExcuseChannel.inPerson,
};
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
    this.isPlaceholder = false,
    this.isFallback = false,
    this.timings = allExcuseTimings,
    this.relationships = allRelationshipKinds,
    this.obligations = allObligationLevels,
    this.contexts = allExcuseContexts,
    this.audienceSizes = allAudienceSizes,
    this.channels = allExcuseChannels,
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
  final Set<ExcuseChannel> channels;
  final Set<ExcuseTone> tones;
  final Set<LinguisticFeature> linguisticFeatures;
  final Set<RepairOption> repairOptions;
  final Set<RiskFlag> prohibitedRiskFlags;
  final String ideaDirection;
  final bool isPlaceholder;
  final bool isFallback;

  bool supports(ExcuseRequest request) {
    return intents.contains(request.intent) &&
        actions.contains(request.action) &&
        (request.family == null || family == request.family) &&
        timings.contains(request.timing) &&
        relationships.contains(request.relationship) &&
        obligations.contains(request.obligation) &&
        contexts.contains(request.context) &&
        audienceSizes.contains(request.audienceSize) &&
        channels.contains(request.channel) &&
        (request.repairPreference == RepairOption.none ||
            repairOptions.contains(request.repairPreference)) &&
        tones.contains(request.tone);
  }
}
