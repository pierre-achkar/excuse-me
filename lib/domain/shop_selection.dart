import '../domain/excuse_request.dart';

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
