/// The kinds of content a chapter folder holds.
///
/// Each kind is either one file (`scenes.json`) **or** one folder
/// (`scenes/*.json`), never both (ADR 0018). Story texts are not listed
/// here: they stay one file per language (`text_en.json`).
enum ContentType {
  scenes,
  items,
  notes,
  inspections,

  /// Optional: a chapter without triggers has neither file nor folder.
  triggers(isOptional: true);

  const ContentType({this.isOptional = false});

  /// Whether a chapter may leave this kind out.
  final bool isOptional;

  /// `scenes.json`
  String get fileName => '$name.json';

  /// `scenes/`
  String get folderName => '$name/';
}

/// Where the game content lives inside the asset bundle.
///
/// ```text
/// assets/content/
///   common/text_en.json
///   cases/case01/
///     case.json
///     chapters/ch01/
///       scenes.json        or  scenes/*.json
///       items.json         or  items/*.json
///       notes.json         or  notes/*.json
///       inspections.json   or  inspections/*.json
///       triggers.json      or  triggers/*.json   (optional)
///       text_en.json
/// ```
abstract final class ContentPaths {
  static const root = 'assets/content';

  /// The case the game starts with.
  static const defaultCaseId = 'case01';

  static String caseManifest(String caseId) => '$root/cases/$caseId/case.json';

  /// The folder of one chapter, with a trailing slash.
  static String chapterFolder(String caseId, String chapterId) =>
      '$root/cases/$caseId/chapters/$chapterId/';

  static String chapterFile(String caseId, String chapterId, String file) =>
      '${chapterFolder(caseId, chapterId)}$file';

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
