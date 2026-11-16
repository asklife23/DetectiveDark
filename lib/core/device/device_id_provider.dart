import 'package:detective_dark/core/error/failure.dart';
import 'package:detective_dark/core/error/result.dart';
import 'package:detective_dark/core/storage/key_value_store.dart';
import 'package:uuid/uuid.dart';

/// Gives this installation a stable, random ID.
///
/// The ID is created on the first start and then never changes. Cloud sync
/// (Phase 4) uses it to tell which device wrote a save. It says nothing
/// about the person or the hardware: it is a random UUID, and uninstalling
/// the game forgets it.
class DeviceIdProvider {
  DeviceIdProvider(this._store, {String Function()? generate})
    : _generate = generate ?? _randomUuid;

  static const storageKey = 'device_id';

  final KeyValueStore _store;
  final String Function() _generate;

  String? _cached;

  static String _randomUuid() => const Uuid().v4();

  /// The ID of this installation; created and stored on the first call.
  Future<Result<String>> get() async {
    final cached = _cached;
    if (cached != null) return Success(cached);

    try {
      var id = await _store.readString(storageKey);
      if (id == null || id.isEmpty) {
        id = _generate();
        await _store.writeString(storageKey, id);
      }
      _cached = id;
      return Success(id);
    } on Exception catch (error, stackTrace) {
      return Failed(
        StorageFailure(
          'The device ID could not be read or stored.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
