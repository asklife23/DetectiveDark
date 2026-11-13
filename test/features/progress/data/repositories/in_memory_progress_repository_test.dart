import 'package:detective_dark/features/progress/data/repositories/in_memory_progress_repository.dart';
import 'package:detective_dark/features/progress/domain/entities/game_progress.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/slice_fixtures.dart';

void main() {
  late InMemoryProgressRepository repository;

  setUp(() => repository = InMemoryProgressRepository());
  tearDown(() => repository.dispose());

  test('starts without a save', () async {
    expect(repository.current, isNull);
    expect((await repository.load()).valueOrNull, isNull);
  });

  test('save replaces the whole progress', () async {
    final progress = newGame.withItem('brass_key');

    final result = await repository.save(progress);

    expect(result.isSuccess, isTrue);
    expect(repository.current, progress);
    expect((await repository.load()).valueOrNull, progress);
  });

  test('watch emits the current progress first, then every save', () async {
    await repository.save(newGame);
    final seen = <GameProgress>[];
    repository.watch().listen(seen.add);
    await pumpEventQueue();

    final next = newGame.withFlag('front_door_open');
    await repository.save(next);
    await pumpEventQueue();

    expect(seen, [newGame, next]);
  });

  test('watch emits nothing before the first save', () async {
    final seen = <GameProgress>[];
    repository.watch().listen(seen.add);
    await pumpEventQueue();

    expect(seen, isEmpty);
  });

  test('every listener gets every save', () async {
    final first = <GameProgress>[];
    final second = <GameProgress>[];
    repository.watch().listen(first.add);
    repository.watch().listen(second.add);

    await repository.save(newGame);
    await pumpEventQueue();

    expect(first, [newGame]);
    expect(second, [newGame]);
  });

  test('an initial progress counts as a stored save', () async {
    final seeded = InMemoryProgressRepository(initial: newGame);
    addTearDown(seeded.dispose);

    expect((await seeded.load()).valueOrNull, newGame);
  });
}
