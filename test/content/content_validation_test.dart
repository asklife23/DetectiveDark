import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_paths.dart';
import 'package:detective_dark/core/content/content_texts.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/placeholders/placeholder_styles.dart';
import 'package:detective_dark/core/theme/noir_filter_presets.dart';
import 'package:detective_dark/core/theme/overlay_text_styles.dart';
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

  /// Loads everything and validates it; [change] may break the scenes
  /// first, to prove that the checks really fire on the real content.
  Future<List<ContentIssue>> validate({
    CaseContent Function(CaseContent content)? change,
  }) async {
    final content = (await AssetSceneContentRepository(
      source,
    ).loadCase(caseId)).valueOrNull!;
    final items = (await AssetItemCatalogRepository(
      source,
    ).loadItems(caseId)).valueOrNull!;
    final notes = (await AssetNoteCatalogRepository(
      source,
    ).loadNotes(caseId)).valueOrNull!;

    final textKeys = <String, Set<String>>{};
    for (final locale in AppLocalizations.supportedLocales) {
      final texts = await ContentTextLoader(
        source,
      ).load(caseId, locale.languageCode);
      textKeys[locale.languageCode] = texts.valueOrNull!.keys.toSet();
    }

    return const ContentValidator().validate(
      content: change == null ? content : change(content),
      items: items,
      notes: notes,
      textKeysByLanguage: textKeys,
      styles: styles,
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
    final issues = await validate();

    expect(issues, isEmpty, reason: issues.join('\n'));
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
