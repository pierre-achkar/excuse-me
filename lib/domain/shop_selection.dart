import '../domain/excuse_request.dart';
import '../domain/user_profile.dart';

class ShopMission {
  const ShopMission({
    required this.titleKey,
    required this.slug,
    required this.intent,
    required this.action,
    required this.situations,
  });

  final String titleKey;
  final String slug;
  final ExcuseIntent intent;
  final ExcuseAction action;
  final List<ShopSituation> situations;
}

class ShopSituation {
  const ShopSituation({
    required this.titleKey,
    required this.slug,
    required this.context,
    this.action,
  });

  final String titleKey;
  final String slug;
  final ExcuseContext context;
  final ExcuseAction? action;
}

class ShopTone {
  const ShopTone({required this.titleKey, required this.tone});

  final String titleKey;
  final ExcuseTone tone;
}

class ShopDamageOption {
  const ShopDamageOption({
    required this.id,
    required this.labelKey,
    required this.intent,
    required this.action,
    required this.context,
    required this.obligation,
  });

  final String id;
  final String labelKey;
  final ExcuseIntent intent;
  final ExcuseAction action;
  final ExcuseContext context;
  final ObligationLevel obligation;
}

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

class ShopAudienceOption {
  const ShopAudienceOption({
    required this.id,
    required this.labelKey,
    required this.audienceSize,
    required this.relationship,
  });

  final String id;
  final String labelKey;
  final AudienceSize audienceSize;
  final RelationshipKind relationship;
}

class ShopDeliveryOption {
  const ShopDeliveryOption({
    required this.id,
    required this.labelKey,
    required this.channel,
    required this.tone,
  });

  final String id;
  final String labelKey;
  final ExcuseChannel channel;
  final ExcuseTone tone;
}

const shopDamageOptions = <ShopDamageOption>[
  ShopDamageOption(
    id: 'dinner',
    labelKey: 'damageDinner',
    intent: ExcuseIntent.getOutOfPlans,
    action: ExcuseAction.cancel,
    context: ExcuseContext.dinner,
    obligation: ObligationLevel.expected,
  ),
  ShopDamageOption(
    id: 'party',
    labelKey: 'damageParty',
    intent: ExcuseIntent.getOutOfPlans,
    action: ExcuseAction.cancel,
    context: ExcuseContext.party,
    obligation: ObligationLevel.expected,
  ),
  ShopDamageOption(
    id: 'group-work-call',
    labelKey: 'damageGroupWorkCall',
    intent: ExcuseIntent.buyTime,
    action: ExcuseAction.reschedule,
    context: ExcuseContext.work,
    obligation: ObligationLevel.important,
  ),
  ShopDamageOption(
    id: 'date',
    labelKey: 'damageDate',
    intent: ExcuseIntent.getOutOfPlans,
    action: ExcuseAction.decline,
    context: ExcuseContext.date,
    obligation: ObligationLevel.expected,
  ),
  ShopDamageOption(
    id: 'missed',
    labelKey: 'damageMissed',
    intent: ExcuseIntent.recoverFromSituation,
    action: ExcuseAction.explainAbsence,
    context: ExcuseContext.work,
    obligation: ObligationLevel.important,
  ),
];

const shopTimingOptions = <ShopTimingOption>[
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
    id: 'already-late',
    labelKey: 'timingAlreadyLate',
    timing: ExcuseTiming.alreadyLate,
  ),
  ShopTimingOption(
    id: 'already-missed',
    labelKey: 'timingAlreadyMissed',
    timing: ExcuseTiming.alreadyMissed,
  ),
];

const shopAudienceOptions = <ShopAudienceOption>[
  ShopAudienceOption(
    id: 'someone-close',
    labelKey: 'audienceSomeoneClose',
    audienceSize: AudienceSize.individual,
    relationship: RelationshipKind.close,
  ),
  ShopAudienceOption(
    id: 'someone-familiar',
    labelKey: 'audienceSomeoneFamiliar',
    audienceSize: AudienceSize.individual,
    relationship: RelationshipKind.familiar,
  ),
  ShopAudienceOption(
    id: 'a-group',
    labelKey: 'audienceAGroup',
    audienceSize: AudienceSize.group,
    relationship: RelationshipKind.familiar,
  ),
  ShopAudienceOption(
    id: 'work-contact',
    labelKey: 'audienceWorkContact',
    audienceSize: AudienceSize.individual,
    relationship: RelationshipKind.professional,
  ),
  ShopAudienceOption(
    id: 'someone-in-charge',
    labelKey: 'audienceSomeoneInCharge',
    audienceSize: AudienceSize.individual,
    relationship: RelationshipKind.authority,
  ),
];

