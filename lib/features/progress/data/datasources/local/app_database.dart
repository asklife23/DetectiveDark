import 'package:detective_dark/features/progress/data/datasources/local/game_progress_converter.dart';
import 'package:detective_dark/features/progress/data/datasources/local/save_slots_dao.dart';
import 'package:detective_dark/features/progress/data/datasources/local/save_tables.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// The local SQLite database of the game (ADR 0003).
///
/// The connection is passed in: the app opens a file in the app support
/// folder (`openSaveDatabase`), tests open a database in memory.
///
/// **Changing the tables:** raise [schemaVersion], run
/// `dart run drift_dev make-migrations` and write the step in
/// `MigrationStrategy.onUpgrade`. The command dumps the new schema to
/// `drift_schemas/` and generates the test that proves old databases
/// upgrade correctly.
@DriftDatabase(tables: [SaveSlots, SaveBackups], daos: [SaveSlotsDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// The version of the **table layout**. The version of the JSON inside
  /// `payload` is a different number with its own migrations.
  @override
  int get schemaVersion => 1;
}
