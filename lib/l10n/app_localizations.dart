import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The application title shown in the system.
  ///
  /// In en, this message translates to:
  /// **'Excuse Me'**
  String get appTitle;

  /// Step counter shown during the wizard flow.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepIndicator(int current, int total);

  /// Question for the timing shop dialogue beat.
  ///
  /// In en, this message translates to:
  /// **'When\'s the reckoning?'**
  String get dialogueTiming;

  /// Timing choice for a planned-ahead change.
  ///
  /// In en, this message translates to:
  /// **'Planned ahead'**
  String get timingPlannedAhead;

  /// Timing choice for a change happening today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get timingToday;

  /// Timing choice for a last-minute change.
  ///
  /// In en, this message translates to:
  /// **'Last minute'**
  String get timingLastMinute;

  /// Small label for an optional repair direction on a card.
  ///
  /// In en, this message translates to:
  /// **'Repair direction'**
  String get repairDirectionLabel;

  /// Non-sendable placeholder copy for the optional repair direction.
  ///
  /// In en, this message translates to:
  /// **'A small repair direction is available for you to phrase in your own words.'**
  String get repairDirectionPending;

  /// Label for the copy button.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyButton;

  /// Label for the share button.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareButton;

  /// SnackBar text after copying the idea.
  ///
  /// In en, this message translates to:
  /// **'Idea copied.'**
  String get ideaCopied;

  /// Inline error message when generation fails.
  ///
  /// In en, this message translates to:
  /// **'Unable to generate an idea. Please try again.'**
  String get generationError;

  /// Inline body copy when generation fails, before the retry action.
  ///
  /// In en, this message translates to:
  /// **'Nothing came off the shelf this time. Your answers are still here.'**
  String get generationErrorBody;

  /// Action that retries generation with the same answers.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get generationRetry;

  /// App bar title for the profile screen.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Tooltip for retrying a failed profile load.
  ///
  /// In en, this message translates to:
  /// **'Retry loading profile'**
  String get profileRetryTooltip;

  /// Heading above the optional profile fields.
  ///
  /// In en, this message translates to:
  /// **'Optional profile'**
  String get profileHeading;

  /// Explains why the profile is asked for and that it is optional.
  ///
  /// In en, this message translates to:
  /// **'A few broad details can help Excusee sort the shelves.\nLeave anything blank. Nothing here proves what happened today.'**
  String get profileNote;

  /// Label for the age range field.
  ///
  /// In en, this message translates to:
  /// **'Age range'**
  String get profileAgeTitle;

  /// Label for the work or study status field.
  ///
  /// In en, this message translates to:
  /// **'Work / study status'**
  String get profileWorkStudyTitle;

  /// Label for the occupation category field.
  ///
  /// In en, this message translates to:
  /// **'Occupation category'**
  String get profileOccupationTitle;

  /// Label for the has-children field.
  ///
  /// In en, this message translates to:
  /// **'Has children'**
  String get profileChildrenTitle;

  /// Label for the caregiving field.
  ///
  /// In en, this message translates to:
  /// **'Other caregiving responsibilities'**
  String get profileCaregivingTitle;

  /// Label for the relationship status field.
  ///
  /// In en, this message translates to:
  /// **'Relationship status'**
  String get profileRelationshipTitle;

  /// Message when saving the profile fails.
  ///
  /// In en, this message translates to:
  /// **'Profile was not saved. Try again.'**
  String get profileSaveError;

  /// Confirmation that the profile was stored locally.
  ///
  /// In en, this message translates to:
  /// **'Profile saved on this device'**
  String get profileSaved;

  /// Save button label while the profile is being saved.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get profileSaving;

  /// Action that saves the profile.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get profileSaveAction;

  /// Action that clears every profile answer.
  ///
  /// In en, this message translates to:
  /// **'Clear profile'**
  String get profileClearAction;

  /// Message when the profile fails to load.
  ///
  /// In en, this message translates to:
  /// **'Could not load your profile.'**
  String get profileLoadError;

  /// Heading above the collection preview on the profile screen.
  ///
  /// In en, this message translates to:
  /// **'Your collection'**
  String get profileCollectionHeading;

  /// Action that opens the collection from the profile screen.
  ///
  /// In en, this message translates to:
  /// **'View collection'**
  String get profileViewCollection;

  /// Empty state for the profile collection preview.
  ///
  /// In en, this message translates to:
  /// **'No cards yet. Keep one from the shop and it will appear here.'**
  String get profileNoCards;

  /// Semantics label for a card in the profile preview.
  ///
  /// In en, this message translates to:
  /// **'Collection preview: {name}'**
  String profileCardPreviewSemantics(String name);

  /// Chip shown when a profile field has no answer.
  ///
  /// In en, this message translates to:
  /// **'Not answered'**
  String get profileNotAnswered;

  /// Answer declining to give a profile detail.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get profilePreferNotToSay;

  /// Age range answer.
  ///
  /// In en, this message translates to:
  /// **'Under 18'**
  String get profileAgeUnder18;

  /// Age range answer.
  ///
  /// In en, this message translates to:
  /// **'18–24'**
  String get profileAge18To24;

  /// Age range answer.
  ///
  /// In en, this message translates to:
  /// **'25–34'**
  String get profileAge25To34;

  /// Age range answer.
  ///
  /// In en, this message translates to:
  /// **'35–44'**
  String get profileAge35To44;

  /// Age range answer.
  ///
  /// In en, this message translates to:
  /// **'45–54'**
  String get profileAge45To54;

  /// Age range answer.
  ///
  /// In en, this message translates to:
  /// **'55+'**
  String get profileAge55Plus;

  /// Work or study answer.
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get profileWorking;

  /// Work or study answer.
  ///
  /// In en, this message translates to:
  /// **'Studying'**
  String get profileStudying;

  /// Work or study answer.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get profileBoth;

  /// Work or study answer.
  ///
  /// In en, this message translates to:
  /// **'Neither'**
  String get profileNeither;

  /// Occupation answer.
  ///
  /// In en, this message translates to:
  /// **'Healthcare'**
  String get profileOccupationHealthcare;

  /// Occupation answer.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get profileOccupationEducation;

  /// Occupation answer.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get profileOccupationOffice;

  /// Occupation answer.
  ///
  /// In en, this message translates to:
  /// **'Service / hospitality'**
  String get profileOccupationService;

  /// Occupation answer.
  ///
  /// In en, this message translates to:
  /// **'Creative'**
  String get profileOccupationCreative;

  /// Occupation answer.
  ///
  /// In en, this message translates to:
  /// **'Technical'**
  String get profileOccupationTechnical;

  /// Occupation answer.
  ///
  /// In en, this message translates to:
  /// **'Trades'**
  String get profileOccupationTrades;

  /// Occupation answer.
  ///
  /// In en, this message translates to:
  /// **'Self-employed'**
  String get profileOccupationSelfEmployed;

  /// Occupation answer.
  ///
  /// In en, this message translates to:
  /// **'Retired'**
  String get profileOccupationRetired;

  /// Occupation answer.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get profileOccupationOther;

  /// Yes answer.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get profileYes;

  /// No answer.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get profileNo;

  /// Relationship status answer.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get profileSingle;

  /// Relationship status answer.
  ///
  /// In en, this message translates to:
  /// **'In a relationship'**
  String get profileInRelationship;

  /// Relationship status answer.
  ///
  /// In en, this message translates to:
  /// **'Married'**
  String get profileMarried;

  /// Rarity shown on a common card.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get rarityCommon;

  /// Rarity shown on an uncommon card.
  ///
  /// In en, this message translates to:
  /// **'Uncommon'**
  String get rarityUncommon;

  /// Rarity shown on a rare card.
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get rarityRare;

  /// Card family label for capacity and wellbeing.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get familyCapacity;

  /// Card family label for care and family.
  ///
  /// In en, this message translates to:
  /// **'Care & family'**
  String get familyCareFamily;

  /// Card family label for work and study.
  ///
  /// In en, this message translates to:
  /// **'Work & study'**
  String get familyWorkStudy;

  /// Card family label for money and logistics.
  ///
  /// In en, this message translates to:
  /// **'Daily logistics'**
  String get familyDailyLogistics;

  /// Card family label for planning failures.
  ///
  /// In en, this message translates to:
  /// **'Planning failure'**
  String get familyPlanningFailure;

  /// Card family label for boundaries and preferences.
  ///
  /// In en, this message translates to:
  /// **'Boundaries'**
  String get familyBoundaries;

  /// Card family label for absurd or dramatic cards.
  ///
  /// In en, this message translates to:
  /// **'A little absurd'**
  String get familyAbsurd;

  /// Card family label when no family is known.
  ///
  /// In en, this message translates to:
  /// **'From the shop'**
  String get familyFromTheShop;

  /// Card title when the card has no playful name.
  ///
  /// In en, this message translates to:
  /// **'A small escape'**
  String get cardFallbackName;

  /// Action that shares the current card.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareAction;

  /// Timing question when recovering from something that already happened.
  ///
  /// In en, this message translates to:
  /// **'And when did this go wrong?'**
  String get timingRecoverPrompt;

  /// Action choice for backing out of a commitment.
  ///
  /// In en, this message translates to:
  /// **'Back out'**
  String get actionBackOut;

  /// The shopkeeper’s name, shown above their dialogue.
  ///
  /// In en, this message translates to:
  /// **'Excusee'**
  String get shopkeeperName;

  /// Action that returns to the previous question.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backAction;

  /// Action that abandons the current answers and returns to the entry.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get startOverAction;

  /// Action that reopens the current card full screen.
  ///
  /// In en, this message translates to:
  /// **'Open card'**
  String get openCardAction;

  /// Status line on the result once the card has been kept.
  ///
  /// In en, this message translates to:
  /// **'Kept. It is in your collection.'**
  String get resultKept;

  /// Status line on the result before the card has been kept.
  ///
  /// In en, this message translates to:
  /// **'Not kept. Open it again if you change your mind.'**
  String get resultNotKept;

  /// Flavour line shown while a card is being found.
  ///
  /// In en, this message translates to:
  /// **'The shelves shift. A lantern blinks twice.'**
  String get searchAmbient;

  /// Message when saving a card to the collection fails.
  ///
  /// In en, this message translates to:
  /// **'Could not save this card. Please try again.'**
  String get saveCardFailed;

  /// Shopkeeper line when generation fails.
  ///
  /// In en, this message translates to:
  /// **'A small shelf-related complication.'**
  String get errorDialogue;

  /// Shopkeeper line when a second card cannot be found.
  ///
  /// In en, this message translates to:
  /// **'That shelf would not give up a second one.'**
  String get alternativeErrorDialogue;

  /// Body copy when an alternative card cannot be found.
  ///
  /// In en, this message translates to:
  /// **'Your current card is untouched, and nothing was added to your collection.'**
  String get alternativeErrorBody;

  /// Timing question when the user means to leave early.
  ///
  /// In en, this message translates to:
  /// **'Planning your escape, or already there?'**
  String get timingEscapePrompt;

  /// Question asking whether a real responsibility applies today.
  ///
  /// In en, this message translates to:
  /// **'Anything true I can build on?'**
  String get visitContextPrompt;

  /// Explains why the visit-context question is asked and that it is optional.
  ///
  /// In en, this message translates to:
  /// **'This only shapes the wording. It stays on this device, and you can skip it.'**
  String get visitContextNote;

  /// Visit-context answer for looking after children.
  ///
  /// In en, this message translates to:
  /// **'Childcare'**
  String get visitContextChildcare;

  /// Visit-context answer for other caregiving.
  ///
  /// In en, this message translates to:
  /// **'Another caregiving responsibility'**
  String get visitContextCaregiving;

  /// Visit-context answer for a commitment already in place.
  ///
  /// In en, this message translates to:
  /// **'An existing commitment'**
  String get visitContextCommitment;

  /// Visit-context answer for needing rest.
  ///
  /// In en, this message translates to:
  /// **'Needing rest'**
  String get visitContextRest;

  /// Visit-context answer declining to say.
  ///
  /// In en, this message translates to:
  /// **'None of these'**
  String get visitContextSkip;

  /// App bar title for a freshly revealed card.
  ///
  /// In en, this message translates to:
  /// **'Your card'**
  String get cardViewerRevealTitle;

  /// App bar title when viewing a card from the collection.
  ///
  /// In en, this message translates to:
  /// **'Saved card'**
  String get cardViewerSavedTitle;

  /// Action that closes the card viewer.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeAction;

  /// Tooltip for the share control on a card.
  ///
  /// In en, this message translates to:
  /// **'Share card'**
  String get shareCardTooltip;

  /// Tooltip for the copy control on a card.
  ///
  /// In en, this message translates to:
  /// **'Copy idea'**
  String get copyIdeaTooltip;

  /// Keep button label while the card is being saved.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get savingCard;

  /// Keep button label once the card is in the collection.
  ///
  /// In en, this message translates to:
  /// **'Saved to collection'**
  String get cardSavedToCollection;

  /// Action that asks for a different card from the same answers.
  ///
  /// In en, this message translates to:
  /// **'Another one'**
  String get anotherOneAction;

  /// Action that closes a card the user has kept.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneAction;

  /// Action that closes a card the user has not kept.
  ///
  /// In en, this message translates to:
  /// **'Not this one'**
  String get notThisOneAction;

  /// Message when no share handler is wired up.
  ///
  /// In en, this message translates to:
  /// **'Sharing is not available here.'**
  String get shareUnavailable;

  /// Message when sharing fails.
  ///
  /// In en, this message translates to:
  /// **'Could not share this card. Try again.'**
  String get shareFailed;

  /// Collection app bar title with the number of cards.
  ///
  /// In en, this message translates to:
  /// **'Collection · {count}'**
  String collectionTitle(String count);

  /// Heading when no cards have been kept yet.
  ///
  /// In en, this message translates to:
  /// **'Your collection is empty.'**
  String get collectionEmptyTitle;

  /// Explanation of how cards reach the collection.
  ///
  /// In en, this message translates to:
  /// **'Choose “Keep card” when you find one you like.\nYour cards stay on this device.'**
  String get collectionEmptyBody;

  /// Message when the collection fails to load.
  ///
  /// In en, this message translates to:
  /// **'Could not load your collection.'**
  String get collectionLoadError;

  /// Action that retries a failed load.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryAction;

  /// Semantics label for a card on the collection shelf.
  ///
  /// In en, this message translates to:
  /// **'{name} collection card'**
  String collectionCardSemantics(String name);

  /// Direct primary action that enters the shop conversation.
  ///
  /// In en, this message translates to:
  /// **'I need an excuse'**
  String get entryCta;

  /// Question for the intent beat.
  ///
  /// In en, this message translates to:
  /// **'Now then... what\'s the situation?'**
  String get dialogueIntent;

  /// Question for actions after needing out.
  ///
  /// In en, this message translates to:
  /// **'Ah. An escape. What\'s the plan?'**
  String get dialogueActionOut;

  /// Question for actions after needing more time.
  ///
  /// In en, this message translates to:
  /// **'Patience is a resource. What do you need?'**
  String get dialogueActionTime;

  /// Question for actions after a missed situation.
  ///
  /// In en, this message translates to:
  /// **'The ledger remembers. What needs explaining?'**
  String get dialogueActionRecover;

  /// Question for the context beat.
  ///
  /// In en, this message translates to:
  /// **'Where is this trouble taking place?'**
  String get dialogueContext;

  /// Question for the v6 timing beat.
  ///
  /// In en, this message translates to:
  /// **'When does the clock start complaining?'**
  String get dialogueTimingV6;

  /// Question for the relationship beat.
  ///
  /// In en, this message translates to:
  /// **'Who is waiting for an answer?'**
  String get dialogueRelationshipV6;

  /// Question for the obligation beat.
  ///
  /// In en, this message translates to:
  /// **'How much does this one matter?'**
  String get dialogueObligationV6;

  /// Shopkeeper line during deterministic card search.
  ///
  /// In en, this message translates to:
  /// **'Let me look through the shelves.'**
  String get searchDialogue;

  /// Shopkeeper line when handing over a card.
  ///
  /// In en, this message translates to:
  /// **'There. This one should do.'**
  String get handoverDialogue;

  /// Intent choice: get out of plans.
  ///
  /// In en, this message translates to:
  /// **'I need out'**
  String get intentNeedOut;

  /// Intent choice: buy time.
  ///
  /// In en, this message translates to:
  /// **'I need more time'**
  String get intentNeedMoreTime;

  /// Intent choice: recover from a situation.
  ///
  /// In en, this message translates to:
  /// **'I already messed up'**
  String get intentAlreadyMessedUp;

  /// Action choice for getting out of plans.
  ///
  /// In en, this message translates to:
  /// **'Cancel something'**
  String get actionCancelSomething;

  /// Action choice for declining a plan.
  ///
  /// In en, this message translates to:
  /// **'Say no'**
  String get actionSayNo;

  /// Action choice for leaving a commitment early.
  ///
  /// In en, this message translates to:
  /// **'Leave early'**
  String get actionLeaveEarly;

  /// Action choice for buying time.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get actionReschedule;

  /// Action choice for delaying a commitment.
  ///
  /// In en, this message translates to:
  /// **'Delay the answer'**
  String get actionDelay;

  /// Action choice for avoiding a commitment.
  ///
  /// In en, this message translates to:
  /// **'Avoid committing'**
  String get actionAvoidCommitting;

  /// Action choice for explaining a late situation.
  ///
  /// In en, this message translates to:
  /// **'Explain what happened'**
  String get actionExplainWhatHappened;

  /// Action choice for asking for more time after a miss.
  ///
  /// In en, this message translates to:
  /// **'Ask for more time'**
  String get actionAskMoreTime;

  /// Action choice for acknowledging a missed commitment.
  ///
  /// In en, this message translates to:
  /// **'Acknowledge the miss'**
  String get actionAcknowledgeMiss;

  /// Broad context choice for social situations.
  ///
  /// In en, this message translates to:
  /// **'Social plans'**
  String get contextSocial;

  /// Broad context choice for personal situations.
  ///
  /// In en, this message translates to:
  /// **'Personal life'**
  String get contextPersonal;

  /// Broad context choice for work or study.
  ///
  /// In en, this message translates to:
  /// **'Work or study'**
  String get contextWorkStudy;

  /// Broad context choice for practical situations.
  ///
  /// In en, this message translates to:
  /// **'A practical thing'**
  String get contextPractical;

  /// Timing choice for something happening now.
  ///
  /// In en, this message translates to:
  /// **'Happening now'**
  String get timingHappeningNow;

  /// Relationship choice for someone close.
  ///
  /// In en, this message translates to:
  /// **'Someone close'**
  String get relationshipClose;

  /// Relationship choice for a casual connection.
  ///
  /// In en, this message translates to:
  /// **'Someone I know'**
  String get relationshipCasual;

  /// Relationship choice for a formal connection.
  ///
  /// In en, this message translates to:
  /// **'Someone formal'**
  String get relationshipFormal;

  /// Obligation choice for low stakes.
  ///
  /// In en, this message translates to:
  /// **'Low stakes'**
  String get obligationLow;

  /// Obligation choice for medium stakes.
  ///
  /// In en, this message translates to:
  /// **'Somewhat important'**
  String get obligationMedium;

  /// Obligation choice for high stakes.
  ///
  /// In en, this message translates to:
  /// **'High stakes'**
  String get obligationHigh;

  /// Semantics label for a tappable answer in the trail of given answers.
  ///
  /// In en, this message translates to:
  /// **'Change this answer: {option}'**
  String changeAnswerSemantics(String option);

  /// Semantics label for an intent choice.
  ///
  /// In en, this message translates to:
  /// **'Choose intent: {option}'**
  String chooseIntent(String option);

  /// Semantics label for an action choice.
  ///
  /// In en, this message translates to:
  /// **'Choose action: {option}'**
  String chooseAction(String option);

  /// Semantics label for a context choice.
  ///
  /// In en, this message translates to:
  /// **'Choose context: {option}'**
  String chooseContext(String option);

  /// Semantics label for a v6 relationship choice.
  ///
  /// In en, this message translates to:
  /// **'Choose relationship: {option}'**
  String chooseRelationshipV6(String option);

  /// Semantics label for an obligation choice.
  ///
  /// In en, this message translates to:
  /// **'Choose obligation: {option}'**
  String chooseObligation(String option);

  /// Accessibility label for the search choreography.
  ///
  /// In en, this message translates to:
  /// **'Excusee is searching the shop'**
  String get searchingLabel;

  /// Label above the atomic idea on the card.
  ///
  /// In en, this message translates to:
  /// **'The idea'**
  String get cardIdeaLabel;

  /// Temporary local keep action without persistence.
  ///
  /// In en, this message translates to:
  /// **'Keep card'**
  String get keepCardButton;

  /// Semantics label describing the current local outfit palette.
  ///
  /// In en, this message translates to:
  /// **'Excusee outfit: {palette}'**
  String outfitSemantics(String palette);

  /// Semantics label for the ambient shop event.
  ///
  /// In en, this message translates to:
  /// **'Shop event: {event}'**
  String ambientEventSemantics(String event);

  /// AppBar title for the legacy form page.
  ///
  /// In en, this message translates to:
  /// **'Excuse Me'**
  String get oldFormTitle;

  /// Heading on the legacy form page.
  ///
  /// In en, this message translates to:
  /// **'Find a way to explain it.'**
  String get oldFormHeading;

  /// Subheading on the legacy form page.
  ///
  /// In en, this message translates to:
  /// **'Get one private, adaptable idea - never a message to send.'**
  String get oldFormSubheading;

  /// Label for the situation text field.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get oldFormSituationLabel;

  /// Hint text for the situation text field.
  ///
  /// In en, this message translates to:
  /// **'Describe the situation'**
  String get oldFormSituationHint;

  /// Label for the relationship dropdown.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get oldFormRelationshipLabel;

  /// Label for the urgency dropdown.
  ///
  /// In en, this message translates to:
  /// **'Urgency'**
  String get oldFormUrgencyLabel;

  /// Label for the tone dropdown.
  ///
  /// In en, this message translates to:
  /// **'Tone'**
  String get oldFormToneLabel;

  /// Relationship option: friend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get oldFormFriend;

  /// Relationship option: family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get oldFormFamily;

  /// Relationship option: coworker.
  ///
  /// In en, this message translates to:
  /// **'Coworker'**
  String get oldFormCoworker;

  /// Relationship option: client.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get oldFormClient;

  /// Urgency option: soon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get oldFormSoon;

  /// Urgency option: today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get oldFormToday;

  /// Urgency option: this week.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get oldFormThisWeek;

  /// Tone option: warm.
  ///
  /// In en, this message translates to:
  /// **'Warm'**
  String get oldFormToneWarm;

  /// Tone option: direct.
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get oldFormToneDirect;

  /// Tone option: professional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get oldFormToneProfessional;

  /// Label for the generate button on the legacy form.
  ///
  /// In en, this message translates to:
  /// **'Generate idea'**
  String get oldFormGenerateButton;

  /// Label for the regenerate button on the legacy form.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get oldFormRegenerateButton;

  /// Title above the result card on the legacy form.
  ///
  /// In en, this message translates to:
  /// **'Your idea'**
  String get oldFormResultTitle;

  /// Error when the situation field is empty.
  ///
  /// In en, this message translates to:
  /// **'Describe the situation before generating an idea.'**
  String get oldFormEmptyError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
