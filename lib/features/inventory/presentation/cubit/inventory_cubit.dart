import 'dart:async';

import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/features/inventory/domain/entities/item_definition.dart';
import 'package:detective_dark/features/inventory/domain/repositories/item_catalog_repository.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// What the item panel shows.
class InventoryState extends Equatable {
  const InventoryState({this.items = const [], this.selectedItemId});

  /// The carried items, in pick-up order.
  final List<ItemDefinition> items;

  /// The item the next tap on the scene will use, if any.
  final String? selectedItemId;

  @override
  List<Object?> get props => [items, selectedItemId];
}

/// The carried items and the selection.
///
/// Which items the player carries is read from the progress (the single
/// source of truth); the cubit only adds the catalog data and the
/// selection, which is interface state and is not saved.
class InventoryCubit extends Cubit<InventoryState> {
  InventoryCubit({
    required this._catalogRepository,
    required this._progressRepository,
    required this._caseId,
  }) : super(const InventoryState());

  final ItemCatalogRepository _catalogRepository;
  final ProgressRepository _progressRepository;
  final String _caseId;

  Map<String, ItemDefinition> _catalog = const {};
  StreamSubscription<GameProgress>? _subscription;

  /// Loads the catalog and starts following the progress.
  Future<void> load() async {
    switch (await _catalogRepository.loadItems(_caseId)) {
      case Success(:final value):
        _catalog = value;
      case Failed(:final failure):
        addError(failure);
    }
    if (isClosed) return;

    await _subscription?.cancel();
    _subscription = _progressRepository.watch().listen(_onProgress);
  }

  void _onProgress(GameProgress progress) {
    final items = [for (final id in progress.inventory) ?_catalog[id]];
    // A used-up item cannot stay selected.
    final selected = items.any((item) => item.id == state.selectedItemId)
        ? state.selectedItemId
        : null;
    emit(InventoryState(items: items, selectedItemId: selected));
  }

  /// Tap on an item: select it, or put it back when it is already selected.
  void toggle(String itemId) {
    if (!state.items.any((item) => item.id == itemId)) return;
    emit(
      InventoryState(
        items: state.items,
        selectedItemId: state.selectedItemId == itemId ? null : itemId,
      ),
    );
  }

  /// After every tap on the scene the selection is cleared.
  void clearSelection() {
    if (state.selectedItemId == null) return;
    emit(InventoryState(items: state.items));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
