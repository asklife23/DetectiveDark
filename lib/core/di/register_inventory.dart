import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_paths.dart';
import 'package:detective_dark/features/inventory/data/repositories/asset_item_catalog_repository.dart';
import 'package:detective_dark/features/inventory/domain/repositories/item_catalog_repository.dart';
import 'package:detective_dark/features/inventory/presentation/cubit/inventory_cubit.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:get_it/get_it.dart';

/// Inventory: the item catalog and the cubit of the item panel.
void registerInventory(GetIt getIt) {
  getIt
    ..registerLazySingleton<ItemCatalogRepository>(
      () => AssetItemCatalogRepository(getIt<ContentAssetSource>()),
    )
    ..registerFactory<InventoryCubit>(
      () => InventoryCubit(
        catalogRepository: getIt<ItemCatalogRepository>(),
        progressRepository: getIt<ProgressRepository>(),
        caseId: ContentPaths.defaultCaseId,
      ),
    );
}
