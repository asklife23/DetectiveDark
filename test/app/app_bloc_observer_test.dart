import 'package:detective_dark/app/app_bloc_observer.dart';
import 'package:detective_dark/core/logging/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _CounterCubit extends Cubit<int> {
  _CounterCubit() : super(0);

  void increment() => emit(state + 1);

  void fail(Object error) => addError(error, StackTrace.current);
}

void main() {
  late List<LogEntry> entries;
  late BlocObserver previousObserver;

  setUp(() {
    entries = [];
    previousObserver = Bloc.observer;
    Bloc.observer = AppBlocObserver(AppLogger('bloc', writer: entries.add));
  });

  tearDown(() => Bloc.observer = previousObserver);

  test('logs state changes at debug level', () async {
    final cubit = _CounterCubit()..increment();
    await cubit.close();

    expect(entries.single.level, LogLevel.debug);
    expect(entries.single.message, '_CounterCubit: 0 -> 1');
  });

  test('logs bloc errors at error level', () async {
    final error = StateError('boom');
    final cubit = _CounterCubit()..fail(error);
    await cubit.close();

    expect(entries.single.level, LogLevel.error);
    expect(entries.single.error, error);
    expect(entries.single.stackTrace, isNotNull);
  });
}
