import 'dart:io';

import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_paths.dart';
import 'package:detective_dark/core/content/content_texts.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/placeholders/placeholder_styles.dart';
import 'package:detective_dark/core/theme/noir_filter_presets.dart';
import 'package:detective_dark/core/theme/overlay_text_styles.dart';
import 'package:detective_dark/core/theme/scene_layout.dart';
import 'package:detective_dark/features/inventory/data/repositories/asset_item_catalog_repository.dart';
import 'package:detective_dark/features/notebook/data/repositories/asset_note_catalog_repository.dart';
import 'package:detective_dark/features/scene_engine/data/repositories/asset_scene_content_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/case_content.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/hotspot_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/services/content_validator.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/content_folders.dart';
import '../helpers/content_validation.dart';

/// The content safety net (CLAUDE.md section 9): loads the REAL game
/// content from the asset bundle and runs every consistency check on it.
///
/// If this test fails, the message says which scene, hotspot or text is
/// wrong. Fix the JSON, not the test.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const caseId = ContentPaths.defaultCaseId;
  final source = ContentAssetSource(rootBundle);
  final styles = KnownStyleNames(
    overlayStyles: OverlayTextStyles.names,
    filterPresets: NoirFilterPresets.names,
    placeholderStyles: PlaceholderStyles.names,
  );

  /// Loads the first [chapterLimit] chapters (all when null) and validates
  /// them; [change] may break the scenes first, to prove that the checks
  /// really fire on the real content.
  Future<List<ContentIssue>> validate({
    CaseContent Function(CaseContent content)? change,
    double reservedBottomStrip = SceneLayout.chatStripHeight,
    int? chapterLimit,
    bool reportUnusedTexts = false,
  }) async {
    final loaded = await loadCaseForValidation(
      source,
      caseId,
      chapterLimit: chapterLimit,
    );
    return validateLoadedCase(
      change == null ? loaded : loaded.withContent(change(loaded.content)),
      styles: styles,
      reservedBottomStrip: reservedBottomStrip,
      reportUnusedTexts: reportUnusedTexts,
    );
  }

  test('all content files load without a failure', () async {
    final scenes = await AssetSceneContentRepository(source).loadCase(caseId);
    final items = await AssetItemCatalogRepository(source).loadItems(caseId);
    final notes = await AssetNoteCatalogRepository(source).loadNotes(caseId);

    expect(scenes.failureOrNull, isNull);
    expect(items.failureOrNull, isNull);
    expect(notes.failureOrNull, isNull);
    expect(scenes.valueOrNull!.scenes, isNotEmpty);
  });

  test('story texts exist for every supported language', () async {
    for (final locale in AppLocalizations.supportedLocales) {
      final texts = await ContentTextLoader(
        source,
      ).load(caseId, locale.languageCode);

      expect(
        texts.failureOrNull,
        isNull,
        reason: 'language ${locale.languageCode}',
      );
    }
  });

  test('the content is consistent', () async {
    final issues = await validate(reportUnusedTexts: true);

    // Warnings do not fail the test, but they are shown on every run:
    // the one place where test output is the point.
    // ignore: avoid_print
    issues.warnings.forEach(print);
    expect(issues.errors, isEmpty, reason: issues.errors.join('\n'));
  });

  test('every chapter prefix is consistent on its own (chapter 1; chapters '
      '1–2; ...): an early chapter never depends on a later one', () async {
    final chapters = await chapterCount(source, caseId);
    expect(chapters, greaterThan(0));

    for (var limit = 1; limit <= chapters; limit++) {
      final errors = (await validate(chapterLimit: limit)).errors;

      expect(
        errors,
        isEmpty,
        reason: 'first $limit chapter(s):\n${errors.join('\n')}',
      );
    }
  });

  test('every folder with content files is declared in pubspec.yaml', () {
    final problems = contentFolderProblems(
      pubspecYaml: File('pubspec.yaml').readAsStringSync(),
      foldersOnDisk: contentFoldersOnDisk(Directory.current),
    );

    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  group('the checks fire on the real content', () {
    /// Replaces the effects of the first rule of one hotspot.
    CaseContent withEffects(
      CaseContent content,
      String sceneId,
      String hotspotId,
      List<Effect> effects,
    ) {
      final scene = content.scenes[sceneId]!;
      final changed = SceneDefinition(
        id: scene.id,
        parentId: scene.parentId,
        titleKey: scene.titleKey,
        visual: scene.visual,
        visualVariants: scene.visualVariants,
        onFirstEnter: scene.onFirstEnter,
        hotspots: [
          for (final hotspot in scene.hotspots)
            if (hotspot.id == hotspotId)
              HotspotDefinition(
                id: hotspot.id,
                rect: hotspot.rect,
                labelKey: hotspot.labelKey,
                visibleWhen: hotspot.visibleWhen,
                glint: hotspot.glint,
                sprite: hotspot.sprite,
                interactions: [
                  InteractionRule(
                    when: hotspot.interactions.first.when,
                    effects: effects,
                  ),
                  ...hotspot.interactions.skip(1),
                ],
              )
            else
              hotspot,
        ],
      );
      return CaseContent(
        definition: content.definition,
        scenes: {...content.scenes, sceneId: changed},
        inspections: content.inspections,
        sceneChapters: content.sceneChapters,
        triggers: content.triggers,
      );
    }

    test('a broken scene ID is caught', () async {
      final issues = await validate(
        change: (content) => withEffects(
          content,
          'villa_exterior',
          'door',
          const [GoToScene('villa_dor_closeup')],
        ),
      );

      expect(
        issues.map((issue) => '$issue'),
        contains(contains('unknown scene "villa_dor_closeup"')),
      );
    });

    test('a hotspot under the message bar is caught', () async {
      // With a taller bar the front door (bottom edge at 0.84) would lie
      // under it.
      final issues = await validate(reservedBottomStrip: 0.2);

      expect(
        issues.map((issue) => '$issue'),
        contains(
          allOf(
            contains('hotspot door'),
            contains('reaches into the bottom strip'),
          ),
        ),
      );
    });

    test('a misspelled flag is caught', () async {
      final issues = await validate(
        change: (content) => withEffects(
          content,
          'villa_door_closeup',
          'lock',
          const [SetFlag('front_door_opn')],
        ),
      );

      expect(
        issues.map((issue) => '$issue'),
        contains(contains('flag "front_door_open" is read but never set')),
      );
    });
  });
}
