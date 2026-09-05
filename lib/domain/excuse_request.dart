enum ExcuseIntent { getOutOfPlans, buyTime, recoverFromSituation }

enum ExcuseFamily {
  capacityWellbeing,
  careFamily,
  workStudy,
  moneyLogistics,
  planningFailure,
  boundaryPreference,
  absurdDramatic,
}

enum ExcuseAction {
  cancel,
  decline,
  leaveEarly,
  backOut,
  reschedule,
  delay,
  avoidCommitting,
  explainLateness,
  explainAbsence,
  acknowledgeMiss,
  suggestAlternative,
}

enum ExcuseTiming {
  plannedAhead,
  today,
  lastMinute,
  happeningNow,
  alreadyLate,
  alreadyMissed,
  alreadyHappened,
  recurring,
}

enum RelationshipKind {
  close,
  familiar,
  casual,
  distant,
  formal,
  professional,
  authority,
}

enum ObligationLevel {
  low,
  medium,
  high,
  casual,
  expected,
  important,
  paidOrReserved,
  hardToReplace,
}

enum ExcuseContext {
  social,
  personal,
  workStudy,
  practical,
  celebration,
  party,
  dinner,
  date,
  family,
  work,
  friends,
  hobby,
  travel,
  other,
}

enum ExcuseTone { lowKey, nice, funny, dramatic, unhinged }

enum AudienceSize { individual, group }

enum ExcuseChannel { text, voiceNote, call, inPerson }

enum RepairOption {
  none,
  briefApology,
  offerAnotherTime,
  alternativePlan,
  acknowledgeInconvenience,
}

enum RequestRisk { none, highRiskFabrication }

enum RequestClarity { structured, ambiguous }

class ExcuseRequest {
  const ExcuseRequest({
    required this.intent,
    required this.action,
    required this.timing,
    required this.relationship,
    required this.obligation,
    required this.context,
    this.tone = ExcuseTone.lowKey,
    this.family,
    this.audienceSize = AudienceSize.individual,
    this.channel = ExcuseChannel.text,
    this.repairPreference = RepairOption.none,
    this.risk = RequestRisk.none,
    this.clarity = RequestClarity.structured,
  });

  final ExcuseIntent intent;
  final ExcuseAction action;
  final ExcuseTiming timing;
  final RelationshipKind relationship;
  final ObligationLevel obligation;
  final ExcuseContext context;
  final ExcuseTone tone;
  final ExcuseFamily? family;
  final AudienceSize audienceSize;
  final ExcuseChannel channel;
  final RepairOption repairPreference;
  final RequestRisk risk;
  final RequestClarity clarity;

  /// The v6 request key intentionally excludes tone because tone is selected
  /// after the kernel/card has been chosen.
  String get semanticSelectionKey => [
    intent.name,
    action.name,
    timing.name,
    relationship.name,
    obligation.name,
    context.name,
    if (family != null) family!.name,
    if (audienceSize != AudienceSize.individual) audienceSize.name,
    if (channel != ExcuseChannel.text) channel.name,
    if (repairPreference != RepairOption.none) repairPreference.name,
    risk.name,
    clarity.name,
  ].join('|');

  /// Legacy key retained for the original client and deterministic fixtures.
  String get selectionKey => [semanticSelectionKey, tone.name].join('|');
}
