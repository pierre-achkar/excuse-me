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

  /// AppBar title for the Excuse Shop screen.
  ///
  /// In en, this message translates to:
  /// **'The Excuse Shop'**
  String get shopTitle;

  /// Semantics label for the shopkeeper avatar image.
  ///
  /// In en, this message translates to:
  /// **'Pixel art shopkeeper'**
  String get shopkeeperAvatarLabel;

  /// Header description below the shopkeeper avatar.
  ///
  /// In en, this message translates to:
  /// **'A friendly shopkeeper helps you craft the perfect excuse.'**
  String get shopHeaderDescription;

  /// Step counter shown during the wizard flow.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepIndicator(int current, int total);

  /// Shopkeeper speech bubble on the mission step.
  ///
  /// In en, this message translates to:
  /// **'Welcome! Tell me what you need and I will help you out.'**
  String get shopkeeperWelcome;

  /// Shopkeeper speech bubble on the situation step.
  ///
  /// In en, this message translates to:
  /// **'Great choice. Now pick a situation that fits.'**
  String get shopkeeperSituation;

  /// Shopkeeper speech bubble on the tone step.
  ///
  /// In en, this message translates to:
  /// **'Almost there. Pick your ingredient for the tone.'**
  String get shopkeeperTone;

  /// Prefix for the shopkeeper speech bubble semantics label.
  ///
  /// In en, this message translates to:
  /// **'Shopkeeper says:'**
  String get shopkeeperSays;

  /// Section title above situation choice cards.
  ///
  /// In en, this message translates to:
  /// **'Choose a situation'**
  String get situationSectionTitle;

  /// Section title above tone choice cards.
  ///
  /// In en, this message translates to:
  /// **'Choose your ingredient'**
  String get toneSectionTitle;

  /// Label for the 'get out of plans' mission.
  ///
  /// In en, this message translates to:
  /// **'Get out of plans'**
  String get missionGetOutOfPlans;

  /// Label for the 'buy time' mission.
  ///
  /// In en, this message translates to:
  /// **'Buy time'**
  String get missionBuyTime;

  /// Label for the 'recover from a situation' mission.
  ///
  /// In en, this message translates to:
  /// **'Recover from a situation'**
  String get missionRecoverFromSituation;

  /// Situation label for dinner contexts.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get situationDinner;

  /// Situation label for party contexts.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get situationParty;

  /// Situation label for work contexts.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get situationWork;

  /// Situation label for family contexts.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get situationFamily;

  /// Situation label for friend contexts.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get situationFriends;

  /// Situation label for rescheduling contexts.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get situationReschedule;

  /// Situation label for delay contexts.
  ///
  /// In en, this message translates to:
  /// **'Delay'**
  String get situationDelay;

  /// Situation label for lateness contexts.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get situationLate;

  /// Situation label for missed event contexts.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get situationMissed;

  /// Tone label for straightforward tone.
  ///
  /// In en, this message translates to:
  /// **'Straightforward'**
  String get toneStraightforward;

  /// Tone label for warm tone.
  ///
  /// In en, this message translates to:
  /// **'Warm'**
  String get toneWarm;

  /// Tone label for funny tone.
  ///
  /// In en, this message translates to:
  /// **'Funny'**
  String get toneFunny;

  /// Semantics label for mission choice cards.
  ///
  /// In en, this message translates to:
  /// **'Choose mission: {mission}'**
  String chooseMission(String mission);

  /// Semantics label for situation choice cards.
  ///
  /// In en, this message translates to:
  /// **'Choose situation: {situation}'**
  String chooseSituation(String situation);

  /// Semantics label for tone choice cards.
  ///
  /// In en, this message translates to:
  /// **'Choose ingredient: {tone}'**
  String chooseTone(String tone);

  /// Text shown while generating the excuse idea.
  ///
  /// In en, this message translates to:
  /// **'Brewing your excuse...'**
  String get brewingYourExcuse;

  /// Semantics label for the brewing state.
  ///
  /// In en, this message translates to:
  /// **'Brewing your excuse'**
  String get brewingYourExcuseSemantic;

  /// Title above the result card.
  ///
  /// In en, this message translates to:
  /// **'Your excuse'**
  String get resultTitle;

  /// Badge label inside the result card.
  ///
  /// In en, this message translates to:
  /// **'COLLECTIBLE IDEA'**
  String get collectibleIdeaBadge;

  /// Label for the regenerate button.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerateButton;

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

  /// Label for the new excuse button.
  ///
  /// In en, this message translates to:
  /// **'New excuse'**
  String get newExcuseButton;

  /// Semantics label for regenerate button.
  ///
  /// In en, this message translates to:
  /// **'Regenerate excuse'**
  String get regenerateSemantics;

  /// Semantics label for copy button.
  ///
  /// In en, this message translates to:
  /// **'Copy excuse to clipboard'**
  String get copySemantics;

  /// Semantics label for share button.
  ///
  /// In en, this message translates to:
  /// **'Share excuse'**
  String get shareSemantics;

  /// Semantics label for new excuse button.
  ///
  /// In en, this message translates to:
  /// **'Start new excuse'**
  String get newExcuseSemantics;

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
