import 'package:detective_dark/core/storage/key_value_store.dart';

/// A [KeyValueStore] that keeps its values in a map, for tests.
class InMemoryKeyValueStore implements KeyValueStore {
  InMemoryKeyValueStore([Map<String, String>? initial])
    : values = {...?initial};

  final Map<String, String> values;

  /// When set, every read and write throws it (a broken disk).
  Exception? failure;

  @override
  Future<String?> readString(String key) async {
    if (failure case final failure?) throw failure;
    return values[key];
  }

  @override
  Future<void> writeString(String key, String value) async {
    if (failure case final failure?) throw failure;
    values[key] = value;
  }
}
