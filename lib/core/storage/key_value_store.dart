import 'package:shared_preferences/shared_preferences.dart';

/// A small store for single values: settings and the device ID.
///
/// The save game does not live here; it is in the database (ADR 0003).
/// The interface exists so that code using it can be tested without the
/// platform plugin.
abstract interface class KeyValueStore {
  Future<String?> readString(String key);

  Future<void> writeString(String key, String value);
}

/// Stores the values with `shared_preferences`: `SharedPreferences` on
/// Android, `NSUserDefaults` on iOS, a JSON file on Windows.
class SharedPreferencesStore implements KeyValueStore {
  SharedPreferencesStore([SharedPreferencesAsync? preferences])
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> readString(String key) => _preferences.getString(key);

  @override
  Future<void> writeString(String key, String value) =>
      _preferences.setString(key, value);
}
