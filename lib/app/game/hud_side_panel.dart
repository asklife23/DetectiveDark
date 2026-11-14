import 'package:detective_dark/app/game/item_inspection.dart';
import 'package:detective_dark/core/theme/app_colors.dart';
import 'package:detective_dark/core/theme/app_spacing.dart';
import 'package:detective_dark/features/dialogue/domain/entities/dialogue_definition.dart';
import 'package:detective_dark/features/dialogue/presentation/cubit/dialogue_cubit.dart';
import 'package:detective_dark/features/inventory/presentation/widgets/item_sidebar.dart';
import 'package:detective_dark/features/notebook/presentation/cubit/notebook_cubit.dart';
import 'package:detective_dark/features/notebook/presentation/widgets/notebook_button.dart';
import 'package:detective_dark/features/scene_engine/presentation/bloc/scene_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The fixed panel on the right edge: the notebook button above the items.
///
/// A long press on an item opens the examine card. The card is the
/// inspection panel of the scene engine, so the request goes to the scene
/// bloc; `inventory` itself never sees the scene engine's widgets.
///
/// **While a conversation is open the panel means something else** (ADR
/// 0016): a tap on an item shows it to the character instead of selecting
/// it, and the notebook opens to pick a note as evidence. The routing is
/// done here; `inventory` and `notebook` know nothing about dialogues.
class HudSidePanel extends StatelessWidget {
  const HudSidePanel({required this.arrivingItemIds, super.key});

  /// Items whose flying copy has not landed yet.
  final ValueListenable<Set<String>> arrivingItemIds;

  @override
  Widget build(BuildContext context) {
    final isTalking = context.select<DialogueCubit, bool>(
      (cubit) => cubit.state.isOpen,
    );

    return ColoredBox(
      color: AppColors.surface,
      child: SafeArea(
        left: false,
        child: SizedBox(
          width: AppSizes.sidebarWidth,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: NotebookButton(
                  onPressed: isTalking
                      ? () => context.read<NotebookCubit>().openForSelection()
                      : null,
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: arrivingItemIds,
                  builder: (context, arriving, _) => ItemSidebar(
                    arrivingItemIds: arriving,
                    onItemTap: isTalking
                        ? (item) => context.read<DialogueCubit>().show(
                            ShowItem(item.id),
                          )
                        : null,
                    onExamine: (item) => context.read<SceneBloc>().add(
                      InspectionRequested(inspectionForItem(item)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
