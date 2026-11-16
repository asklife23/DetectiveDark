import 'dart:async';

import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/core/logging/app_logger.dart';
import 'package:detective_dark/core/time/clock.dart';
import 'package:detective_dark/features/progress/data/datasources/local/game_progress_converter.dart';
import 'package:detective_dark/features/progress/data/datasources/local/save_slots_dao.dart';
import 'package:detective_dark/features/progress/data/migrations/json_save_codec.dart';
import 'package:detective_dark/features/progress/data/migrations/save_exception.dart';
import 'package:detective_dark/features/progress/data/services/play_time_counter.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:detective_dark/features/progress/domain/repositories/progress_repository.dart';
import 'package:detective_dark/features/progress/domain/services/progress_autosave.dart';

/// Keeps the progress in the local database, so the player continues where
/// they stopped (ADR 0003).
///
/// **Memory first, disk shortly after.** [save] updates the progress in
/// memory at once and answers at once, so the game never waits for the
/// disk. The write follows [writeDelay] later; changes that arrive in
/// between are written together, as one row. When the app goes to the
/// background, what is still waiting is written immediately
/// ([onBackground]).
///
/// The disk is read once, by the first [load]. After that the memory is
/// the truth: it may be up to [writeDelay] ahead of the disk, never behind.
class DriftProgressRepository implements ProgressRepository, ProgressAutosave {
  DriftProgressRepository({
    required this._dao,
    required this._clock,
    PlayTimeCounter? playTime,
    this.writeDelay = defaultWriteDelay,
    this._logger = const AppLogger('progress'),
  }) : _playTime = playTime ?? PlayTimeCounter();

  /// The game has a single save slot (ADR 0003).
  static const slotIndex = 0;

  /// How long changes are collected before they are written.
  static const defaultWriteDelay = Duration(milliseconds: 500);

  static const JsonSaveCodec _codec = GameProgressConverter.codec;

  final SaveSlotsDao _dao;
  final Clock _clock;
  final PlayTimeCounter _playTime;
  final AppLogger _logger;

  final Duration writeDelay;

  final _changes = StreamController<GameProgress>.broadcast();
  GameProgress? _current;

  /// Set while the slot holds a save of a newer version of the game: this
  /// build must not write over it.
  Failure? _blocked;

  /// True while memory holds changes the disk has not seen.
  bool _hasUnwrittenChanges = false;

  /// The play time of the row on disk.
  int? _writtenPlayTime;

  Timer? _writeTimer;

  /// The running write. Writes are chained, so two can never overlap and
  /// the later one always wins.
  Future<void> _writing = Future.value();

  @override
  GameProgress? get current => _current;

  @override
  Future<Result<GameProgress?>> load() async {
    final current = _current;
    if (current != null) return Success(current);

    _blocked = null;
    try {
      // The version column is checked before the payload is decoded: a
      // save from a newer build may be unreadable for this one, and must
      // then be reported as too new, not as damaged.
      final storedVersion = await _dao.readSchemaVersion(slotIndex);
      if (storedVersion != null && storedVersion > _codec.version) {
        throw SaveTooNewException(
          savedVersion: storedVersion,
          supportedVersion: _codec.version,
        );
      }

      final stored = (await _dao.readSlot(slotIndex))?.payload;
      _playTime.restart(stored?.playTimeSeconds ?? 0);
      if (stored == null) return const Success(null);

      _current = stored;
      _writtenPlayTime = stored.playTimeSeconds;
      _changes.add(stored);
      return Success(stored);
    } on SaveTooNewException catch (error, stackTrace) {
      final failure = JsonSaveCodec.failureOf(error, stackTrace);
      _blocked = failure;
      return Failed(failure);
    } on SaveCorruptException catch (error, stackTrace) {
      return _setAside(error, stackTrace);
    } on Exception catch (error, stackTrace) {
      return Failed(_readFailure(error, stackTrace));
    }
  }

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
    final blocked = _blocked;
    if (blocked != null) return Failed(blocked);

    // The game rules carry the play time along unchanged. A progress that
    // arrives with another one is a different playthrough (a new game, an
    // imported save): counting starts again from its value.
    if (progress.playTimeSeconds != (_current?.playTimeSeconds ?? 0)) {
      _playTime.restart(progress.playTimeSeconds);
    }

    _current = progress;
    _hasUnwrittenChanges = true;
    if (!_changes.isClosed) _changes.add(progress);

    // The timer is not restarted by later changes: a write happens at most
    // [writeDelay] after the first change it contains, however many follow.
    _writeTimer ??= Timer(writeDelay, () => unawaited(_write()));
    return const Success(null);
  }

  @override
  Future<void> onBackground() {
    _playTime.pause();
    return _write();
  }

  @override
  void onForeground() => _playTime.resume();

  /// Writes what is still waiting and closes the change stream. The
  /// database belongs to whoever opened it and is closed there.
  Future<void> dispose() async {
    await _write();
    await _changes.close();
  }

  /// Moves a save that cannot be read into the backups, so nothing is lost
  /// and the slot is free for a new game.
  Future<Result<GameProgress?>> _setAside(
    SaveCorruptException error,
    StackTrace stackTrace,
  ) async {
    _logger.error(
      'The save cannot be read and is set aside: ${error.message}',
      error: error.cause,
      stackTrace: stackTrace,
    );
    try {
      await _dao.moveSlotToBackup(
        slotIndex: slotIndex,
        reason: [error.message, ?error.cause].join(' '),
        nowUtcMs: _nowUtcMs(),
      );
    } on Exception catch (error, stackTrace) {
      return Failed(_readFailure(error, stackTrace));
    }
    return Failed(JsonSaveCodec.failureOf(error, stackTrace));
  }

  Future<void> _write() {
    _writeTimer?.cancel();
    _writeTimer = null;
    return _writing = _writing.then((_) => _writeNow());
  }

  Future<void> _writeNow() async {
    final progress = _current;
    if (progress == null) return;

    // The play time is stamped here, at the moment of writing. Without a
    // change in progress the row is still written when the play time moved
    // on (the player looked around for minutes, then left the game).
    final playTime = _playTime.seconds;
    if (!_hasUnwrittenChanges && playTime == _writtenPlayTime) return;

    _hasUnwrittenChanges = false;
    try {
      final written = await _dao.writeProgress(
        slotIndex: slotIndex,
        progress: progress.withPlayTime(playTime),
        schemaVersion: _codec.version,
        playTimeSeconds: playTime,
        nowUtcMs: _nowUtcMs(),
      );
      if (written) {
        _writtenPlayTime = playTime;
      } else {
        _logger.error(
          'The slot holds a save of a newer version; it was not overwritten.',
        );
      }
    } on Exception catch (error, stackTrace) {
      // Still unwritten: the next change or the next background tries again.
      _hasUnwrittenChanges = true;
      _logger.error(
        'The save could not be written.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  int _nowUtcMs() => _clock.nowUtc().millisecondsSinceEpoch;

  StorageFailure _readFailure(Object error, StackTrace stackTrace) =>
      StorageFailure(
        'The save could not be read.',
        cause: error,
        stackTrace: stackTrace,
      );
}
