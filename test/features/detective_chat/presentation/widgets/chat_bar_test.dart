import 'package:detective_dark/core/content/content_text_scope.dart';
import 'package:detective_dark/core/content/content_texts.dart';
import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/core/events/game_event_bus.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_durations.dart';
import 'package:detective_dark/core/theme/app_theme.dart';
import 'package:detective_dark/features/detective_chat/presentation/cubit/chat_cubit.dart';
import 'package:detective_dark/features/detective_chat/presentation/widgets/chat_bar.dart';
import 'package:detective_dark/features/detective_chat/presentation/widgets/chat_history_sheet.dart';
import 'package:detective_dark/features/progress/data/repositories/in_memory_progress_repository.dart';
import 'package:detective_dark/features/progress/domain/entities/chat_log_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/slice_fixtures.dart';

const _locked = 'Locked. Of course it is.';
const _texts = ContentTexts({
  'locked': _locked,
  'opened': 'Open.',
  'hint': 'Look {where}.',
});

/// The strip the bar gets on a landscape phone.
const _stripSize = Size(640, 47);

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));
  late InMemoryProgressRepository progress;
  late GameEventBus bus;
  late ChatCubit cubit;

  setUp(() {
    progress = InMemoryProgressRepository();
    bus = GameEventBus();
    cubit = ChatCubit(progressRepository: progress, eventBus: bus);
  });
  tearDown(() async {
    await cubit.close();
    await progress.dispose();
    await bus.dispose();
  });

  Future<void> pumpHost(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ContentTextScope(
          texts: _texts,
          child: BlocProvider.value(value: cubit, child: child),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> pumpBar(WidgetTester tester) => pumpHost(
    tester,
    Center(
      child: SizedBox.fromSize(size: _stripSize, child: const ChatBar()),
    ),
  );

  /// One save with the new line, then the event, like the `say` effect.
  Future<void> say(
    WidgetTester tester,
    String key, {
    Map<String, String> params = const {},
  }) async {
    await tester.runAsync(() async {
      await progress.save(
        (progress.current ?? newGame).withChatEntry(
          ChatLogEntry(textKey: key, sentAtUtcMs: 1, params: params),
        ),
      );
      bus.publish(DetectiveSaid(key));
      await pumpEventQueue();
    });
    // The first pump delivers the new state to the bar, the second builds
    // what the bar made of it.
    await tester.pump();
    await tester.pump();
  }

  /// The message text of the open bar (not the icon of the button, which
  /// is still fading out while the bar opens).
  Finder messageText() => find.descendant(
    of: find.byType(ChatBar),
    matching: find.byWidgetPredicate(
      (widget) => widget is Text && widget.textSpan != null,
    ),
  );

  /// The part of the message that is visible so far.
  String typed(WidgetTester tester) {
    final message = tester.widget<Text>(messageText()).textSpan! as TextSpan;
    return (message.children!.first as TextSpan).text!;
  }

  Finder button() => find.byTooltip(l10n.chatTooltip);

  final typingTime = AppDurations.chatTypePerCharacter * _locked.length;

  /// Lets the bar fade in and type its message to the end.
  Future<void> finishTyping(WidgetTester tester) async {
    await tester.pump(typingTime + const Duration(milliseconds: 100));
    await tester.pump();
  }

  /// Lets the bar finish switching between message and button. An
  /// animation starts counting at its first frame, hence the extra pumps.
  Future<void> finishToggle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(
      AppDurations.chatBarToggle + const Duration(milliseconds: 50),
    );
    await tester.pump();
  }

  testWidgets('without a message it is only a button, without a badge', (
    tester,
  ) async {
    await pumpBar(tester);

    expect(button(), findsOneWidget);
    expect(find.bySemanticsLabel(_locked), findsNothing);
    expect(find.text('1'), findsNothing);
  });

  testWidgets('a new message is typed out letter by letter', (tester) async {
    await pumpBar(tester);
    await say(tester, 'locked');
    expect(typed(tester), isEmpty);

    await tester.pump(typingTime ~/ 2);
    expect(typed(tester), isNotEmpty);
    expect(typed(tester).length, lessThan(_locked.length));
    expect(_locked, startsWith(typed(tester)));

    await finishTyping(tester);
    expect(typed(tester), _locked);
    expect(find.bySemanticsLabel(_locked), findsOneWidget);
    expect(button(), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a tap while typing shows the whole message at once', (
    tester,
  ) async {
    await pumpBar(tester);
    await say(tester, 'locked');
    await tester.pump(typingTime ~/ 4);

    await tester.tap(find.byType(ChatBar));
    await tester.pump();

    expect(typed(tester), _locked);
    expect(cubit.state.isHistoryOpen, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('after the message was readable the bar shrinks to the button', (
    tester,
  ) async {
    await pumpBar(tester);
    await say(tester, 'locked');
    await finishTyping(tester);

    // Still open shortly before the linger time is over...
    await tester.pump(
      AppDurations.chatLingerMin - const Duration(milliseconds: 300),
    );
    expect(find.bySemanticsLabel(_locked), findsOneWidget);

    // ...and a button again after it.
    await tester.pump(const Duration(milliseconds: 400));
    await finishToggle(tester);
    expect(find.bySemanticsLabel(_locked), findsNothing);
    expect(button(), findsOneWidget);
    expect(cubit.state.unreadCount, 0);
  });

  testWidgets('a message that was replaced before it was read stays on the '
      'badge', (tester) async {
    await pumpBar(tester);
    await say(tester, 'locked');
    await say(tester, 'opened');
    await tester.pump(AppDurations.chatBarToggle);
    expect(find.bySemanticsLabel('Open.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(AppDurations.chatLingerMin);
    await finishToggle(tester);

    expect(button(), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('a tap on the finished message opens the history', (
    tester,
  ) async {
    await pumpBar(tester);
    await say(tester, 'locked');
    await finishTyping(tester);

    await tester.tap(find.byType(ChatBar));
    await tester.pump();

    expect(cubit.state.isHistoryOpen, isTrue);
    expect(cubit.state.unreadCount, 0);
  });

  testWidgets('a tap on the button opens the history', (tester) async {
    await pumpBar(tester);

    await tester.tap(button());
    await tester.pump();

    expect(cubit.state.isHistoryOpen, isTrue);
  });

  testWidgets('a message said before the bar existed is played when it '
      'appears', (tester) async {
    await say(tester, 'locked');

    await pumpBar(tester);

    expect(find.bySemanticsLabel(_locked), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('placeholders in a message are filled in', (tester) async {
    await pumpBar(tester);
    await say(tester, 'hint', params: {'where': 'up'});
    await tester.pump(AppDurations.chatBarToggle);

    expect(find.bySemanticsLabel('Look up.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the bar never paints outside the box it is given', (
    tester,
  ) async {
    await pumpBar(tester);
    final box = tester.getRect(find.byType(ChatBar));
    expect(box.size, _stripSize);
    expect(tester.getRect(button()).bottom, lessThanOrEqualTo(box.bottom));
    expect(tester.getRect(button()).top, greaterThanOrEqualTo(box.top));

    await say(tester, 'locked');
    await finishTyping(tester);
    final text = tester.getRect(messageText());
    expect(text.top, greaterThanOrEqualTo(box.top));
    expect(text.bottom, lessThanOrEqualTo(box.bottom));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  group('ChatHistorySheet', () {
    testWidgets('shows an atmospheric text while it is empty', (tester) async {
      await pumpHost(tester, const ChatHistorySheet());

      expect(find.text(l10n.chatHistoryEmpty), findsOneWidget);
    });

    testWidgets('lists the messages, oldest above newest', (tester) async {
      await say(tester, 'locked');
      await say(tester, 'opened');
      await pumpHost(tester, const ChatHistorySheet());

      final older = tester.getTopLeft(find.text(_locked));
      final newer = tester.getTopLeft(find.text('Open.'));
      expect(older.dy, lessThan(newer.dy));
    });

    testWidgets('the close button and a tap outside close it', (tester) async {
      cubit.openHistory();
      await pumpHost(tester, const ChatHistorySheet());

      await tester.tap(find.byTooltip(l10n.closeTooltip));
      expect(cubit.state.isHistoryOpen, isFalse);

      cubit.openHistory();
      await tester.tapAt(const Offset(4, 4));
      expect(cubit.state.isHistoryOpen, isFalse);
    });

    testWidgets('a tap on the panel itself does not close it', (tester) async {
      await say(tester, 'locked');
      cubit.openHistory();
      await pumpHost(tester, const ChatHistorySheet());

      await tester.tap(find.text(_locked));

      expect(cubit.state.isHistoryOpen, isTrue);
    });
  });
}
