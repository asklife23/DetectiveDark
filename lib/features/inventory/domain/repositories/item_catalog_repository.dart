import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/features/inventory/domain/entities/item_definition.dart';

/// Reads the items of a case, keyed by item ID. Items travel between
/// chapters, so the catalog covers the whole case.
abstract interface class ItemCatalogRepository {
  Future<Result<Map<String, ItemDefinition>>> loadItems(String caseId);
}
