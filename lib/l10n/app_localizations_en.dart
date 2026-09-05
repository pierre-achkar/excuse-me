// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Excuse Me';

  @override
  String get shopTitle => 'The Excuse Shop';

  @override
  String get shopkeeperAvatarLabel => 'Pixel art shopkeeper';

  @override
  String get shopHeaderDescription =>
      'A friendly shopkeeper helps you craft the perfect excuse.';

  @override
  String stepIndicator(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get shopkeeperWelcome =>
      'Welcome! Tell me what you need and I will help you out.';

  @override
  String get shopkeeperSituation =>
      'Great choice. Now pick a situation that fits.';

  @override
  String get shopkeeperTone => 'Almost there. Pick how loud you want this.';

  @override
  String get dialogueDamage => 'What\'s the damage?';

  @override
  String get dialogueTiming => 'When\'s the reckoning?';

  @override
  String get dialogueAudience => 'Who\'s on the other end?';

  @override
  String get dialogueDelivery => 'How loud do you want this?';

  @override
  String get damageDinner => 'A dinner I can\'t face';

  @override
  String get damageParty => 'A party I said yes to';

  @override
  String get damageGroupWorkCall => 'A group work call';

  @override
  String get damageDate => 'A date I\'m dreading';

  @override
  String get damageMissed => 'I missed something';

  @override
  String get timingPlannedAhead => 'Planned ahead';

  @override
  String get timingToday => 'Today';

  @override
  String get timingLastMinute => 'Last minute';

  @override
  String get timingAlreadyLate => 'Already late';

  @override
  String get timingAlreadyMissed => 'Already missed';

  @override
  String get audienceSomeoneClose => 'Someone close';

  @override
  String get audienceSomeoneFamiliar => 'Someone familiar';

  @override
  String get audienceAGroup => 'A group';

  @override
  String get audienceWorkContact => 'A work contact';

  @override
  String get audienceSomeoneInCharge => 'Someone in charge';

  @override
  String get deliveryLowKeyText => 'Low-key text';

  @override
  String get deliveryNiceText => 'Nice text';

  @override
  String get deliveryFunnyText => 'Funny text';

  @override
  String get deliveryDramaticVoiceNote => 'Dramatic voice note';

  @override
  String get deliveryUnhingedCall => 'Unhinged call';

  @override
  String get shopkeeperSays => 'Shopkeeper says:';

  @override
  String get situationSectionTitle => 'Choose a situation';

  @override
  String get toneSectionTitle => 'Choose your ingredient';

  @override
  String get missionGetOutOfPlans => 'Get out of plans';

  @override
  String get missionBuyTime => 'Buy time';

  @override
  String get missionRecoverFromSituation => 'Recover from a situation';

  @override
  String get situationDinner => 'Dinner';

  @override
  String get situationParty => 'Party';

  @override
  String get situationWork => 'Work';

  @override
  String get situationFamily => 'Family';

  @override
  String get situationFriends => 'Friends';

  @override
  String get situationReschedule => 'Reschedule';

  @override
  String get situationDelay => 'Delay';

  @override
  String get situationLate => 'Late';

  @override
  String get situationMissed => 'Missed';

  @override
  String get toneStraightforward => 'Straightforward';

  @override
  String get toneWarm => 'Warm';

  @override
  String get toneFunny => 'Funny';

  @override
  String get toneLowKey => 'Low-key';

  @override
  String get toneNice => 'Nice';

  @override
  String get toneDramatic => 'Dramatic';

  @override
  String get toneUnhinged => 'Unhinged';

  @override
  String chooseMission(String mission) {
    return 'Choose mission: $mission';
  }

  @override
  String chooseSituation(String situation) {
    return 'Choose situation: $situation';
  }

  @override
  String chooseTone(String tone) {
    return 'Choose ingredient: $tone';
  }

  @override
  String chooseDamage(String option) {
    return 'Choose damage: $option';
  }

  @override
  String chooseTiming(String option) {
    return 'Choose timing: $option';
  }

  @override
  String chooseAudience(String option) {
    return 'Choose audience: $option';
  }

  @override
  String chooseDelivery(String option) {
    return 'Choose delivery: $option';
  }

  @override
  String get brewingYourExcuse => 'Brewing your excuse...';

  @override
  String get brewingYourExcuseSemantic => 'Brewing your excuse';

  @override
  String get resultTitle => 'Your excuse';

  @override
  String get repairDirectionLabel => 'Repair direction';

  @override
  String get repairDirectionPending =>
      'A small repair direction is available for you to phrase in your own words.';

  @override
  String get collectibleIdeaBadge => 'COLLECTIBLE IDEA';

  @override
  String get regenerateButton => 'Regenerate';

  @override
  String get copyButton => 'Copy';

  @override
  String get shareButton => 'Share';

  @override
  String get newExcuseButton => 'New excuse';

  @override
  String get regenerateSemantics => 'Regenerate excuse';

  @override
  String get copySemantics => 'Copy excuse to clipboard';

  @override
  String get shareSemantics => 'Share excuse';

  @override
  String get newExcuseSemantics => 'Start new excuse';

  @override
  String get ideaCopied => 'Idea copied.';

  @override
  String get generationError => 'Unable to generate an idea. Please try again.';

  @override
  String get oldFormTitle => 'Excuse Me';

  @override
  String get oldFormHeading => 'Find a way to explain it.';

  @override
  String get oldFormSubheading =>
      'Get one private, adaptable idea - never a message to send.';

  @override
  String get oldFormSituationLabel => 'What happened?';

  @override
  String get oldFormSituationHint => 'Describe the situation';

  @override
  String get oldFormRelationshipLabel => 'Relationship';

  @override
  String get oldFormUrgencyLabel => 'Urgency';

  @override
  String get oldFormToneLabel => 'Tone';

  @override
  String get oldFormFriend => 'Friend';

  @override
  String get oldFormFamily => 'Family';

  @override
  String get oldFormCoworker => 'Coworker';

  @override
  String get oldFormClient => 'Client';

  @override
  String get oldFormSoon => 'Soon';

  @override
  String get oldFormToday => 'Today';

  @override
  String get oldFormThisWeek => 'This week';

  @override
  String get oldFormToneWarm => 'Warm';

  @override
  String get oldFormToneDirect => 'Direct';

  @override
  String get oldFormToneProfessional => 'Professional';

  @override
  String get oldFormGenerateButton => 'Generate idea';

  @override
  String get oldFormRegenerateButton => 'Regenerate';

  @override
  String get oldFormResultTitle => 'Your idea';

  @override
  String get oldFormEmptyError =>
      'Describe the situation before generating an idea.';
}
