import 'package:detective_dark/core/content/case_manifest.dart';
import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_loading.dart';
import 'package:detective_dark/core/content/content_paths.dart';
import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/features/inventory/data/models/item_dto.dart';
import 'package:detective_dark/features/inventory/domain/entities/item_definition.dart';
import 'package:detective_dark/features/inventory/domain/repositories/item_catalog_repository.dart';

/// Loads the item catalog from the `items.json` of every chapter.
class AssetItemCatalogRepository implements ItemCatalogRepository {
  const AssetItemCatalogRepository(this._source);

  final ContentAssetSource _source;

  @override
  Future<Result<Map<String, ItemDefinition>>> loadItems(String caseId) {
    return guardContent(() async {
      final manifest = await CaseManifest.read(_source, caseId);
      final items = <String, ItemDefinition>{};

      for (final chapter in manifest.chapters) {
        final path = ContentPaths.chapterFile(
          caseId,
          chapter.id,
          ContentPaths.itemsFile,
        );
        final chapterItems = parseContentFile(
          path,
          await _source.readObject(path),
          (json) => ItemsFileDto.fromJson(json).items,
        );
        mergeUnique(
          items,
          chapterItems.map((item) => MapEntry(item.id, item.toEntity())),
          file: path,
          kind: 'item',
        );
      }

      return Map.unmodifiable(items);
    });
  }
}
