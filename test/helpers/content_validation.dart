import 'package:detective_dark/core/content/case_manifest.dart';
import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_texts.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/features/dialogue/data/repositories/asset_dialogue_catalog_repository.dart';
import 'package:detective_dark/features/dialogue/domain/entities/dialogue_definition.dart';
import 'package:detective_dark/features/dialogue/domain/services/dialogue_validator.dart';
import 'package:detective_dark/features/inventory/data/repositories/asset_item_catalog_repository.dart';
import 'package:detective_dark/features/inventory/domain/entities/item_definition.dart';
import 'package:detective_dark/features/notebook/data/repositories/asset_note_catalog_repository.dart';
import 'package:detective_dark/features/notebook/domain/entities/note_definition.dart';
import 'package:detective_dark/features/scene_engine/data/models/codec_rule_parser.dart';
import 'package:detective_dark/features/scene_engine/data/repositories/asset_scene_content_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/case_content.dart';
import 'package:detective_dark/features/scene_engine/domain/services/content_checks.dart';
import 'package:detective_dark/features/scene_engine/domain/services/content_validator.dart';

/// Everything of a case that the validators look at.
class LoadedCase {
  const LoadedCase({
    required this.content,
    required this.items,
    required this.notes,
    required this.dialogues,
    required this.textKeysByLanguage,
  });

  final CaseContent content;
  final Map<String, ItemDefinition> items;
  final Map<String, NoteDefinition> notes;
  final Map<String, DialogueDefinition> dialogues;

  /// Language code → the text keys that exist in that language.
  final Map<String, Set<String>> textKeysByLanguage;

  LoadedCase withContent(CaseContent content) => LoadedCase(
    content: content,
    items: items,
    notes: notes,
    dialogues: dialogues,
    textKeysByLanguage: textKeysByLanguage,
  );

  LoadedCase withDialogues(Map<String, DialogueDefinition> dialogues) =>
      LoadedCase(
        content: content,
        items: items,
        notes: notes,
        dialogues: dialogues,
        textKeysByLanguage: textKeysByLanguage,
      );
}

/// How many chapters of [caseId] are present in the bundle.
Future<int> chapterCount(ContentAssetSource source, String caseId) async =>
    (await CaseManifest.read(source, caseId)).chapters.length;

/// Loads the first [chapterLimit] chapters of a case (all of them when
/// null) through the real loaders. A loading failure throws, with the
/// message of the failure.
Future<LoadedCase> loadCaseForValidation(
  ContentAssetSource source,
  String caseId, {
  int? chapterLimit,
}) async {
  T unwrap<T>(T? value, Object? failure) {
    if (value == null) throw StateError('Content failed to load: $failure');
    return value;
  }

  final content = await AssetSceneContentRepository(
    source,
    chapterLimit: chapterLimit,
  ).loadCase(caseId);
  final items = await AssetItemCatalogRepository(
    source,
    chapterLimit: chapterLimit,
  ).loadItems(caseId);
  final notes = await AssetNoteCatalogRepository(
    source,
    chapterLimit: chapterLimit,
  ).loadNotes(caseId);
  final dialogues = await AssetDialogueCatalogRepository(
    source,
    const CodecRuleParser(),
    chapterLimit: chapterLimit,
  ).loadDialogues(caseId);

  final textKeys = <String, Set<String>>{};
  for (final locale in AppLocalizations.supportedLocales) {
    final texts = await ContentTextLoader(
      source,
    ).load(caseId, locale.languageCode, chapterLimit: chapterLimit);
    textKeys[locale.languageCode] = unwrap(
      texts.valueOrNull,
      texts.failureOrNull,
    ).keys.toSet();
  }

  return LoadedCase(
    content: unwrap(content.valueOrNull, content.failureOrNull),
    items: unwrap(items.valueOrNull, items.failureOrNull),
    notes: unwrap(notes.valueOrNull, notes.failureOrNull),
    dialogues: unwrap(dialogues.valueOrNull, dialogues.failureOrNull),
    textKeysByLanguage: textKeys,
  );
}

/// Runs every validator on [loaded], the way the content validation test
/// does: scenes first, then dialogues, then the flags (a flag may be set
/// on one side and read on the other).
///
/// With [reportUnusedTexts] the result also holds a warning for each text
/// key nothing refers to. That is only meaningful for a whole case, not for
/// a chapter prefix.
List<ContentIssue> validateLoadedCase(
  LoadedCase loaded, {
  required KnownStyleNames styles,
  double reservedBottomStrip = 0,
  bool reportUnusedTexts = false,
}) {
  final checks = ContentChecks(
    content: loaded.content,
    items: loaded.items,
    notes: loaded.notes,
    textKeysByLanguage: loaded.textKeysByLanguage,
    dialogueTopics: DialogueValidator.topicIds(loaded.dialogues),
  );
  const ContentValidator().validateWith(
    checks,
    styles: styles,
    reservedBottomStrip: reservedBottomStrip,
  );
  const DialogueValidator().validate(
    dialogues: loaded.dialogues,
    checks: checks,
    portraitStyles: styles.placeholderStyles,
  );
  checks.flagIssues();

  return [
    ...checks.issues,
    if (reportUnusedTexts)
      ...ContentValidator.unusedTextWarnings(
        textKeysByLanguage: loaded.textKeysByLanguage,
        usedKeys: checks.usedTextKeys,
      ),
  ];
}
