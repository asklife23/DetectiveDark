import 'package:detective_dark/core/content/case_manifest.dart';
import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_loading.dart';
import 'package:detective_dark/core/content/content_paths.dart';
import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/features/inventory/data/models/item_dto.dart';
import 'package:detective_dark/features/inventory/domain/entities/item_definition.dart';
import 'package:detective_dark/features/inventory/domain/repositories/item_catalog_repository.dart';

/// Loads the item catalog from the item files of every chapter
/// (`items.json` or `items/*.json`).
class AssetItemCatalogRepository implements ItemCatalogRepository {
  const AssetItemCatalogRepository(this._source, {this.chapterLimit});

  final ContentAssetSource _source;

  /// Loads only the first N chapters (content validation per prefix).
  final int? chapterLimit;

  @override
  Future<Result<Map<String, ItemDefinition>>> loadItems(String caseId) {
    return guardContent(() async {
      final manifest = await CaseManifest.read(
        _source,
        caseId,
        chapterLimit: chapterLimit,
      );
      final items = <String, ItemDefinition>{};

      for (final chapter in manifest.chapters) {
        final files = await readChapterFiles(
          _source,
          chapter,
          ContentType.items,
          ItemsFileDto.fromJson,
        );
        for (final (file, content) in files) {
          mergeUnique(
            items,
            content.items.map((item) => MapEntry(item.id, item.toEntity())),
            file: file,
            kind: 'item',
          );
        }
      }

      return Map.unmodifiable(items);
    });
  }
}
