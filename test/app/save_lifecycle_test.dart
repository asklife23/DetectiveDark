import 'dart:ui';

import 'package:detective_dark/app/save_lifecycle.dart';
import 'package:detective_dark/features/progress/domain/services/progress_autosave.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingAutosave implements ProgressAutosave {
  final calls = <String>[];

  @override
  Future<void> onBackground() async => calls.add('background');

  @override
  void onForeground() => calls.add('foreground');
}

void main() {
  late _RecordingAutosave autosave;

  /// The states an app passes through on its way to the background and
  /// back. The framework accepts only neighbouring steps, as a real device
  /// sends them.
  const path = [
    AppLifecycleState.resumed,
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
  ];
  var current = AppLifecycleState.resumed;

  /// Walks the app to [target], one legal step at a time.
  void become(WidgetTester tester, AppLifecycleState target) {
    final goal = path.indexOf(target);
    while (current != target) {
      final index = path.indexOf(current);
      current = path[index + (goal > index ? 1 : -1)];
      tester.binding.handleAppLifecycleStateChanged(current);
    }
  }

  Future<void> pumpApp(WidgetTester tester) async {
    autosave = _RecordingAutosave();
    current = AppLifecycleState.resumed;
    tester.binding.handleAppLifecycleStateChanged(current);
    addTearDown(() => become(tester, AppLifecycleState.resumed));
    await tester.pumpWidget(
      SaveLifecycle(autosave: autosave, child: const SizedBox.shrink()),
    );
  }

  testWidgets('shows its child and does nothing while the app is in the '
      'foreground', (tester) async {
    await pumpApp(tester);

    expect(find.byType(SizedBox), findsOneWidget);
    expect(autosave.calls, isEmpty);
  });

  testWidgets('losing the focus alone does not save (the game is still on '
      'screen)', (tester) async {
    await pumpApp(tester);

    become(tester, AppLifecycleState.inactive);

    expect(autosave.calls, isEmpty);
  });

  testWidgets('going to the background saves; coming back counts on', (
    tester,
  ) async {
    await pumpApp(tester);

    become(tester, AppLifecycleState.paused);
    expect(autosave.calls, isNotEmpty);
    expect(autosave.calls.toSet(), {'background'});

    autosave.calls.clear();
    become(tester, AppLifecycleState.resumed);
    // On the way back the app is hidden once more before it is resumed;
    // what counts is that the last word is "foreground".
    expect(autosave.calls.last, 'foreground');
  });

  testWidgets('a hidden window (minimised on desktop) saves too', (
    tester,
  ) async {
    await pumpApp(tester);

    become(tester, AppLifecycleState.hidden);

    expect(autosave.calls, ['background']);
  });

  testWidgets('closing the window waits for the save, then lets the app '
      'exit', (tester) async {
    await pumpApp(tester);

    final response = await tester.binding.handleRequestAppExit();

    expect(response, AppExitResponse.exit);
    expect(autosave.calls, ['background']);
  });

  testWidgets('after it is removed it no longer listens', (tester) async {
    await pumpApp(tester);
    await tester.pumpWidget(const SizedBox.shrink());

    become(tester, AppLifecycleState.paused);

    expect(autosave.calls, isEmpty);
  });
}
