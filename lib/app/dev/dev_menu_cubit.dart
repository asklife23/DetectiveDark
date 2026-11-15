import 'dart:async';

import 'package:detective_dark/app/dev/dev_actions.dart';
import 'package:detective_dark/app/dev/dev_catalog.dart';
import 'package:detective_dark/app/dev/dev_preset.dart';
import 'package:detective_dark/app/dev/dev_preset_source.dart';
import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/features/dialogue/domain/repositories/dialogue_catalog_repository.dart';
import 'package:detective_dark/features/inventory/domain/repositories/item_catalog_repository.dart';
import 'package:detective_dark/features/notebook/domain/repositories/note_catalog_repository.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/case_content.dart';
import 'package:detective_dark/features/scene_engine/domain/repositories/scene_content_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum DevMenuStatus { loading, ready, failed }

class DevMenuState extends Equatable {
  const DevMenuState({
    this.status = DevMenuStatus.loading,
    this.catalog,
    this.presets = const [],
    this.progress,
    this.actionFailed = false,
  });

  final DevMenuStatus status;
  final DevCatalog? catalog;
  final List<DevPreset> presets;

  /// The running game, to mark what the player already has.
  final GameProgress? progress;

  /// The last action could not be carried out (e.g. the save failed).
  final bool actionFailed;

  DevMenuState copyWith({
    DevMenuStatus? status,
    DevCatalog? catalog,
    List<DevPreset>? presets,
    GameProgress? progress,
    bool? actionFailed,
  }) => DevMenuState(
    status: status ?? this.status,
    catalog: catalog ?? this.catalog,
    presets: presets ?? this.presets,
    progress: progress ?? this.progress,
    actionFailed: actionFailed ?? this.actionFailed,
  );

  @override
  List<Object?> get props => [status, catalog, presets, progress, actionFailed];
}

/// State of the developer menu: what can be chosen and what the player has.
///
/// The actions return whether they worked. After one that moves the player
/// (jump, reset, preset) the menu widget asks the scene bloc to start
/// again, so the screen shows the scene the progress now points at.
class DevMenuCubit extends Cubit<DevMenuState> {
  DevMenuCubit({
    required this._caseId,
    required this._contentRepository,
    required this._itemCatalog,
    required this._noteCatalog,
    required this._dialogueCatalog,
    required this._presetSource,
    required this._progressRepository,
    required this._actions,
  }) : super(const DevMenuState());

  final String _caseId;
  final SceneContentRepository _contentRepository;
  final ItemCatalogRepository _itemCatalog;
  final NoteCatalogRepository _noteCatalog;
  final DialogueCatalogRepository _dialogueCatalog;
  final DevPresetSource _presetSource;
  final ProgressRepository _progressRepository;
  final DevActions _actions;

  CaseContent? _content;
  StreamSubscription<GameProgress>? _progressSubscription;

  Future<void> load() async {
    final content = (await _contentRepository.loadCase(_caseId)).valueOrNull;
    final items = (await _itemCatalog.loadItems(_caseId)).valueOrNull;
    final notes = (await _noteCatalog.loadNotes(_caseId)).valueOrNull;
    final dialogues = (await _dialogueCatalog.loadDialogues(
      _caseId,
    )).valueOrNull;
    final presets = await _presetSource.load();
    if (isClosed) return;

    if (content == null ||
        items == null ||
        notes == null ||
        dialogues == null) {
      emit(state.copyWith(status: DevMenuStatus.failed));
      return;
    }
    _content = content;
    emit(
      state.copyWith(
        status: DevMenuStatus.ready,
        catalog: DevCatalog.fromContent(
          content: content,
          itemIds: items.keys,
          noteIds: notes.keys,
          dialogues: dialogues.values,
        ),
        presets: presets,
        progress: _progressRepository.current,
      ),
    );
    _progressSubscription = _progressRepository.watch().listen(
      (progress) => emit(state.copyWith(progress: progress)),
    );
  }

  Future<bool> jumpTo(String sceneId) =>
      _run((content) => _actions.jumpTo(content, sceneId));

  Future<bool> giveItem(String itemId) =>
      _run((content) => _actions.giveItem(content, itemId));

  Future<bool> addNote(String noteId) =>
      _run((content) => _actions.addNote(content, noteId));

  Future<bool> setFlag(String flag) =>
      _run((content) => _actions.setFlag(content, flag));

  Future<bool> reset() => _run(_actions.reset);

  Future<bool> loadPreset(DevPreset preset) =>
      _run((content) => _actions.loadPreset(content, preset));

  Future<bool> _run(
    Future<Result<void>> Function(CaseContent content) action,
  ) async {
    final content = _content;
    if (content == null) return false;

    final result = await action(content);
    if (result case Failed(:final failure)) addError(failure);
    if (!isClosed) emit(state.copyWith(actionFailed: !result.isSuccess));
    return result.isSuccess;
  }

  @override
  Future<void> close() async {
    await _progressSubscription?.cancel();
    return super.close();
  }
}
