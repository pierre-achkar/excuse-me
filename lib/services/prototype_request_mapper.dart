import '../domain/excuse_request.dart';

class PrototypeRequestMapper {
  const PrototypeRequestMapper();

  ExcuseRequest map({
    required String situation,
    required String relationship,
    required String urgency,
    required String tone,
  }) {
    final normalized = situation.toLowerCase();
    final action = _action(normalized);
    final context = _context(normalized);
    return ExcuseRequest(
      intent: _intent(action),
      action: action,
      timing: switch (urgency.toLowerCase()) {
        'soon' => ExcuseTiming.lastMinute,
        'today' => ExcuseTiming.today,
        _ => ExcuseTiming.plannedAhead,
      },
      relationship: switch (relationship.toLowerCase()) {
        'friend' || 'family' => RelationshipKind.close,
        'coworker' => RelationshipKind.professional,
        'client' => RelationshipKind.authority,
        _ => RelationshipKind.familiar,
      },
      obligation:
          normalized.contains('reservation') || normalized.contains('paid')
          ? ObligationLevel.paidOrReserved
          : normalized.contains('important')
          ? ObligationLevel.important
          : ObligationLevel.expected,
      context: context,
      tone: switch (tone.toLowerCase()) {
        'warm' => ExcuseTone.nice,
        'professional' || 'direct' => ExcuseTone.lowKey,
        'funny' => ExcuseTone.funny,
        'dramatic' => ExcuseTone.dramatic,
        'unhinged' => ExcuseTone.unhinged,
        _ => ExcuseTone.lowKey,
      },
      risk: _risk(normalized),
      clarity: _clarity(normalized, context),
    );
  }

  ExcuseAction _action(String situation) {
    if (situation.contains('late')) return ExcuseAction.explainLateness;
    if (situation.contains('missed') || situation.contains('miss ')) {
      return ExcuseAction.explainAbsence;
    }
    if (situation.contains('reschedul')) return ExcuseAction.reschedule;
    if (situation.contains('leave early')) return ExcuseAction.leaveEarly;
    if (situation.contains('decline') || situation.contains('say no')) {
      return ExcuseAction.decline;
    }
    if (situation.contains('delay') || situation.contains('more time')) {
      return ExcuseAction.delay;
    }
    return ExcuseAction.cancel;
  }

  ExcuseIntent _intent(ExcuseAction action) {
    return switch (action) {
      ExcuseAction.reschedule ||
      ExcuseAction.delay ||
      ExcuseAction.avoidCommitting ||
      ExcuseAction.suggestAlternative => ExcuseIntent.buyTime,
      ExcuseAction.explainLateness ||
      ExcuseAction.explainAbsence => ExcuseIntent.recoverFromSituation,
      _ => ExcuseIntent.getOutOfPlans,
    };
  }

  ExcuseContext _context(String situation) {
    if (situation.contains('dinner')) return ExcuseContext.dinner;
    if (situation.contains('party')) return ExcuseContext.party;
    if (situation.contains('date')) return ExcuseContext.date;
    if (situation.contains('family')) return ExcuseContext.family;
    if (situation.contains('work') || situation.contains('meeting')) {
      return ExcuseContext.work;
    }
    if (situation.contains('friend')) return ExcuseContext.friends;
    if (situation.contains('travel') || situation.contains('flight')) {
      return ExcuseContext.travel;
    }
    return ExcuseContext.other;
  }

  static final RegExp _highRiskClaim = RegExp(
    r'(?:'
    r'hospit|medic|diagnos|cancer|tumor|surger|stroke|heart attack|'
    r'diabet|seizur|injur|overdos|suicid|miscarriag|pregnan|'
    r'death|died|dying|passed away|funeral|morgue|'
    r'emergenc|ambulanc|intensive care|icu|contagious|'
    r'police|arrest|court|lawsuit|legal|jail|pris|deport|'
    r'identity theft|bank fraud|stolen|robbed|mugged|hacked|scam|'
    r'embassy|visa|immigration|evict|psychiatric|mental health crisis)',
    caseSensitive: false,
  );

  static final RegExp _fabricationCue = RegExp(
    r"(?:claim|pretend|invent|fabricate|make up|tell (?:them|him|her|everyone)|"
    r'say (?:that|my|i)|lie|excuse about)',
    caseSensitive: false,
  );

  RequestRisk _risk(String situation) {
    final containsHighRiskClaim =
        _highRiskClaim.hasMatch(situation) ||
        (_fabricationCue.hasMatch(situation) &&
            RegExp(
              r'(?:medic|ill|sick|dies|dead|emergen|accident|police|'
              r'arrest|court|lawyer|stolen|hacked|injur)',
              caseSensitive: false,
            ).hasMatch(situation));
    return containsHighRiskClaim
        ? RequestRisk.highRiskFabrication
        : RequestRisk.none;
  }

  RequestClarity _clarity(String situation, ExcuseContext context) {
    final containsActionCue =
        situation.contains('cancel') ||
        situation.contains('late') ||
        situation.contains('missed') ||
        situation.contains('miss ') ||
        situation.contains('reschedul') ||
        situation.contains('leave early') ||
        situation.contains('decline') ||
        situation.contains('say no') ||
        situation.contains('delay') ||
        situation.contains('more time') ||
        situation.contains('back out');
    return containsActionCue || context != ExcuseContext.other
        ? RequestClarity.structured
        : RequestClarity.ambiguous;
  }
}
