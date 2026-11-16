import 'package:detective_dark/core/device/device_id_provider.dart';
import 'package:detective_dark/core/error/failure.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_key_value_store.dart';

void main() {
  late InMemoryKeyValueStore store;

  setUp(() => store = InMemoryKeyValueStore());

  test('creates an ID on the first call and stores it', () async {
    final provider = DeviceIdProvider(store, generate: () => 'generated-id');

    final id = await provider.get();

    expect(id.valueOrNull, 'generated-id');
    expect(store.values[DeviceIdProvider.storageKey], 'generated-id');
  });

  test('keeps the stored ID on later starts', () async {
    store.values[DeviceIdProvider.storageKey] = 'first-start-id';
    var generated = 0;
    final provider = DeviceIdProvider(
      store,
      generate: () {
        generated++;
        return 'another-id';
      },
    );

    expect((await provider.get()).valueOrNull, 'first-start-id');
    expect(generated, 0);
  });

  test('asks the store only once', () async {
    final provider = DeviceIdProvider(store, generate: () => 'generated-id');
    await provider.get();
    store.failure = Exception('disk gone');

    expect((await provider.get()).valueOrNull, 'generated-id');
  });

  test('the real generator makes a different UUID for every install', () async {
    final first = await DeviceIdProvider(InMemoryKeyValueStore()).get();
    final second = await DeviceIdProvider(InMemoryKeyValueStore()).get();

    final uuid = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );
    expect(first.valueOrNull, matches(uuid));
    expect(second.valueOrNull, matches(uuid));
    expect(first.valueOrNull, isNot(second.valueOrNull));
  });

  test('a failing store becomes a StorageFailure, and a later call '
      'tries again', () async {
    final provider = DeviceIdProvider(store, generate: () => 'generated-id');
    store.failure = Exception('disk gone');

    final failed = await provider.get();

    expect(failed.failureOrNull, isA<StorageFailure>());

    store.failure = null;
    expect((await provider.get()).valueOrNull, 'generated-id');
  });
}
