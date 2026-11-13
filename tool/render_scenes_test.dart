// Developer tool, not part of the test suite (it lives outside `test/`).
//
// Renders every scene and inspection visual of the game content to a PNG in
// `build/scene_previews/`, exactly as the game draws it (picture, overlay
// text, noir filter), with the hotspot rectangles outlined. Use it to check
// art and hotspot placement without starting the app:
//
//   flutter test tool/render_scenes_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_paths.dart';
import 'package:detective_dark/core/content/content_text_scope.dart';
import 'package:detective_dark/core/content/content_texts.dart';
import 'package:detective_dark/core/theme/app_theme.dart';
import 'package:detective_dark/features/scene_engine/data/repositories/asset_scene_content_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/hotspot_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_visual.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/hotspot_layer.dart';
import 'package:detective_dark/features/scene_engine/presentation/widgets/scene_visual_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _width = 1280.0;
const _height = 720.0;
const _outputDir = 'build/scene_previews';

Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final file in files) {
    final bytes = await File(file).readAsBytes();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

void main() {
  testWidgets('render scene previews', (tester) async {
    late final ContentTexts texts;
    late final Map<String, (SceneVisual, List<HotspotDefinition>)> pictures;

    await tester.runAsync(() async {
      await _loadFont('CourierPrime', [
        'assets/fonts/courier_prime/CourierPrime-Regular.ttf',
        'assets/fonts/courier_prime/CourierPrime-Bold.ttf',
      ]);
      await _loadFont('IBMPlexSans', [
        'assets/fonts/ibm_plex_sans/IBMPlexSans-Regular.ttf',
      ]);

      final source = ContentAssetSource(rootBundle);
      const caseId = ContentPaths.defaultCaseId;
      texts = (await ContentTextLoader(source).load(caseId, 'en')).valueOrNull!;
      final content = (await AssetSceneContentRepository(
        source,
      ).loadCase(caseId)).valueOrNull!;

      pictures = {
        for (final scene in content.scenes.values) ...{
          scene.id: (scene.visual, scene.hotspots),
          for (final (index, variant) in scene.visualVariants.indexed)
            '${scene.id}__variant${index + 1}': (
              variant.visual,
              scene.hotspots,
            ),
        },
        for (final inspection in content.inspections.values)
          'inspection_${inspection.id}': (
            inspection.visual,
            const <HotspotDefinition>[],
          ),
      };
    });

    tester.view
      ..physicalSize = const Size(_width, _height)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Directory(_outputDir).createSync(recursive: true);

    for (final MapEntry(key: name, value: (visual, hotspots))
        in pictures.entries) {
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: ContentTextScope(
            texts: texts,
            child: RepaintBoundary(
              key: boundaryKey,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SceneVisualView(visual: visual),
                  HotspotLayer(
                    hotspots: hotspots,
                    showDebug: true,
                    onTap: (_) {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));

      await tester.runAsync(() async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$_outputDir/$name.png').writeAsBytesSync(
          bytes!.buffer.asUint8List(),
        );
      });
    }

    // Unmount, so the repeating hotspot animations stop before the test
    // ends.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
