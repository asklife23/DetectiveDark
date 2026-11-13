import 'dart:async';

import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';

/// Keeps the progress in memory: it is gone when the app closes.
///
/// Phase 2 replaces this class with a Drift (SQLite) implementation of the
/// same interface; nothing that uses [ProgressRepository] has to change.
class InMemoryProgressRepository implements ProgressRepository {
  InMemoryProgressRepository({GameProgress? initial}) : _current = initial;

  final _changes = StreamController<GameProgress>.broadcast();
  GameProgress? _current;

  @override
  GameProgress? get current => _current;

  @override
  Future<Result<GameProgress?>> load() async => Success(_current);

  @override
  Stream<GameProgress> watch() {
    // `Stream.multi` runs this for every listener: each one first gets the
    // current progress, then every later change.
    return Stream.multi((listener) {
      final current = _current;
      if (current != null) listener.add(current);
      final subscription = _changes.stream.listen(
        listener.addSync,
        onDone: listener.close,
      );
      listener.onCancel = subscription.cancel;
    });
  }

  @override
  Future<Result<void>> save(GameProgress progress) async {
    _current = progress;
    if (!_changes.isClosed) _changes.add(progress);
    return const Success(null);
  }

  Future<void> dispose() => _changes.close();
}
