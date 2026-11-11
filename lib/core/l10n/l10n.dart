import 'package:detective_dark/core/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

export 'package:detective_dark/core/l10n/generated/app_localizations.dart';

/// Short access to the UI texts: `context.l10n.appTitle`.
///
/// The supported languages are `AppLocalizations.supportedLocales`, generated
/// from the ARB files in `arb/`. It is the only language list in the code.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
