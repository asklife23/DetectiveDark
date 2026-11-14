// Developer tool, not part of the test suite (it lives outside `test/`).
//
// Plays a few steps of the game on the real game screen and saves what the
// player sees as PNG files in `build/screenshots/`:
//
//   flutter test tool/render_screenshots_test.dart
//
// The README shows JPEG copies from `docs/screenshots/` (film grain makes
// PNG files of these pictures over a megabyte each).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:detective_dark/app/game/game_screen.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_theme.dart';
import 'package:detective_dark/features/dialogue/presentation/widgets/dialogue_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../test/helpers/game_app.dart';

const _outputDir = 'build/screenshots';

/// Logical size of the pictures and how many pixels each logical pixel gets.
const _size = Size(960, 432);
const _pixelRatio = 1.25;

Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final file in files) {
    final bytes = await File(file).readAsBytes();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

void main() {
  setUp(setUpGameDependencies);
  tearDown(GetIt.instance.reset);

  testWidgets('render README screenshots', (tester) async {
    final l10n = lookupAppLocalizations(const Locale('en'));
    final flutterRoot = Platform.environment['FLUTTER_ROOT'];

    await tester.runAsync(() async {
      await _loadFont('CourierPrime', [
        'assets/fonts/courier_prime/CourierPrime-Regular.ttf',
        'assets/fonts/courier_prime/CourierPrime-Bold.ttf',
      ]);
      await _loadFont('IBMPlexSans', [
        'assets/fonts/ibm_plex_sans/IBMPlexSans-Regular.ttf',
        'assets/fonts/ibm_plex_sans/IBMPlexSans-Medium.ttf',
        'assets/fonts/ibm_plex_sans/IBMPlexSans-Bold.ttf',
      ]);
      const iconFont =
          'bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf';
      await _loadFont('MaterialIcons', ['$flutterRoot/$iconFont']);
    });

    tester.view
      ..physicalSize = _size * _pixelRatio
      ..devicePixelRatio = _pixelRatio;
    addTearDown(tester.view.reset);
    Directory(_outputDir).createSync(recursive: true);

    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundaryKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const GameScreen(),
        ),
      ),
    );

    Future<void> save(String name) => tester.runAsync(() async {
      final boundary =
          boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: _pixelRatio);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$_outputDir/$name.png').writeAsBytesSync(
        bytes!.buffer.asUint8List(),
      );
    });

    // The first scene, while the detective comments on it.
    await tester.pumpFor(const Duration(seconds: 3));
    await save('01_villa');

    // The statue up close: the key glimmers behind its ear.
    await tester.tapHotspot('Garden statue');
    await tester.pumpFor(const Duration(milliseconds: 1500));
    await save('02_statue_key');

    // The plaque in the inspection panel, with the inscription drawn by
    // the game.
    await tester.tapHotspot('Plaque on the pedestal');
    await save('03_inspection');
    await tester.tap(find.byTooltip(l10n.backTooltip));
    await tester.pumpFor();

    // Key taken and selected, in front of the locked door.
    await tester.tapHotspot("Something behind the statue's ear");
    await tester.pumpFor(const Duration(seconds: 1));
    await tester.tap(find.byTooltip(l10n.backTooltip));
    await tester.pumpFor();
    await tester.tapHotspot('Front door');
    await tester.tap(find.bySemanticsLabel('Brass key'));
    await tester.pumpFor();
    await save('04_door_with_key');

    // The letter from the hall, read in the notebook.
    await tester.tapHotspot('Door lock');
    await tester.tapHotspot('Open doorway');
    await tester.tapHotspot('Sheet of paper on the desk');
    await tester.pumpFor(const Duration(seconds: 1));
    await tester.tap(find.byTooltip(l10n.notebookTooltip));
    await tester.pumpFor();
    await tester.tap(find.text('Unsigned letter'));
    await tester.pumpFor();
    await save('05_notebook');

    // On to the market square: the bottle from the desk, then the signpost
    // that appeared in front of the villa.
    await tester.tap(find.byTooltip(l10n.closeTooltip));
    await tester.pumpFor();
    await tester.tapHotspot('Small bottle on the desk');
    await tester.pumpFor(const Duration(seconds: 1));
    await tester.tap(find.byTooltip(l10n.backTooltip));
    await tester.pumpFor();
    await tester.tap(find.byTooltip(l10n.backTooltip));
    await tester.pumpFor();
    await tester.tapHotspot('Signpost to the market');
    await tester.pumpFor(const Duration(seconds: 3));
    await save('06_market');

    // The pharmacist speaks; then the questions.
    final panel = find.byType(DialoguePanel);
    await tester.tapHotspot('Figure at the pharmacy window');
    await tester.pumpFor(const Duration(seconds: 2));
    await save('07_dialogue_line');
    await tester.tapAt(tester.getCenter(panel));
    await tester.pumpFor();
    await save('08_dialogue_questions');

    await tester.closeGame();
  });
}
