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
  String get debugHotspotsTooltip => 'Show hotspots';
}
