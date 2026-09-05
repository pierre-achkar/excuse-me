import '../domain/excuse_kernel.dart';

const _placeholderIdea =
    'Placeholder: Content pending for the local excuse database.';

class CuratedKernelRepository {
  const CuratedKernelRepository({required this.version, required this.kernels});

  factory CuratedKernelRepository.englishAlpha() {
    return const CuratedKernelRepository(
      version: '1.1.0',
      kernels: [
        ExcuseKernel(
          id: 'en_capacity_reset',
          playfulName: 'Quiet Recharge',
          family: ExcuseFamily.capacityWellbeing,
          causeType: CauseType.capacity,
          responsibilityStrategy: ResponsibilityStrategy.honestBoundary,
          intents: {
            ExcuseIntent.getOutOfPlans,
            ExcuseIntent.recoverFromSituation,
          },
          actions: {
            ExcuseAction.cancel,
            ExcuseAction.leaveEarly,
            ExcuseAction.backOut,
          },
          timings: {
            ExcuseTiming.plannedAhead,
            ExcuseTiming.today,
            ExcuseTiming.lastMinute,
          },
          relationships: {RelationshipKind.close, RelationshipKind.familiar},
          obligations: {ObligationLevel.casual, ObligationLevel.expected},
          contexts: {
            ExcuseContext.celebration,
            ExcuseContext.party,
            ExcuseContext.dinner,
            ExcuseContext.date,
            ExcuseContext.family,
            ExcuseContext.friends,
            ExcuseContext.hobby,
            ExcuseContext.other,
          },
          tones: {ExcuseTone.lowKey, ExcuseTone.nice},
          ideaDirection: 'Idea: You do not have the bandwidth for it today.',
          toneDirections: {
            ExcuseTone.lowKey:
                'Idea: You do not have the bandwidth for it today.',
            ExcuseTone.nice:
                'Idea: You need to step back and take some time to recharge.',
            ExcuseTone.funny:
                'Idea: Your social battery is at 1%; you need the time back.',
            ExcuseTone.dramatic:
                'Idea: Your remaining energy has officially left the building.',
            ExcuseTone.unhinged:
                'Idea: Your social battery has entered witness protection.',
          },
          isPlaceholder: false,
        ),
        ExcuseKernel(
          id: 'en_existing_commitment',
          playfulName: 'Calendar Shield',
          family: ExcuseFamily.planningFailure,
          causeType: CauseType.priorCommitment,
          responsibilityStrategy: ResponsibilityStrategy.limitedControl,
          intents: {ExcuseIntent.getOutOfPlans, ExcuseIntent.buyTime},
          actions: {
            ExcuseAction.cancel,
            ExcuseAction.decline,
            ExcuseAction.reschedule,
          },
          timings: {ExcuseTiming.plannedAhead, ExcuseTiming.today},
          obligations: {ObligationLevel.expected, ObligationLevel.important},
          tones: {ExcuseTone.lowKey, ExcuseTone.nice},
          ideaDirection:
              'Idea: You misjudged the timing and cannot make it work.',
          toneDirections: {
            ExcuseTone.lowKey:
                'Idea: You misjudged the timing and cannot make it work.',
            ExcuseTone.nice:
                'Idea: You got the schedule wrong and need to own the mix-up.',
            ExcuseTone.funny: 'Idea: Your calendar and reality were apparently not in contact.',
          },
          isPlaceholder: false,
        ),
        ExcuseKernel(
          id: 'en_schedule_collision',
          playfulName: 'Double-Booked',
          family: ExcuseFamily.planningFailure,
          causeType: CauseType.schedulingConflict,
          responsibilityStrategy: ResponsibilityStrategy.acknowledgeMistake,
          intents: {ExcuseIntent.getOutOfPlans, ExcuseIntent.buyTime},
          actions: {
            ExcuseAction.backOut,
            ExcuseAction.reschedule,
            ExcuseAction.delay,
          },
          timings: {
            ExcuseTiming.plannedAhead,
            ExcuseTiming.today,
            ExcuseTiming.lastMinute,
          },
          obligations: {
            ObligationLevel.expected,
            ObligationLevel.paidOrReserved,
          },
          tones: {ExcuseTone.lowKey, ExcuseTone.nice, ExcuseTone.dramatic},
          ideaDirection:
              'Idea: You misjudged the timing and cannot make it work.',
          toneDirections: {
            ExcuseTone.lowKey:
                'Idea: You misjudged the timing and cannot make it work.',
            ExcuseTone.nice:
                'Idea: You got the schedule wrong and need to own the mix-up.',
            ExcuseTone.funny: 'Idea: Your calendar and reality were apparently not in contact.',
          },
          isPlaceholder: false,
        ),
        ExcuseKernel(
          id: 'en_logistics_delay',
          playfulName: 'Transit Tangle',
          family: ExcuseFamily.moneyLogistics,
          causeType: CauseType.logistics,
          responsibilityStrategy: ResponsibilityStrategy.limitedControl,
          intents: {ExcuseIntent.buyTime, ExcuseIntent.recoverFromSituation},
          actions: {ExcuseAction.delay, ExcuseAction.explainLateness},
          timings: {
            ExcuseTiming.today,
            ExcuseTiming.lastMinute,
            ExcuseTiming.alreadyLate,
          },
          contexts: {
            ExcuseContext.dinner,
            ExcuseContext.date,
            ExcuseContext.work,
            ExcuseContext.friends,
            ExcuseContext.travel,
            ExcuseContext.other,
          },
          tones: {ExcuseTone.lowKey, ExcuseTone.funny},
          ideaDirection: 'Idea: The logistics no longer work for you.',
          toneDirections: {
            ExcuseTone.lowKey: 'Idea: The logistics no longer work for you.',
            ExcuseTone.nice: 'Idea: You cannot make the timing and logistics work comfortably.',
            ExcuseTone.funny:
                'Idea: The route from here to there has become a side quest.',
          },
          isPlaceholder: false,
        ),
        ExcuseKernel(
          id: 'en_budget_boundary',
          playfulName: 'Wallet Boundary',
          family: ExcuseFamily.moneyLogistics,
          causeType: CauseType.budget,
          responsibilityStrategy: ResponsibilityStrategy.honestBoundary,
          intents: {ExcuseIntent.getOutOfPlans},
          actions: {
            ExcuseAction.cancel,
            ExcuseAction.decline,
            ExcuseAction.avoidCommitting,
          },
          timings: {ExcuseTiming.plannedAhead, ExcuseTiming.today},
          relationships: {RelationshipKind.close, RelationshipKind.familiar},
          obligations: {ObligationLevel.paidOrReserved},
          contexts: {
            ExcuseContext.celebration,
            ExcuseContext.party,
            ExcuseContext.dinner,
            ExcuseContext.date,
            ExcuseContext.friends,
          },
          tones: {ExcuseTone.lowKey, ExcuseTone.nice},
          ideaDirection: 'Idea: The logistics no longer work for you.',
          toneDirections: {
            ExcuseTone.lowKey: 'Idea: The logistics no longer work for you.',
            ExcuseTone.nice: 'Idea: You cannot make the timing and logistics work comfortably.',
            ExcuseTone.funny:
                'Idea: The route from here to there has become a side quest.',
          },
          isPlaceholder: false,
        ),
        ExcuseKernel(
          id: 'en_work_overrun',
          playfulName: 'Deadline Drift',
          family: ExcuseFamily.workStudy,
          causeType: CauseType.workStudy,
          responsibilityStrategy: ResponsibilityStrategy.limitedControl,
          intents: {
            ExcuseIntent.getOutOfPlans,
            ExcuseIntent.buyTime,
            ExcuseIntent.recoverFromSituation,
          },
          actions: {
            ExcuseAction.cancel,
            ExcuseAction.delay,
            ExcuseAction.explainLateness,
            ExcuseAction.explainAbsence,
          },
          timings: {
            ExcuseTiming.today,
            ExcuseTiming.lastMinute,
            ExcuseTiming.alreadyLate,
            ExcuseTiming.alreadyMissed,
          },
          contexts: {
            ExcuseContext.celebration,
            ExcuseContext.party,
            ExcuseContext.dinner,
            ExcuseContext.date,
            ExcuseContext.work,
            ExcuseContext.friends,
            ExcuseContext.hobby,
            ExcuseContext.other,
          },
          tones: {ExcuseTone.lowKey, ExcuseTone.nice, ExcuseTone.dramatic},
          ideaDirection:
              'Idea: Work has spilled into the time you thought you had.',
          toneDirections: {
            ExcuseTone.lowKey:
                'Idea: Work has spilled into the time you thought you had.',
            ExcuseTone.nice:
                'Idea: You underestimated what you still need to finish.',
            ExcuseTone.funny:
                'Idea: Your to-do list has reproduced while unsupervised.',
          },
          isPlaceholder: false,
        ),
        ExcuseKernel(
          id: 'en_household_responsibility',
          playfulName: 'Home Front',
          family: ExcuseFamily.careFamily,
          causeType: CauseType.householdCare,
          responsibilityStrategy: ResponsibilityStrategy.limitedControl,
          intents: {ExcuseIntent.getOutOfPlans, ExcuseIntent.buyTime},
          actions: {
            ExcuseAction.cancel,
            ExcuseAction.leaveEarly,
            ExcuseAction.reschedule,
          },
          timings: {ExcuseTiming.today, ExcuseTiming.lastMinute},
          contexts: {
            ExcuseContext.family,
            ExcuseContext.dinner,
            ExcuseContext.party,
            ExcuseContext.date,
            ExcuseContext.friends,
            ExcuseContext.other,
          },
          tones: {ExcuseTone.lowKey, ExcuseTone.nice},
          ideaDirection: 'Idea: Something personal needs your attention.',
          toneDirections: {
            ExcuseTone.lowKey: 'Idea: Something personal needs your attention.',
            ExcuseTone.nice:
                'Idea: You need to make room for a personal responsibility.',
            ExcuseTone.funny: 'Idea: Home life has unexpectedly promoted itself to top priority.',
          },
          isPlaceholder: false,
        ),
        ExcuseKernel(
          id: 'en_planning_mistake',
          playfulName: 'Calendar Goblin',
          family: ExcuseFamily.absurdDramatic,
          causeType: CauseType.planningFailure,
          responsibilityStrategy: ResponsibilityStrategy.acknowledgeMistake,
          intents: {ExcuseIntent.recoverFromSituation},
          actions: {ExcuseAction.explainLateness, ExcuseAction.explainAbsence},
          timings: {
            ExcuseTiming.today,
            ExcuseTiming.lastMinute,
            ExcuseTiming.alreadyLate,
            ExcuseTiming.alreadyMissed,
          },
          tones: {ExcuseTone.funny, ExcuseTone.dramatic, ExcuseTone.unhinged},
          ideaDirection: 'Idea: Your energy has mysteriously disappeared.',
          toneDirections: {
            ExcuseTone.lowKey:
                'Idea: Your energy has mysteriously disappeared.',
            ExcuseTone.nice: 'Idea: You need to retreat before the evening gets the better of you.',
            ExcuseTone.funny:
                'Idea: Your social battery has filed for bankruptcy.',
            ExcuseTone.dramatic:
                'Idea: The night has demanded a sacrifice. It will not be you.',
            ExcuseTone.unhinged:
                'Idea: Your aura has been recalled by the manufacturer.',
          },
          isPlaceholder: false,
        ),
        ExcuseKernel(
          id: 'en_early_start',
          playfulName: 'Tomorrow Tax',
          family: ExcuseFamily.capacityWellbeing,
          causeType: CauseType.capacity,
          responsibilityStrategy: ResponsibilityStrategy.honestBoundary,
          intents: {ExcuseIntent.getOutOfPlans},
          actions: {
            ExcuseAction.cancel,
            ExcuseAction.leaveEarly,
            ExcuseAction.backOut,
          },
          timings: {
            ExcuseTiming.plannedAhead,
            ExcuseTiming.today,
            ExcuseTiming.lastMinute,
          },
          relationships: {RelationshipKind.close, RelationshipKind.familiar},
          contexts: {
            ExcuseContext.celebration,
            ExcuseContext.party,
            ExcuseContext.dinner,
            ExcuseContext.date,
            ExcuseContext.friends,
          },
          tones: {ExcuseTone.lowKey, ExcuseTone.nice, ExcuseTone.funny},
          ideaDirection: 'Idea: You do not have the bandwidth for it today.',
          toneDirections: {
            ExcuseTone.lowKey:
                'Idea: You do not have the bandwidth for it today.',
            ExcuseTone.nice:
                'Idea: You need to step back and take some time to recharge.',
            ExcuseTone.funny:
                'Idea: Your social battery is at 1%; you need the time back.',
          },
          isPlaceholder: false,
        ),
        ExcuseKernel(
          id: 'en_honest_decline',
          playfulName: 'Clean No',
          family: ExcuseFamily.boundaryPreference,
          causeType: CauseType.preference,
          responsibilityStrategy: ResponsibilityStrategy.honestBoundary,
          intents: {ExcuseIntent.getOutOfPlans, ExcuseIntent.buyTime},
          actions: {ExcuseAction.decline, ExcuseAction.avoidCommitting},
          timings: {
            ExcuseTiming.plannedAhead,
            ExcuseTiming.today,
            ExcuseTiming.recurring,
          },
          obligations: {ObligationLevel.casual, ObligationLevel.expected},
          tones: {ExcuseTone.lowKey, ExcuseTone.nice},
          ideaDirection: 'Idea: You need to pass this time.',
          toneDirections: {
            ExcuseTone.lowKey: 'Idea: You need to pass this time.',
            ExcuseTone.nice:
                'Idea: You need to bow out and keep the time for yourself.',
            ExcuseTone.funny:
                'Idea: Your internal RSVP has changed to a respectful nope.',
            ExcuseTone.dramatic:
                'Idea: The boundary has been drawn. The evening stays yours.',
            ExcuseTone.unhinged:
                'Idea: The council has voted unanimously: absolutely not.',
          },
          isPlaceholder: false,
        ),
        ExcuseKernel(
          id: 'en_alternative_timing',
          playfulName: 'Rain Check',
          family: ExcuseFamily.boundaryPreference,
          causeType: CauseType.schedulingConflict,
          responsibilityStrategy: ResponsibilityStrategy.repair,
          intents: {ExcuseIntent.buyTime},
          actions: {
            ExcuseAction.reschedule,
            ExcuseAction.delay,
            ExcuseAction.suggestAlternative,
          },
          timings: {
            ExcuseTiming.plannedAhead,
            ExcuseTiming.today,
            ExcuseTiming.lastMinute,
            ExcuseTiming.alreadyLate,
          },
          relationships: {
            RelationshipKind.close,
            RelationshipKind.familiar,
            RelationshipKind.distant,
          },
          obligations: {ObligationLevel.casual, ObligationLevel.expected},
          tones: {ExcuseTone.lowKey, ExcuseTone.nice, ExcuseTone.funny},
          ideaDirection: 'Idea: You need to pass this time.',
          toneDirections: {
            ExcuseTone.lowKey: 'Idea: You need to pass this time.',
            ExcuseTone.nice:
                'Idea: You need to bow out and keep the time for yourself.',
            ExcuseTone.funny:
                'Idea: Your internal RSVP has changed to a respectful nope.',
          },
          isPlaceholder: false,
        ),
        ExcuseKernel(
          id: 'en_honest_boundary_fallback',
          playfulName: 'Honest Exit',
          family: ExcuseFamily.boundaryPreference,
          causeType: CauseType.preference,
          responsibilityStrategy: ResponsibilityStrategy.repair,
          intents: {
            ExcuseIntent.getOutOfPlans,
            ExcuseIntent.buyTime,
            ExcuseIntent.recoverFromSituation,
          },
          actions: {
            ExcuseAction.cancel,
            ExcuseAction.decline,
            ExcuseAction.leaveEarly,
            ExcuseAction.backOut,
            ExcuseAction.reschedule,
            ExcuseAction.delay,
            ExcuseAction.avoidCommitting,
            ExcuseAction.explainLateness,
            ExcuseAction.explainAbsence,
            ExcuseAction.acknowledgeMiss,
            ExcuseAction.suggestAlternative,
          },
          tones: {
            ExcuseTone.lowKey,
            ExcuseTone.nice,
            ExcuseTone.funny,
            ExcuseTone.dramatic,
            ExcuseTone.unhinged,
          },
          ideaDirection: _placeholderIdea,
          isPlaceholder: true,
          isFallback: true,
        ),
        ExcuseKernel(
          id: 'en_repair_path_fallback',
          playfulName: 'Repair Path',
          family: ExcuseFamily.boundaryPreference,
          causeType: CauseType.preference,
          responsibilityStrategy: ResponsibilityStrategy.repair,
          intents: {
            ExcuseIntent.getOutOfPlans,
            ExcuseIntent.buyTime,
            ExcuseIntent.recoverFromSituation,
          },
          actions: {
            ExcuseAction.cancel,
            ExcuseAction.decline,
            ExcuseAction.leaveEarly,
            ExcuseAction.backOut,
            ExcuseAction.reschedule,
            ExcuseAction.delay,
            ExcuseAction.avoidCommitting,
            ExcuseAction.explainLateness,
            ExcuseAction.explainAbsence,
            ExcuseAction.acknowledgeMiss,
            ExcuseAction.suggestAlternative,
          },
          tones: {
            ExcuseTone.lowKey,
            ExcuseTone.nice,
            ExcuseTone.funny,
            ExcuseTone.dramatic,
            ExcuseTone.unhinged,
          },
          ideaDirection: _placeholderIdea,
          isPlaceholder: true,
          isFallback: true,
        ),
      ],
    );
  }

  final String version;
  final List<ExcuseKernel> kernels;
}
