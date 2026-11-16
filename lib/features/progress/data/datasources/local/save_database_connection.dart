import 'package:detective_dark/core/config/flavor.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// The file name of the save database, without the `.sqlite` ending.
///
/// On Android every flavor is a separate app with its own folder. Windows
/// has no flavors: there, a dev run and the Steam build share one folder,
/// so the flavor is part of the name and a test session can never touch
/// the save of a real playthrough.
String saveDatabaseName(Flavor flavor) => switch (flavor) {
  Flavor.prod => 'detective_dark',
  Flavor.dev || Flavor.staging => 'detective_dark_${flavor.name}',
};

/// Opens the save database file of the app.
///
/// The file is `<app support folder>/<name>.sqlite`, a fixed, known place
/// on every platform (ADR 0003):
/// - Android: `/data/data/<application id>/files/`
/// - iOS: `<app container>/Library/Application Support/`
/// - Windows: `%APPDATA%\<company>\<product>\`
///
/// The app support folder is private to the app and, unlike the documents
/// folder (the default of `drift_flutter`), not shown to the user as their
/// own files. Steam Cloud will sync this file (Phase 11).
///
/// `drift_flutter` runs the database on a background isolate, so a write
/// never blocks a frame.
QueryExecutor openSaveDatabase(Flavor flavor) => driftDatabase(
  name: saveDatabaseName(flavor),
  native: const DriftNativeOptions(
    databaseDirectory: getApplicationSupportDirectory,
  ),
);
