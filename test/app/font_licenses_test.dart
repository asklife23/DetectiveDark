import 'package:detective_dark/app/font_licenses.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(LicenseRegistry.reset);

  test('registers the OFL text of every bundled font', () async {
    registerFontLicenses();

    final entries = await LicenseRegistry.licenses.toList();
    final packages = entries.expand((e) => e.packages).toSet();
    expect(packages, containsAll(fontLicenses.keys));

    for (final entry in entries) {
      final text = entry.paragraphs.map((p) => p.text).join('\n');
      expect(text, contains('SIL OPEN FONT LICENSE Version 1.1'));
    }
  });
}
