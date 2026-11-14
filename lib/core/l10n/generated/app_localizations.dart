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
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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

  /// Name of the game. Shown in the OS task switcher, the window title and on screen.
  ///
  /// In en, this message translates to:
  /// **'DetectiveDark'**
  String get appTitle;

  /// Label of the HUD button that returns to the previous scene.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backTooltip;

  /// Label of the button that closes a panel (inspection panel, notebook, message history, dialogue panel).
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeTooltip;

  /// Shown when the player presses the system back button in a main scene. A second press closes the app.
  ///
  /// In en, this message translates to:
  /// **'Press back again to leave the game.'**
  String get exitHint;

  /// Shown instead of the game when the game content failed to load.
  ///
  /// In en, this message translates to:
  /// **'The case files could not be opened.'**
  String get gameLoadFailed;

  /// Button that repeats a failed action, e.g. loading the game content.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retryButton;

  /// Accessibility label of the item panel on the right edge of the screen.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventoryLabel;

  /// Shown in the item panel while the player carries no items. Very little space: keep it to two short words.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet'**
  String get inventoryEmpty;

  /// Label of the HUD button that opens the notebook, and title of the notebook.
  ///
  /// In en, this message translates to:
  /// **'Notebook'**
  String get notebookTooltip;

  /// Notebook tab: letters, clippings, receipts, photos.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get notebookTabDocuments;

  /// Notebook tab: conclusions the detective has drawn.
  ///
  /// In en, this message translates to:
  /// **'Observations'**
  String get notebookTabObservations;

  /// Notebook tab: one file per person the detective has met or heard of. Each file grows line by line as the game goes on.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get notebookTabPeople;

  /// Shown in the Documents tab of the notebook while it is empty. Atmospheric, in the voice of the detective.
  ///
  /// In en, this message translates to:
  /// **'No papers yet. Somebody always leaves something behind.'**
  String get notebookEmptyDocuments;

  /// Shown in the Observations tab of the notebook while it is empty. Atmospheric, in the voice of the detective.
  ///
  /// In en, this message translates to:
  /// **'Nothing worth writing down. Not yet.'**
  String get notebookEmptyObservations;

  /// Shown in the People tab of the notebook while it is empty. Atmospheric, in the voice of the detective.
  ///
  /// In en, this message translates to:
  /// **'No names. Only shadows, so far.'**
  String get notebookEmptyPeople;

  /// Shown on the right page of the notebook while no note is selected.
  ///
  /// In en, this message translates to:
  /// **'Pick a note to read it.'**
  String get notebookSelectHint;

  /// Small tag on a question in the dialogue panel that the player has not asked yet. Very little space: one short word, lower case.
  ///
  /// In en, this message translates to:
  /// **'new'**
  String get dialogueTopicNew;

  /// Accessibility text for a question in the dialogue panel that the player has already asked (shown as a check mark).
  ///
  /// In en, this message translates to:
  /// **'asked'**
  String get dialogueTopicAsked;

  /// Accessibility hint on the line a character is saying in the dialogue panel: a tap shows the next line.
  ///
  /// In en, this message translates to:
  /// **'Tap to continue'**
  String get dialogueContinueHint;

  /// Shown in the dialogue panel when the character has no question on offer. In the voice of the detective.
  ///
  /// In en, this message translates to:
  /// **'Nothing to ask. Not yet.'**
  String get dialogueNoTopics;

  /// Label of the HUD button that opens the history of the detective's inner voice, and title of that history.
  ///
  /// In en, this message translates to:
  /// **'Thoughts'**
  String get chatTooltip;

  /// Shown in the message history while the detective has not said anything. In the voice of the detective.
  ///
  /// In en, this message translates to:
  /// **'Nothing on my mind yet.'**
  String get chatHistoryEmpty;

  /// Developer tool, visible only in dev builds: toggles the outlines of the tappable areas.
  ///
  /// In en, this message translates to:
  /// **'Show hotspots'**
  String get debugHotspotsTooltip;
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
