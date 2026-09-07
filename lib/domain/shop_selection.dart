import '../domain/excuse_request.dart';
import '../domain/user_profile.dart';

class ShopTimingOption {
  const ShopTimingOption({
    required this.id,
    required this.labelKey,
    required this.timing,
  });

  final String id;
  final String labelKey;
  final ExcuseTiming timing;
}

/// One typed option per v6 conversation beat. Presentation labels never carry
/// the routing logic; the enum values travel with the selected option.
class ShopIntentOption {
  const ShopIntentOption({
    required this.id,
    required this.labelKey,
    required this.intent,
  });

  final String id;
  final String labelKey;
  final ExcuseIntent intent;
}

class ShopActionOption {
  const ShopActionOption({
    required this.id,
    required this.labelKey,
    required this.intent,
    required this.action,
  });

  final String id;
  final String labelKey;
  final ExcuseIntent intent;
  final ExcuseAction action;
}

class ShopContextOption {
  const ShopContextOption({
    required this.id,
    required this.labelKey,
    required this.context,
  });

  final String id;
  final String labelKey;
  final ExcuseContext context;
}

class ShopRelationshipOption {
  const ShopRelationshipOption({
    required this.id,
    required this.labelKey,
    required this.relationship,
  });

  final String id;
  final String labelKey;
  final RelationshipKind relationship;
}

class ShopObligationOption {
  const ShopObligationOption({
    required this.id,
    required this.labelKey,
    required this.obligation,
  });

  final String id;
  final String labelKey;
  final ObligationLevel obligation;
}

const shopIntentOptions = <ShopIntentOption>[
  ShopIntentOption(
    id: 'need-out',
    labelKey: 'intentNeedOut',
    intent: ExcuseIntent.getOutOfPlans,
  ),
  ShopIntentOption(
    id: 'need-more-time',
    labelKey: 'intentNeedMoreTime',
    intent: ExcuseIntent.buyTime,
  ),
  ShopIntentOption(
    id: 'already-messed-up',
    labelKey: 'intentAlreadyMessedUp',
    intent: ExcuseIntent.recoverFromSituation,
  ),
];

const _actionsByIntent = <ExcuseIntent, List<ShopActionOption>>{
  ExcuseIntent.getOutOfPlans: [
    ShopActionOption(
      id: 'cancel',
      labelKey: 'actionCancelSomething',
      intent: ExcuseIntent.getOutOfPlans,
      action: ExcuseAction.cancel,
    ),
    ShopActionOption(
      id: 'say-no',
      labelKey: 'actionSayNo',
      intent: ExcuseIntent.getOutOfPlans,
      action: ExcuseAction.decline,
    ),
    ShopActionOption(
      id: 'leave-early',
      labelKey: 'actionLeaveEarly',
      intent: ExcuseIntent.getOutOfPlans,
      action: ExcuseAction.leaveEarly,
    ),
  ],
  ExcuseIntent.buyTime: [
    ShopActionOption(
      id: 'reschedule',
      labelKey: 'actionReschedule',
      intent: ExcuseIntent.buyTime,
      action: ExcuseAction.reschedule,
    ),
    ShopActionOption(
      id: 'delay',
      labelKey: 'actionDelay',
      intent: ExcuseIntent.buyTime,
      action: ExcuseAction.delay,
    ),
    ShopActionOption(
      id: 'avoid-committing',
      labelKey: 'actionAvoidCommitting',
      intent: ExcuseIntent.buyTime,
      action: ExcuseAction.avoidCommitting,
    ),
  ],
  ExcuseIntent.recoverFromSituation: [
    ShopActionOption(
      id: 'explain-what-happened',
      labelKey: 'actionExplainWhatHappened',
      intent: ExcuseIntent.recoverFromSituation,
      action: ExcuseAction.explainLateness,
    ),
    ShopActionOption(
      id: 'ask-more-time',
      labelKey: 'actionAskMoreTime',
      intent: ExcuseIntent.recoverFromSituation,
      action: ExcuseAction.explainAbsence,
    ),
    ShopActionOption(
      id: 'acknowledge-miss',
      labelKey: 'actionAcknowledgeMiss',
      intent: ExcuseIntent.recoverFromSituation,
      action: ExcuseAction.acknowledgeMiss,
    ),
  ],
};

