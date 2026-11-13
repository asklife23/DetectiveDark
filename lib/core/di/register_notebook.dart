import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_paths.dart';
import 'package:detective_dark/features/notebook/data/repositories/asset_note_catalog_repository.dart';
import 'package:detective_dark/features/notebook/domain/repositories/note_catalog_repository.dart';
import 'package:detective_dark/features/notebook/domain/usecases/mark_note_read.dart';
import 'package:detective_dark/features/notebook/presentation/cubit/notebook_cubit.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:get_it/get_it.dart';

/// Notebook: the note catalog, marking notes as read and the cubit.
void registerNotebook(GetIt getIt) {
  getIt
    ..registerLazySingleton<NoteCatalogRepository>(
      () => AssetNoteCatalogRepository(getIt<ContentAssetSource>()),
    )
    ..registerLazySingleton<MarkNoteRead>(
      () => MarkNoteRead(getIt<ProgressRepository>()),
    )
    ..registerFactory<NotebookCubit>(
      () => NotebookCubit(
        catalogRepository: getIt<NoteCatalogRepository>(),
        progressRepository: getIt<ProgressRepository>(),
        markNoteRead: getIt<MarkNoteRead>(),
        caseId: ContentPaths.defaultCaseId,
      ),
    );
}
