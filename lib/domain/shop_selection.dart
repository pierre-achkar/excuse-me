import '../domain/excuse_request.dart';

class ShopMission {
  const ShopMission({
    required this.label,
    required this.intent,
    required this.action,
    required this.situations,
  });

  final String label;
  final ExcuseIntent intent;
  final ExcuseAction action;
  final List<ShopSituation> situations;
}

class ShopSituation {
  const ShopSituation({
    required this.label,
    required this.context,
    this.action,
  });

  final String label;
  final ExcuseContext context;
  final ExcuseAction? action;
}

class ShopTone {
  const ShopTone({required this.label, required this.tone});

  final String label;
  final ExcuseTone tone;
}

const shopMissions = [
  ShopMission(
    label: 'Get out of plans',
    intent: ExcuseIntent.getOutOfPlans,
    action: ExcuseAction.cancel,
    situations: [
      ShopSituation(label: 'Dinner', context: ExcuseContext.dinner),
      ShopSituation(label: 'Party', context: ExcuseContext.party),
      ShopSituation(label: 'Work', context: ExcuseContext.work),
      ShopSituation(label: 'Family', context: ExcuseContext.family),
      ShopSituation(label: 'Friends', context: ExcuseContext.friends),
    ],
  ),
  ShopMission(
    label: 'Buy time',
    intent: ExcuseIntent.buyTime,
    action: ExcuseAction.reschedule,
    situations: [
      ShopSituation(
        label: 'Reschedule',
        context: ExcuseContext.work,
        action: ExcuseAction.reschedule,
      ),
      ShopSituation(
        label: 'Delay',
        context: ExcuseContext.other,
        action: ExcuseAction.delay,
      ),
    ],
  ),
  ShopMission(
    label: 'Recover from a situation',
    intent: ExcuseIntent.recoverFromSituation,
    action: ExcuseAction.explainLateness,
    situations: [
      ShopSituation(
        label: 'Late',
        context: ExcuseContext.dinner,
        action: ExcuseAction.explainLateness,
      ),
      ShopSituation(
        label: 'Missed',
        context: ExcuseContext.work,
        action: ExcuseAction.explainAbsence,
      ),
    ],
  ),
];

const shopTones = [
  ShopTone(label: 'Straightforward', tone: ExcuseTone.lowKey),
  ShopTone(label: 'Warm', tone: ExcuseTone.nice),
  ShopTone(label: 'Funny', tone: ExcuseTone.funny),
];
