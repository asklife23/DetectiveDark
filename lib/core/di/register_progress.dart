import 'package:detective_dark/features/progress/data/migrations/json_save_codec.dart';
import 'package:detective_dark/features/progress/data/repositories/in_memory_progress_repository.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:detective_dark/features/progress/domain/services/save_codec.dart';
import 'package:get_it/get_it.dart';

/// The progress of the player.
///
/// Everything else asks for the [ProgressRepository] interface. Phase 2
/// swaps the in-memory implementation for Drift by changing this one
/// registration.
void registerProgress(GetIt getIt) {
  getIt
    ..registerSingleton<SaveCodec>(const JsonSaveCodec())
    ..registerLazySingleton<ProgressRepository>(
      InMemoryProgressRepository.new,
      dispose: (repository) async {
        if (repository is InMemoryProgressRepository) {
          await repository.dispose();
        }
      },
    );
}
