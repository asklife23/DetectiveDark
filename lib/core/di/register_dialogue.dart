import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_paths.dart';
import 'package:detective_dark/core/time/clock.dart';
import 'package:detective_dark/features/dialogue/data/repositories/asset_dialogue_catalog_repository.dart';
import 'package:detective_dark/features/dialogue/domain/repositories/dialogue_catalog_repository.dart';
import 'package:detective_dark/features/dialogue/domain/usecases/ask_topic.dart';
import 'package:detective_dark/features/dialogue/domain/usecases/start_conversation.dart';
import 'package:detective_dark/features/dialogue/presentation/cubit/dialogue_cubit.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/repositories/scene_content_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/services/effect_pipeline.dart';
import 'package:detective_dark/features/scene_engine/domain/services/rule_parser.dart';
import 'package:get_it/get_it.dart';

/// Conversations with characters: the dialogue catalog, the use cases that
/// change the game (they write through the shared [EffectPipeline]) and
/// the cubit of the dialogue panel.
///
/// Must run after `registerSceneEngine`: the catalog needs its
/// [RuleParser], the use cases its pipeline.
void registerDialogue(GetIt getIt) {
  getIt
    ..registerLazySingleton<DialogueCatalogRepository>(
      () => AssetDialogueCatalogRepository(
        getIt<ContentAssetSource>(),
        getIt<RuleParser>(),
      ),
    )
    ..registerLazySingleton<StartConversation>(
      () => StartConversation(
        pipeline: getIt<EffectPipeline>(),
        clock: getIt<Clock>(),
      ),
    )
    ..registerLazySingleton<AskTopic>(
      () => AskTopic(
        pipeline: getIt<EffectPipeline>(),
        clock: getIt<Clock>(),
      ),
    )
    ..registerFactory<DialogueCubit>(
      () => DialogueCubit(
        catalogRepository: getIt<DialogueCatalogRepository>(),
        contentRepository: getIt<SceneContentRepository>(),
        progressRepository: getIt<ProgressRepository>(),
        startConversation: getIt<StartConversation>(),
        askTopic: getIt<AskTopic>(),
        caseId: ContentPaths.defaultCaseId,
      ),
    );
}