List<ShopActionOption> shopActionOptionsFor(ExcuseIntent intent) {
  return List.unmodifiable(_actionsByIntent[intent]!);
}

const shopContextOptions = <ShopContextOption>[
  ShopContextOption(
    id: 'social',
    labelKey: 'contextSocial',
    context: ExcuseContext.social,
  ),
  ShopContextOption(
    id: 'personal',
    labelKey: 'contextPersonal',
    context: ExcuseContext.personal,
  ),
  ShopContextOption(
    id: 'work-study',
    labelKey: 'contextWorkStudy',
    context: ExcuseContext.workStudy,
  ),
  ShopContextOption(
    id: 'practical',
    labelKey: 'contextPractical',
    context: ExcuseContext.practical,
  ),
];

const _visibleTimings = <ShopTimingOption>[
  ShopTimingOption(
    id: 'planned-ahead',
    labelKey: 'timingPlannedAhead',
    timing: ExcuseTiming.plannedAhead,
  ),
  ShopTimingOption(
    id: 'today',
    labelKey: 'timingToday',
    timing: ExcuseTiming.today,
  ),
  ShopTimingOption(
    id: 'last-minute',
    labelKey: 'timingLastMinute',
    timing: ExcuseTiming.lastMinute,
  ),
  ShopTimingOption(
    id: 'happening-now',
    labelKey: 'timingHappeningNow',
    timing: ExcuseTiming.happeningNow,
  ),
];

List<ShopTimingOption> shopTimingOptionsFor(ShopActionOption action) {
  return action.action == ExcuseAction.explainLateness ||
          action.action == ExcuseAction.explainAbsence ||
          action.action == ExcuseAction.acknowledgeMiss
      ? const []
      : List.unmodifiable(_visibleTimings);
}

const shopRelationshipOptions = <ShopRelationshipOption>[
  ShopRelationshipOption(
    id: 'close',
    labelKey: 'relationshipClose',
    relationship: RelationshipKind.close,
  ),
  ShopRelationshipOption(
    id: 'casual',
    labelKey: 'relationshipCasual',
    relationship: RelationshipKind.casual,
  ),
  ShopRelationshipOption(
    id: 'formal',
    labelKey: 'relationshipFormal',
    relationship: RelationshipKind.formal,
  ),
];

const shopObligationOptions = <ShopObligationOption>[
  ShopObligationOption(
    id: 'low',
    labelKey: 'obligationLow',
    obligation: ObligationLevel.low,
  ),
  ShopObligationOption(
    id: 'medium',
    labelKey: 'obligationMedium',
    obligation: ObligationLevel.medium,
  ),
  ShopObligationOption(
    id: 'high',
    labelKey: 'obligationHigh',
    obligation: ObligationLevel.high,
  ),
];

ExcuseRequest requestForV6Selections({
  required ShopIntentOption intent,
  required ShopActionOption action,
  required ShopContextOption context,
  ShopTimingOption? timing,
  required ShopRelationshipOption relationship,
  required ShopObligationOption obligation,
  UserProfile profile = const UserProfile.empty(),
  CurrentVisitContext currentVisitContext = const CurrentVisitContext.skip(),
}) {
  final resolvedTiming = timing?.timing ?? ExcuseTiming.alreadyHappened;
  return ExcuseRequest(
    intent: intent.intent,
    action: action.action,
    timing: resolvedTiming,
    relationship: relationship.relationship,
    obligation: obligation.obligation,
    context: context.context,
    tone: ExcuseTone.lowKey,
    repairPreference:
        shouldOfferRepairForV6(
          intent.intent,
          action.action,
          resolvedTiming,
          obligation.obligation,
        )
        ? RepairOption.briefApology
        : RepairOption.none,
    profile: profile,
    currentVisitContext: currentVisitContext,
  );
}

bool shouldOfferRepairForV6(
  ExcuseIntent intent,
  ExcuseAction action,
  ExcuseTiming timing,
  ObligationLevel obligation,
) {
  return intent == ExcuseIntent.recoverFromSituation ||
      action == ExcuseAction.acknowledgeMiss ||
      timing == ExcuseTiming.alreadyHappened ||
      obligation == ObligationLevel.high;
}
