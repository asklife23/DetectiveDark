/// Where the game content lives inside the asset bundle.
///
/// ```text
/// assets/content/
///   common/text_en.json
///   cases/case01/
///     case.json
///     chapters/ch01/
///       scenes.json  items.json  notes.json  inspections.json
///       text_en.json
/// ```
abstract final class ContentPaths {
  static const root = 'assets/content';

  /// The case the game starts with.
  static const defaultCaseId = 'case01';

  static const scenesFile = 'scenes.json';
  static const itemsFile = 'items.json';
  static const notesFile = 'notes.json';
  static const inspectionsFile = 'inspections.json';

  static String caseManifest(String caseId) => '$root/cases/$caseId/case.json';

  static String chapterFile(String caseId, String chapterId, String file) =>
      '$root/cases/$caseId/chapters/$chapterId/$file';

  /// Texts shared by all cases, for one language.
  static String commonTexts(String languageCode) =>
      '$root/common/${_textFile(languageCode)}';

  /// The story texts of one chapter, for one language.
  static String chapterTexts(
    String caseId,
    String chapterId,
    String languageCode,
  ) => chapterFile(caseId, chapterId, _textFile(languageCode));

  static String _textFile(String languageCode) => 'text_$languageCode.json';
}
