enum ExcuseIntent { getOutOfPlans, buyTime, recoverFromSituation }

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
    risk.name,
    clarity.name,
  ].join('|');
}
