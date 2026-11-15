import 'dart:async';

import 'package:detective_dark/app/dev/dev_actions.dart';
import 'package:detective_dark/app/dev/dev_menu_cubit.dart';
import 'package:detective_dark/app/dev/dev_menu_lists.dart';
import 'package:detective_dark/app/dev/dev_preset_source.dart';
import 'package:detective_dark/core/content/content_paths.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:detective_dark/core/theme/app_spacing.dart';
import 'package:detective_dark/core/time/clock.dart';
import 'package:detective_dark/core/widgets/hud_icon_button.dart';
import 'package:detective_dark/features/dialogue/domain/repositories/dialogue_catalog_repository.dart';
import 'package:detective_dark/features/inventory/domain/repositories/item_catalog_repository.dart';
import 'package:detective_dark/features/notebook/domain/repositories/note_catalog_repository.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/repositories/scene_content_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/services/effect_pipeline.dart';
import 'package:detective_dark/features/scene_engine/domain/usecases/enter_scene.dart';
import 'package:detective_dark/features/scene_engine/presentation/bloc/scene_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

/// The `DevMenuBuilder` that `lib/main_dev.dart` hands to `bootstrap`.
Widget buildDevMenu(BuildContext context, VoidCallback onClose) {
  return BlocProvider(
    create: (_) {
      final cubit = createDevMenuCubit(GetIt.instance);
      unawaited(cubit.load());
      return cubit;
    },
    child: DevMenu(onClose: onClose),
  );
}

/// Wires the menu to the dependencies of the running game. It is done here
/// and not in `core/di`, because nothing outside `lib/app/dev/` may know
/// the menu.
DevMenuCubit createDevMenuCubit(GetIt getIt) {
  final progressRepository = getIt<ProgressRepository>();
  return DevMenuCubit(
    caseId: ContentPaths.defaultCaseId,
    contentRepository: getIt<SceneContentRepository>(),
    itemCatalog: getIt<ItemCatalogRepository>(),
    noteCatalog: getIt<NoteCatalogRepository>(),
    dialogueCatalog: getIt<DialogueCatalogRepository>(),
    presetSource: DevPresetSource(getIt<AssetBundle>()),
    progressRepository: progressRepository,
    actions: DevActions(
      pipeline: getIt<EffectPipeline>(),
      enterScene: getIt<EnterScene>(),
      progressRepository: progressRepository,
      clock: getIt<Clock>(),
    ),
  );
}

/// The developer menu: jump to a scene, add items, notes and flags, reset
/// the progress or load a named state. It covers the whole game screen.
class DevMenu extends StatelessWidget {
  const DevMenu({required this.onClose, super.key});

  final VoidCallback onClose;

  /// Runs an action that moves the player. On success the menu closes and
  /// the scene bloc starts again from the stored progress, which now
  /// points at the new scene.
  Future<void> _move(BuildContext context, Future<bool> action) async {
    final sceneBloc = context.read<SceneBloc>();
    if (!await action) return;
    onClose();
    sceneBloc.add(const SceneStarted());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<DevMenuCubit>();
    final tabs = [
      l10n.devMenuTabScenes,
      l10n.devMenuTabItems,
      l10n.devMenuTabNotes,
      l10n.devMenuTabFlags,
      l10n.devMenuTabPresets,
    ];

    return ColoredBox(
      color: AppColors.scrim,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Material(
            color: AppColors.surface,
            borderRadius: const BorderRadius.all(Radius.circular(AppRadii.md)),
            clipBehavior: Clip.antiAlias,
            child: DefaultTabController(
              length: tabs.length,
              child: Column(
                children: [
                  _Header(
                    onReset: () => _move(context, cubit.reset()),
                    onClose: onClose,
                  ),
                  TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: [for (final tab in tabs) Tab(text: tab)],
                  ),
                  Expanded(
                    child: BlocBuilder<DevMenuCubit, DevMenuState>(
                      builder: (context, state) => DevMenuLists(
                        state: state,
                        onJump: (id) => _move(context, cubit.jumpTo(id)),
                        onGiveItem: cubit.giveItem,
                        onAddNote: cubit.addNote,
                        onSetFlag: cubit.setFlag,
                        onLoadPreset: (preset) =>
                            _move(context, cubit.loadPreset(preset)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onReset, required this.onClose});

  final VoidCallback onReset;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final actionFailed = context.select<DevMenuCubit, bool>(
      (cubit) => cubit.state.actionFailed,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
        0,
      ),
      child: Row(
        children: [
          Text(
            l10n.devMenuTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: actionFailed
                ? Text(
                    l10n.devMenuActionFailed,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.warning),
                  )
                : const SizedBox.shrink(),
          ),
          TextButton(onPressed: onReset, child: Text(l10n.devMenuReset)),
          const SizedBox(width: AppSpacing.sm),
          HudIconButton(
            icon: Icons.close,
            tooltip: l10n.closeTooltip,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
