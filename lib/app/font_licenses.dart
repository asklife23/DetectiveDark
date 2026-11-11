import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Bundled fonts and their license files (SIL Open Font License 1.1).
const fontLicenses = {
  'Courier Prime': 'assets/fonts/courier_prime/OFL.txt',
  'IBM Plex Sans': 'assets/fonts/ibm_plex_sans/OFL.txt',
};

/// Adds the font licenses to Flutter's license registry, so they appear on
/// the license page next to the package licenses. The OFL requires the
/// license to travel with the font.
///
/// The texts load lazily: only when the license page is opened.
void registerFontLicenses({AssetBundle? bundle}) {
  LicenseRegistry.addLicense(() async* {
    final assets = bundle ?? rootBundle;
    for (final MapEntry(key: font, value: path) in fontLicenses.entries) {
      yield LicenseEntryWithLineBreaks([font], await assets.loadString(path));
    }
  });
}
