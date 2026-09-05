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
  ExcuseTiming.happeningNow,
  ExcuseTiming.alreadyLate,
  ExcuseTiming.alreadyMissed,
  ExcuseTiming.alreadyHappened,
  ExcuseTiming.recurring,
};
const allRelationshipKinds = {
  RelationshipKind.close,
  RelationshipKind.familiar,
  RelationshipKind.casual,
  RelationshipKind.distant,
  RelationshipKind.formal,
  RelationshipKind.professional,
  RelationshipKind.authority,
};
const allObligationLevels = {
  ObligationLevel.low,
  ObligationLevel.medium,
  ObligationLevel.high,
  ObligationLevel.casual,
  ObligationLevel.expected,
  ObligationLevel.important,
  ObligationLevel.paidOrReserved,
  ObligationLevel.hardToReplace,
};
const allExcuseContexts = {
  ExcuseContext.social,
  ExcuseContext.personal,
  ExcuseContext.workStudy,
  ExcuseContext.practical,
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
    this.toneDirections = const {},
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
  final Map<ExcuseTone, String> toneDirections;
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

  /// v6 lookup ignores presentation tone and accepts the broader six-beat
  /// taxonomy while remaining compatible with the alpha kernel catalogue.
  bool supportsSemantic(ExcuseRequest request) {
    return intents.contains(request.intent) &&
        _supportsAction(request.action) &&
        (request.family == null || family == request.family) &&
        _supportsTiming(request.timing) &&
        _supportsRelationship(request.relationship) &&
        _supportsObligation(request.obligation) &&
        _supportsContext(request.context) &&
        audienceSizes.contains(request.audienceSize) &&
        channels.contains(request.channel) &&
        (request.repairPreference == RepairOption.none ||
            repairOptions.contains(request.repairPreference));
  }

  bool _supportsAction(ExcuseAction action) {
    if (actions.contains(action)) return true;
    return action == ExcuseAction.acknowledgeMiss &&
        (actions.contains(ExcuseAction.explainAbsence) ||
            actions.contains(ExcuseAction.explainLateness));
  }

  bool _supportsTiming(ExcuseTiming timing) {
    if (timings.contains(timing)) return true;
    return switch (timing) {
      ExcuseTiming.happeningNow =>
        timings.contains(ExcuseTiming.lastMinute) ||
            timings.contains(ExcuseTiming.today),
      ExcuseTiming.alreadyHappened =>
        timings.contains(ExcuseTiming.alreadyMissed) ||
            timings.contains(ExcuseTiming.alreadyLate),
      _ => false,
    };
  }

  bool _supportsRelationship(RelationshipKind relationship) {
    if (relationships.contains(relationship)) return true;
    return switch (relationship) {
      RelationshipKind.casual =>
        relationships.contains(RelationshipKind.familiar) ||
            relationships.contains(RelationshipKind.distant),
      RelationshipKind.formal =>
        relationships.contains(RelationshipKind.professional) ||
            relationships.contains(RelationshipKind.authority),
      _ => false,
    };
  }

  bool _supportsObligation(ObligationLevel obligation) {
    if (obligations.contains(obligation)) return true;
    return switch (obligation) {
      ObligationLevel.low => obligations.contains(ObligationLevel.casual),
      ObligationLevel.medium =>
        obligations.contains(ObligationLevel.expected) ||
            obligations.contains(ObligationLevel.important),
      ObligationLevel.high =>
        obligations.contains(ObligationLevel.important) ||
            obligations.contains(ObligationLevel.paidOrReserved) ||
            obligations.contains(ObligationLevel.hardToReplace),
      _ => false,
    };
  }

  bool _supportsContext(ExcuseContext context) {
    if (contexts.contains(context)) return true;
    final aliases = switch (context) {
      ExcuseContext.social => {
        ExcuseContext.celebration,
        ExcuseContext.party,
        ExcuseContext.dinner,
        ExcuseContext.date,
        ExcuseContext.friends,
      },
      ExcuseContext.personal => {
        ExcuseContext.family,
        ExcuseContext.dinner,
        ExcuseContext.date,
        ExcuseContext.hobby,
      },
      ExcuseContext.workStudy => {ExcuseContext.work, ExcuseContext.hobby},
      ExcuseContext.practical => {ExcuseContext.travel, ExcuseContext.other},
      _ => <ExcuseContext>{},
    };
    return contexts.any(aliases.contains);
  }
}
