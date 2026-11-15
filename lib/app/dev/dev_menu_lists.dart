import 'package:detective_dark/app/dev/dev_menu_cubit.dart';
import 'package:detective_dark/app/dev/dev_preset.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:detective_dark/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// The pages of the developer menu, one per tab: scenes, items, notes,
/// flags and presets. Each is a list of IDs to tap.
///
/// What the player already has (and the scene they stand in) is marked and
/// cannot be tapped again.
class DevMenuLists extends StatelessWidget {
  const DevMenuLists({
    required this.state,
    required this.onJump,
    required this.onGiveItem,
    required this.onAddNote,
    required this.onSetFlag,
    required this.onLoadPreset,
    super.key,
  });

  final DevMenuState state;
  final ValueChanged<String> onJump;
  final ValueChanged<String> onGiveItem;
  final ValueChanged<String> onAddNote;
  final ValueChanged<String> onSetFlag;
  final ValueChanged<DevPreset> onLoadPreset;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final catalog = state.catalog;
    final progress = state.progress;

    if (state.status == DevMenuStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (catalog == null) return _Message(l10n.gameLoadFailed);

    return TabBarView(
      children: [
        _IdList(
          ids: catalog.sceneIds,
          isDone: (id) => progress?.currentSceneId == id,
          onTap: onJump,
        ),
        _IdList(
          ids: catalog.itemIds,
          isDone: (id) => progress?.hasItem(id) ?? false,
          onTap: onGiveItem,
        ),
        _IdList(
          ids: catalog.noteIds,
          isDone: (id) => progress?.hasNote(id) ?? false,
          onTap: onAddNote,
        ),
        _IdList(
          ids: catalog.flags,
          isDone: (flag) => progress?.hasFlag(flag) ?? false,
          onTap: onSetFlag,
        ),
        if (state.presets.isEmpty)
          _Message(l10n.devMenuNoPresets)
        else
          _IdList(
            ids: [for (final preset in state.presets) preset.id],
            isDone: (_) => false,
            onTap: (id) => onLoadPreset(
              state.presets.firstWhere((preset) => preset.id == id),
            ),
          ),
      ],
    );
  }
}

class _IdList extends StatelessWidget {
  const _IdList({
    required this.ids,
    required this.isDone,
    required this.onTap,
  });

  final List<String> ids;
  final bool Function(String id) isDone;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final id in ids)
              ActionChip(
                label: Text(id),
                avatar: isDone(id)
                    ? const Icon(Icons.check, color: AppColors.accent)
                    : null,
                onPressed: isDone(id) ? null : () => onTap(id),
              ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