const shopDeliveryOptions = <ShopDeliveryOption>[
  ShopDeliveryOption(
    id: 'low-key-text',
    labelKey: 'deliveryLowKeyText',
    channel: ExcuseChannel.text,
    tone: ExcuseTone.lowKey,
  ),
  ShopDeliveryOption(
    id: 'nice-text',
    labelKey: 'deliveryNiceText',
    channel: ExcuseChannel.text,
    tone: ExcuseTone.nice,
  ),
  ShopDeliveryOption(
    id: 'funny-text',
    labelKey: 'deliveryFunnyText',
    channel: ExcuseChannel.text,
    tone: ExcuseTone.funny,
  ),
  ShopDeliveryOption(
    id: 'dramatic-voice-note',
    labelKey: 'deliveryDramaticVoiceNote',
    channel: ExcuseChannel.voiceNote,
    tone: ExcuseTone.dramatic,
  ),
  ShopDeliveryOption(
    id: 'unhinged-call',
    labelKey: 'deliveryUnhingedCall',
    channel: ExcuseChannel.call,
    tone: ExcuseTone.unhinged,
  ),
];

ExcuseRequest requestForShopSelections({
  required ShopDamageOption damage,
  required ShopTimingOption timing,
  required ShopAudienceOption audience,
  required ShopDeliveryOption delivery,
  RepairOption repairPreference = RepairOption.none,
}) {
  return ExcuseRequest(
    intent: damage.intent,
    action: damage.action,
    timing: timing.timing,
    relationship: audience.relationship,
    obligation: damage.obligation,
    context: damage.context,
    tone: delivery.tone,
    audienceSize: audience.audienceSize,
    channel: delivery.channel,
    repairPreference: repairPreference,
  );
}

bool shouldOfferRepair(ExcuseRequest request) {
  return request.intent == ExcuseIntent.recoverFromSituation ||
      request.timing == ExcuseTiming.alreadyLate ||
      request.timing == ExcuseTiming.alreadyMissed ||
      request.obligation == ObligationLevel.important ||
      request.obligation == ObligationLevel.paidOrReserved ||
      request.obligation == ObligationLevel.hardToReplace;
}

const shopMissions = [
  ShopMission(
    titleKey: 'missionGetOutOfPlans',
    slug: 'get out of plans',
    intent: ExcuseIntent.getOutOfPlans,
    action: ExcuseAction.cancel,
    situations: [
      ShopSituation(
        titleKey: 'situationDinner',
        slug: 'dinner',
        context: ExcuseContext.dinner,
      ),
      ShopSituation(
        titleKey: 'situationParty',
        slug: 'party',
        context: ExcuseContext.party,
      ),
      ShopSituation(
        titleKey: 'situationWork',
        slug: 'work',
        context: ExcuseContext.work,
      ),
      ShopSituation(
        titleKey: 'situationFamily',
        slug: 'family',
        context: ExcuseContext.family,
      ),
      ShopSituation(
        titleKey: 'situationFriends',
        slug: 'friends',
        context: ExcuseContext.friends,
      ),
    ],
  ),
  ShopMission(
    titleKey: 'missionBuyTime',
    slug: 'buy time',
    intent: ExcuseIntent.buyTime,
    action: ExcuseAction.reschedule,
    situations: [
      ShopSituation(
        titleKey: 'situationReschedule',
        slug: 'reschedule',
        context: ExcuseContext.work,
        action: ExcuseAction.reschedule,
      ),
      ShopSituation(
        titleKey: 'situationDelay',
        slug: 'delay',
        context: ExcuseContext.other,
        action: ExcuseAction.delay,
      ),
    ],
  ),
  ShopMission(
    titleKey: 'missionRecoverFromSituation',
    slug: 'recover',
    intent: ExcuseIntent.recoverFromSituation,
    action: ExcuseAction.explainLateness,
    situations: [
      ShopSituation(
        titleKey: 'situationLate',
        slug: 'late',
        context: ExcuseContext.dinner,
        action: ExcuseAction.explainLateness,
      ),
      ShopSituation(
        titleKey: 'situationMissed',
        slug: 'missed',
        context: ExcuseContext.work,
        action: ExcuseAction.explainAbsence,
      ),
    ],
  ),
];

const shopTones = [
  ShopTone(titleKey: 'toneStraightforward', tone: ExcuseTone.lowKey),
  ShopTone(titleKey: 'toneWarm', tone: ExcuseTone.nice),
  ShopTone(titleKey: 'toneFunny', tone: ExcuseTone.funny),
];

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
