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
  suggestAlternative,
}

enum ExcuseTiming {
  plannedAhead,
  today,
  lastMinute,
  alreadyLate,
  alreadyMissed,
  recurring,
}

enum RelationshipKind { close, familiar, distant, professional, authority }

enum ObligationLevel {
  casual,
  expected,
  important,
  paidOrReserved,
  hardToReplace,
}

enum ExcuseContext {
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
    required this.tone,
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

  String get selectionKey => [
    intent.name,
    action.name,
    timing.name,
    relationship.name,
    obligation.name,
    context.name,
    tone.name,
    if (family != null) family!.name,
    if (audienceSize != AudienceSize.individual) audienceSize.name,
    if (channel != ExcuseChannel.text) channel.name,
    if (repairPreference != RepairOption.none) repairPreference.name,
    risk.name,
    clarity.name,
  ].join('|');
}
