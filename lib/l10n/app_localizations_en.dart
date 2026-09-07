// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pardon';

  @override
  String stepIndicator(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get dialogueTiming => 'When\'s the reckoning?';

  @override
  String get timingPlannedAhead => 'Planned ahead';

  @override
  String get timingToday => 'Today';

  @override
  String get timingLastMinute => 'Last minute';

  @override
  String get repairDirectionLabel => 'Repair direction';

  @override
  String get repairDirectionPending =>
      'A small repair direction is available for you to phrase in your own words.';

  @override
  String get copyButton => 'Copy';

  @override
  String get shareButton => 'Share';

  @override
  String get ideaCopied => 'Idea copied.';

  @override
  String get generationError => 'Unable to generate an idea. Please try again.';

  @override
  String get generationErrorBody =>
      'Nothing came off the shelf this time. Your answers are still here.';

  @override
  String get generationRetry => 'Try again';

  @override
  String answerEcho(String answer) {
    return '$answer.';
  }

  @override
  String get entryCta => 'I need an excuse';

  @override
  String get dialogueIntent => 'Now then... what\'s the situation?';

  @override
  String get dialogueActionOut => 'Ah. An escape. What\'s the plan?';

  @override
  String get dialogueActionTime => 'Patience is a resource. What do you need?';

  @override
  String get dialogueActionRecover =>
      'The ledger remembers. What needs explaining?';

  @override
  String get dialogueContext => 'Where is this trouble taking place?';

  @override
  String get dialogueTimingV6 => 'When does the clock start complaining?';

  @override
  String get dialogueRelationshipV6 => 'Who is waiting for an answer?';

  @override
  String get dialogueObligationV6 => 'How much does this one matter?';

  @override
  String get searchDialogue => 'Let me look through the shelves.';

  @override
  String get handoverDialogue => 'There. This one should do.';

  @override
  String get intentNeedOut => 'I need out';

  @override
  String get intentNeedMoreTime => 'I need more time';

  @override
  String get intentAlreadyMessedUp => 'I already messed up';

  @override
  String get actionCancelSomething => 'Cancel something';

  @override
  String get actionSayNo => 'Say no';

  @override
  String get actionLeaveEarly => 'Leave early';

  @override
  String get actionReschedule => 'Reschedule';

  @override
  String get actionDelay => 'Delay the answer';

  @override
  String get actionAvoidCommitting => 'Avoid committing';

  @override
  String get actionExplainWhatHappened => 'Explain what happened';

  @override
  String get actionAskMoreTime => 'Ask for more time';

  @override
  String get actionAcknowledgeMiss => 'Acknowledge the miss';

  @override
  String get contextSocial => 'Social plans';

  @override
  String get contextPersonal => 'Personal life';

  @override
  String get contextWorkStudy => 'Work or study';

  @override
  String get contextPractical => 'A practical thing';

  @override
  String get timingHappeningNow => 'Happening now';

  @override
  String get relationshipClose => 'Someone close';

  @override
  String get relationshipCasual => 'Someone I know';

  @override
  String get relationshipFormal => 'Someone formal';

  @override
  String get obligationLow => 'Low stakes';

  @override
  String get obligationMedium => 'Somewhat important';

  @override
  String get obligationHigh => 'High stakes';

  @override
  String chooseIntent(String option) {
    return 'Choose intent: $option';
  }

  @override
  String chooseAction(String option) {
    return 'Choose action: $option';
  }

  @override
  String chooseContext(String option) {
    return 'Choose context: $option';
  }

  @override
  String chooseRelationshipV6(String option) {
    return 'Choose relationship: $option';
  }

  @override
  String chooseObligation(String option) {
    return 'Choose obligation: $option';
  }

  @override
  String get searchingLabel => 'Wick is searching the shop';

  @override
  String get cardIdeaLabel => 'The idea';

  @override
  String get keepCardButton => 'Keep card';

  @override
  String outfitSemantics(String palette) {
    return 'Wick\'s outfit: $palette';
  }

  @override
  String ambientEventSemantics(String event) {
    return 'Shop event: $event';
  }

  @override
  String get oldFormTitle => 'Pardon';

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

  @override
  String get cardViewerRevealTitle => 'Your card';

  @override
  String get cardViewerSavedTitle => 'Saved card';

  @override
  String get closeAction => 'Close';

  @override
  String get shareCardTooltip => 'Share card';

  @override
  String get copyIdeaTooltip => 'Copy idea';

  @override
  String get savingCard => 'Saving…';

  @override
  String get cardSavedToCollection => 'Saved to collection';

  @override
  String get anotherOneAction => 'Another one';

  @override
  String get doneAction => 'Done';

  @override
  String get notThisOneAction => 'Not this one';

  @override
  String get shareUnavailable => 'Sharing is not available here.';

  @override
  String get shareFailed => 'Could not share this card. Try again.';

  @override
  String collectionTitle(String count) {
    return 'Collection · $count';
  }

  @override
  String get collectionEmptyTitle => 'Your collection is empty.';

  @override
  String get collectionEmptyBody =>
      'Choose “Keep card” when you find one you like.\nYour cards stay on this device.';

  @override
  String get collectionLoadError => 'Could not load your collection.';

  @override
  String get retryAction => 'Retry';

  @override
  String collectionCardSemantics(String name) {
    return '$name collection card';
  }

  @override
  String get shopkeeperName => 'Wick';

  @override
  String get backAction => 'Back';

  @override
  String get startOverAction => 'Start over';

  @override
  String get openCardAction => 'Open card';

  @override
  String get resultKept => 'Kept. It is in your collection.';

  @override
  String get resultNotKept =>
      'Not kept. Open it again if you change your mind.';

  @override
  String get searchAmbient => 'The shelves shift. A lantern blinks twice.';

  @override
  String get saveCardFailed => 'Could not save this card. Please try again.';

  @override
  String get errorDialogue => 'A small shelf-related complication.';

  @override
  String get alternativeErrorDialogue =>
      'That shelf would not give up a second one.';

  @override
  String get alternativeErrorBody =>
      'Your current card is untouched, and nothing was added to your collection.';

  @override
  String get timingEscapePrompt => 'Planning your escape, or already there?';

  @override
  String get visitContextPrompt => 'Anything true I can build on?';

  @override
  String get visitContextNote =>
      'This only shapes the wording. It stays on this device, and you can skip it.';

  @override
  String get visitContextChildcare => 'Childcare';

  @override
  String get visitContextCaregiving => 'Another caregiving responsibility';

  @override
  String get visitContextCommitment => 'An existing commitment';

  @override
  String get visitContextRest => 'Needing rest';

  @override
  String get visitContextSkip => 'None of these';

  @override
  String get shareAction => 'Share';

  @override
  String get timingRecoverPrompt => 'And when did this go wrong?';

  @override
  String get actionBackOut => 'Back out';

  @override
  String get rarityCommon => 'Common';

  @override
  String get rarityUncommon => 'Uncommon';

  @override
  String get rarityRare => 'Rare';

  @override
  String get familyCapacity => 'Capacity';

  @override
  String get familyCareFamily => 'Care & family';

  @override
  String get familyWorkStudy => 'Work & study';

  @override
  String get familyDailyLogistics => 'Daily logistics';

  @override
  String get familyPlanningFailure => 'Planning failure';

  @override
  String get familyBoundaries => 'Boundaries';

  @override
  String get familyAbsurd => 'A little absurd';

  @override
  String get familyFromTheShop => 'From the shop';

  @override
  String get cardFallbackName => 'A small escape';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileRetryTooltip => 'Retry loading profile';

  @override
  String get profileHeading => 'Optional profile';

  @override
  String get profileNote =>
      'A few broad details can help Wick sort the shelves.\nLeave anything blank. Nothing here proves what happened today.';

  @override
  String get profileAgeTitle => 'Age range';

  @override
  String get profileWorkStudyTitle => 'Work / study status';

  @override
  String get profileOccupationTitle => 'Occupation category';

  @override
  String get profileChildrenTitle => 'Has children';

  @override
  String get profileCaregivingTitle => 'Other caregiving responsibilities';

  @override
  String get profileRelationshipTitle => 'Relationship status';

  @override
  String get profileSaveError => 'Profile was not saved. Try again.';

  @override
  String get profileSaved => 'Profile saved on this device';

  @override
  String get profileSaving => 'Saving…';

  @override
  String get profileSaveAction => 'Save profile';

  @override
  String get profileClearAction => 'Clear profile';

  @override
  String get profileLoadError => 'Could not load your profile.';

  @override
  String get profileCollectionHeading => 'Your collection';

  @override
  String get profileViewCollection => 'View collection';

  @override
  String get profileNoCards =>
      'No cards yet. Keep one from the shop and it will appear here.';

  @override
  String profileCardPreviewSemantics(String name) {
    return 'Collection preview: $name';
  }

  @override
  String get profileNotAnswered => 'Not answered';

  @override
  String get profilePreferNotToSay => 'Prefer not to say';

  @override
  String get profileAgeUnder18 => 'Under 18';

  @override
  String get profileAge18To24 => '18–24';

  @override
  String get profileAge25To34 => '25–34';

  @override
  String get profileAge35To44 => '35–44';

  @override
  String get profileAge45To54 => '45–54';

  @override
  String get profileAge55Plus => '55+';

  @override
  String get profileWorking => 'Working';

  @override
  String get profileStudying => 'Studying';

  @override
  String get profileBoth => 'Both';

  @override
  String get profileNeither => 'Neither';

  @override
  String get profileOccupationHealthcare => 'Healthcare';

  @override
  String get profileOccupationEducation => 'Education';

  @override
  String get profileOccupationOffice => 'Office';

  @override
  String get profileOccupationService => 'Service / hospitality';

  @override
  String get profileOccupationCreative => 'Creative';

  @override
  String get profileOccupationTechnical => 'Technical';

  @override
  String get profileOccupationTrades => 'Trades';

  @override
  String get profileOccupationSelfEmployed => 'Self-employed';

  @override
  String get profileOccupationRetired => 'Retired';

  @override
  String get profileOccupationOther => 'Other';

  @override
  String get profileYes => 'Yes';

  @override
  String get profileNo => 'No';

  @override
  String get profileSingle => 'Single';

  @override
  String get profileInRelationship => 'In a relationship';

  @override
  String get profileMarried => 'Married';
}
