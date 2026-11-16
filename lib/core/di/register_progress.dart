import 'package:detective_dark/core/config/app_config.dart';
import 'package:detective_dark/core/time/clock.dart';
import 'package:detective_dark/features/progress/data/datasources/local/app_database.dart';
import 'package:detective_dark/features/progress/data/datasources/local/save_database_connection.dart';
import 'package:detective_dark/features/progress/data/migrations/json_save_codec.dart';
import 'package:detective_dark/features/progress/data/repositories/drift_progress_repository.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:detective_dark/features/progress/domain/services/progress_autosave.dart';
import 'package:detective_dark/features/progress/domain/services/save_codec.dart';
import 'package:get_it/get_it.dart';

/// The progress of the player.
///
/// Everything else asks for the [ProgressRepository] interface and does
/// not know where the progress is kept. This file is the only place that
/// decides: the local database (Drift), with the save file in the app
/// support folder.
///
/// [repository] replaces the database in tests (progress in memory).
void registerProgress(GetIt getIt, {ProgressRepository? repository}) {
  getIt.registerSingleton<SaveCodec>(const JsonSaveCodec());

  if (repository != null) {
    getIt
      ..registerSingleton<ProgressRepository>(repository)
      ..registerSingleton<ProgressAutosave>(const NoAutosave());
    return;
  }

  // Registered in this order on purpose: `GetIt.reset` disposes in reverse,
  // so the repository writes what is waiting before the database closes.
  getIt
    ..registerLazySingleton<AppDatabase>(
      () => AppDatabase(openSaveDatabase(getIt<AppConfig>().flavor)),
      dispose: (database) => database.close(),
    )
    ..registerLazySingleton<DriftProgressRepository>(
      () => DriftProgressRepository(
        dao: getIt<AppDatabase>().saveSlotsDao,
        clock: getIt<Clock>(),
      ),
      dispose: (repository) => repository.dispose(),
    )
    ..registerLazySingleton<ProgressRepository>(
      () => getIt<DriftProgressRepository>(),
    )
    ..registerLazySingleton<ProgressAutosave>(
      () => getIt<DriftProgressRepository>(),
    );
}
