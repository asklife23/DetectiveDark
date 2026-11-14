// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DetectiveDark';

  @override
  String get backTooltip => 'Back';

  @override
  String get closeTooltip => 'Close';

  @override
  String get exitHint => 'Press back again to leave the game.';

  @override
  String get gameLoadFailed => 'The case files could not be opened.';

  @override
  String get retryButton => 'Try again';

  @override
  String get inventoryLabel => 'Inventory';

  @override
  String get inventoryEmpty => 'Nothing yet';

  @override
  String get notebookTooltip => 'Notebook';

  @override
  String get notebookTabDocuments => 'Documents';

  @override
  String get notebookTabObservations => 'Observations';

  @override
  String get notebookTabPeople => 'People';

  @override
  String get notebookEmptyDocuments =>
      'No papers yet. Somebody always leaves something behind.';

  @override
  String get notebookEmptyObservations =>
      'Nothing worth writing down. Not yet.';

  @override
  String get notebookEmptyPeople => 'No names. Only shadows, so far.';

  @override
  String get notebookSelectHint => 'Pick a note to read it.';

  @override
  String get dialogueTopicNew => 'new';

  @override
  String get dialogueTopicAsked => 'asked';

  @override
  String get dialogueContinueHint => 'Tap to continue';

  @override
  String get dialogueNoTopics => 'Nothing to ask. Not yet.';

  @override
  String get chatTooltip => 'Thoughts';

  @override
  String get chatHistoryEmpty => 'Nothing on my mind yet.';

  @override
  String get debugHotspotsTooltip => 'Show hotspots';
}
