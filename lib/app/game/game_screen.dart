import 'dart:async';

import 'package:detective_dark/app/game/game_hud.dart';
import 'package:detective_dark/app/game/game_status_views.dart';
import 'package:detective_dark/app/game/game_texts_cubit.dart';
import 'package:detective_dark/core/content/content_text_scope.dart';
import 'package:detective_dark/features/scene_engine/presentation/bloc/scene_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

/// The in-game screen. It is the place where the features meet: the `app/`
/// layer is the only one allowed to combine the presentation of several
/// features (scene, inventory, notebook, detective messages).
///
/// It creates the blocs, waits until content and texts are loaded, and
/// then shows the game.
class GameScreen extends StatelessWidget {
  const GameScreen({this.showDebugTools = false, super.key});

  /// Shows developer tools such as the hotspot outlines (dev builds).
  final bool showDebugTools;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final getIt = GetIt.instance;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<SceneBloc>()..add(const SceneStarted()),
        ),
        BlocProvider(
          create: (_) {
            final cubit = getIt<GameTextsCubit>();
            unawaited(cubit.load(languageCode));
            return cubit;
          },
        ),
      ],
      child: Scaffold(body: _GameGate(showDebugTools: showDebugTools)),
    );
  }
}

/// Decides between loading, error and the running game.
class _GameGate extends StatelessWidget {
  const _GameGate({required this.showDebugTools});

  final bool showDebugTools;

  @override
  Widget build(BuildContext context) {
    final textsState = context.watch<GameTextsCubit>().state;
    final sceneStatus = context.select<SceneBloc, SceneStatus>(
      (bloc) => bloc.state.status,
    );
    final texts = textsState.texts;

    if (textsState.failure != null || sceneStatus == SceneStatus.failed) {
      return GameErrorView(
        onRetry: () {
          final languageCode = Localizations.localeOf(context).languageCode;
          context.read<SceneBloc>().add(const SceneStarted());
          unawaited(context.read<GameTextsCubit>().load(languageCode));
        },
      );
    }
    if (texts == null || sceneStatus == SceneStatus.loading) {
      return const GameLoadingView();
    }
    return ContentTextScope(
      texts: texts,
      child: GameHud(showDebugTools: showDebugTools),
    );
  }
}
