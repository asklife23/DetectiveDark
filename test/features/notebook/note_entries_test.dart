import 'dart:convert';

import 'package:detective_dark/core/content/content_asset_source.dart';
import 'package:detective_dark/core/content/content_text_scope.dart';
import 'package:detective_dark/core/content/content_texts.dart';
import 'package:detective_dark/core/events/game_event.dart';
import 'package:detective_dark/core/events/game_event_bus.dart';
import 'package:detective_dark/core/l10n/l10n.dart';
import 'package:detective_dark/core/theme/app_theme.dart';
import 'package:detective_dark/features/notebook/data/repositories/asset_note_catalog_repository.dart';
import 'package:detective_dark/features/notebook/domain/entities/note_definition.dart';
import 'package:detective_dark/features/notebook/domain/usecases/mark_note_read.dart';
import 'package:detective_dark/features/notebook/presentation/cubit/notebook_cubit.dart';
import 'package:detective_dark/features/notebook/presentation/widgets/note_page.dart';
import 'package:detective_dark/features/notebook/presentation/widgets/notebook_button.dart';
import 'package:detective_dark/features/notebook/presentation/widgets/notebook_screen.dart';
import 'package:detective_dark/features/progress/data/repositories/in_memory_progress_repository.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/services/effect_applier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_asset_bundle.dart';
import '../../helpers/game_app.dart';
import '../../helpers/slice_fixtures.dart';

/// Note entries and the People tab (ADR 0015), with hand-made content: the
/// file of a gardener that gains two lines.
void main() {
  const knowsVilla = AddNoteEntry(
    noteId: 'person_gardener',
    entryId: 'knows_villa',
  );
  const sawLight = AddNoteEntry(
    noteId: 'person_gardener',
    entryId: 'saw_light',
  );
  const texts = ContentTexts({
    'gardener_title': 'The gardener',
    'gardener_body': 'Works the grounds of the villa.',
    'gardener_knows_villa': 'Has kept the garden for twenty years.',
    'gardener_saw_light': 'Saw a light in the hall after midnight.',
  });

  late InMemoryProgressRepository progress;
  late GameEventBus bus;
  late NotebookCubit cubit;

  /// Applies [effects] the way the effect pipeline does: one save, then
  /// the events. Does not wait for the listeners.
  Future<void> applyNow(List<Effect> effects) async {
    final current = progress.current ?? newGame;
    final outcome = const EffectApplier().apply(
      current,
      effects,
      EffectContext(
        sceneId: 'villa_exterior',
        nowUtcMs: 1000 + current.notes.length,
      ),
    );
    await progress.save(outcome.progress);
    bus.publishAll(outcome.events);
  }

  /// [applyNow], then lets every listener run (plain tests).
  Future<void> apply(List<Effect> effects) async {
    await applyNow(effects);
    await pumpEventQueue();
  }

  /// Creates repository, bus and cubit. Widget tests call it inside the
  /// test body: streams deliver in the zone they were listened in, and
  /// only listeners created under the fake clock run during `pump`.
  Future<void> create() async {
    progress = InMemoryProgressRepository();
    bus = GameEventBus();
    cubit = NotebookCubit(
      catalogRepository: AssetNoteCatalogRepository(
        ContentAssetSource(
          minimalCaseBundle({
            chapterAsset('notes.json'): jsonEncode({
              'formatVersion': 1,
              'notes': [
                {
                  'id': 'person_gardener',
                  'category': 'person',
                  'titleKey': 'gardener_title',
                  'bodyKey': 'gardener_body',
                  'entries': [
                    {'id': 'saw_light', 'textKey': 'gardener_saw_light'},
                    {'id': 'knows_villa', 'textKey': 'gardener_knows_villa'},
                  ],
                },
              ],
            }),
          }),
        ),
      ),
      progressRepository: progress,
      markNoteRead: MarkNoteRead(progress),
      caseId: 'case01',
      eventBus: bus,
    );
    await cubit.load();
  }

  Future<void> dispose() async {
    await cubit.close();
    await progress.dispose();
    await bus.dispose();
  }

  group('NotebookCubit', () {
    setUp(create);
    tearDown(dispose);

    test('the first line opens the file: one unread note with one line, no '
        'pulse', () async {
      await apply(const [knowsVilla]);

      final entry = cubit.state.entries.single;
      expect(entry.note.category, NoteCategory.person);
      expect(entry.isRead, isFalse);
      expect(entry.lines.map((line) => line.id), ['knows_villa']);
      expect(cubit.state.unreadCount, 1);
      expect(cubit.state.updatePulse, 0);
    });

    test('a line added to a read note makes it unread again and pulses the '
        'button', () async {
      await apply(const [knowsVilla]);
      await cubit.selectNote('person_gardener');
      await pumpEventQueue();
      expect(cubit.state.unreadCount, 0);

      await apply(const [sawLight]);

      expect(cubit.state.unreadCount, 1);
      expect(cubit.state.entries.single.isRead, isFalse);
      expect(cubit.state.updatePulse, 1);
    });

    test('lines are listed in the order they were added, not in catalog '
        'order', () async {
      await apply(const [knowsVilla]);
      await apply(const [sawLight]);

      // The catalog lists saw_light first.
      expect(cubit.state.entries.single.lines.map((line) => line.id), [
        'knows_villa',
        'saw_light',
      ]);
    });

    test('opening an updated note marks its newest line and clears the '
        'badge', () async {
      await apply(const [knowsVilla]);
      await cubit.selectNote('person_gardener');
      await pumpEventQueue();
      await apply(const [sawLight]);

      await cubit.selectNote('person_gardener');
      await pumpEventQueue();

      expect(cubit.state.highlightedLineId, 'saw_light');
      expect(cubit.state.unreadCount, 0);
      expect(progress.current!.notes.single.isRead, isTrue);
    });

    test('the mark is gone once the notebook is closed or the note is '
        'opened again', () async {
      await apply(const [knowsVilla]);
      cubit.openNotebook();
      await cubit.selectNote('person_gardener');
      await pumpEventQueue();
      expect(cubit.state.highlightedLineId, 'knows_villa');

      cubit.closeNotebook();
      expect(cubit.state.highlightedLineId, isNull);
      expect(cubit.state.selectedNoteId, 'person_gardener');

      await cubit.selectNote('person_gardener');
      expect(cubit.state.highlightedLineId, isNull);
    });

    test('switching the tab clears the mark', () async {
      await apply(const [knowsVilla]);
      cubit.selectCategory(NoteCategory.person);
      await cubit.selectNote('person_gardener');

      cubit.selectCategory(NoteCategory.document);

      expect(cubit.state.highlightedLineId, isNull);
    });

    test('a line whose ID is not in the catalog is skipped, not shown '
        'broken', () async {
      await progress.save(
        const EffectApplier().apply(
          newGame,
          const [
            AddNoteEntry(noteId: 'person_gardener', entryId: 'removed'),
            knowsVilla,
          ],
          const EffectContext(sceneId: 'villa_exterior', nowUtcMs: 1),
        ).progress,
      );
      await pumpEventQueue();

      expect(cubit.state.entries.single.lines.map((line) => line.id), [
        'knows_villa',
      ]);
    });
  });

  group('the notebook on screen', () {
    /// Like [apply], under the fake clock of a widget test.
    Future<void> say(WidgetTester tester, List<Effect> effects) async {
      await applyNow(effects);
      await tester.pump();
    }

    Future<void> pumpNotebook(
      WidgetTester tester, {
      List<Effect> first = const [],
    }) async {
      await create();
      addTearDown(dispose);
      if (first.isNotEmpty) await applyNow(first);
      tester.useLandscapePhone();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ContentTextScope(
              texts: texts,
              child: BlocProvider.value(
                value: cubit,
                child: Stack(
                  children: [
                    const Align(
                      alignment: Alignment.topRight,
                      child: NotebookButton(),
                    ),
                    BlocSelector<NotebookCubit, NotebookState, bool>(
                      selector: (state) => state.isOpen,
                      builder: (context, isOpen) => isOpen
                          ? const NotebookScreen()
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    final l10n = lookupAppLocalizations(const Locale('en'));
    Finder badge() => find.descendant(
      of: find.byType(NotebookButton),
      matching: find.text('1'),
    );

    Future<void> openFile(WidgetTester tester) async {
      await tester.tap(find.byTooltip(l10n.notebookTooltip));
      await tester.pumpFor();
      await tester.tap(find.text(l10n.notebookTabPeople));
      await tester.pumpFor();
      await tester.tap(find.text('The gardener'));
      await tester.pumpFor();
    }

    testWidgets('the tabs are Documents, Observations and People', (
      tester,
    ) async {
      await pumpNotebook(tester);
      await tester.tap(find.byTooltip(l10n.notebookTooltip));
      await tester.pumpFor();

      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('Observations'), findsOneWidget);
      expect(find.text('People'), findsOneWidget);

      await tester.tap(find.text('People'));
      await tester.pumpFor();
      expect(find.text(l10n.notebookEmptyPeople), findsOneWidget);
    });

    testWidgets('a person file lies in the People tab; its lines follow the '
        'body in the order they were added', (tester) async {
      await pumpNotebook(tester, first: const [knowsVilla, sawLight]);
      await tester.tap(find.byTooltip(l10n.notebookTooltip));
      await tester.pumpFor();
      expect(find.text('The gardener'), findsNothing);

      await tester.tap(find.text(l10n.notebookTabPeople));
      await tester.pumpFor();
      await tester.tap(find.text('The gardener'));
      await tester.pumpFor();

      final body = tester.getTopLeft(
        find.text('Works the grounds of the villa.'),
      );
      final first = tester.getTopLeft(
        find.text('Has kept the garden for twenty years.'),
      );
      final second = tester.getTopLeft(
        find.text('Saw a light in the hall after midnight.'),
      );
      expect(body.dy, lessThan(first.dy));
      expect(first.dy, lessThan(second.dy));
    });

    testWidgets('a new line lights the badge again; opening the note shows '
        'the line marked and clears the badge', (tester) async {
      await pumpNotebook(tester, first: const [knowsVilla]);
      expect(badge(), findsOneWidget);

      await openFile(tester);
      await tester.tap(find.byTooltip(l10n.closeTooltip));
      await tester.pumpFor();
      expect(badge(), findsNothing);

      // The gardener says more: the file gains a line.
      await say(tester, const [sawLight]);
      await tester.pumpFor();
      expect(badge(), findsOneWidget);

      await tester.tap(find.byTooltip(l10n.notebookTooltip));
      await tester.pumpFor();
      // The note is listed as unread (bold) until it is opened.
      // (The note is still on the right page, so its title is there twice;
      // the first one is the list.)
      final inList = find.text('The gardener').first;
      expect(tester.widget<Text>(inList).style!.fontWeight, FontWeight.w700);

      await tester.tap(inList);
      await tester.pumpFor();

      expect(
        find.descendant(
          of: find.byKey(NotePage.highlightKey),
          matching: find.text('Saw a light in the hall after midnight.'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(NotePage.highlightKey),
          matching: find.text('Has kept the garden for twenty years.'),
        ),
        findsNothing,
      );
      expect(badge(), findsNothing);
    });

    testWidgets('the button swells once when a known note is updated', (
      tester,
    ) async {
      await pumpNotebook(tester, first: const [knowsVilla]);

      double scale() => tester
          .widget<ScaleTransition>(
            find.descendant(
              of: find.byType(NotebookButton),
              matching: find.byType(ScaleTransition),
            ),
          )
          .scale
          .value;
      expect(scale(), 1);

      bus.publish(const NoteUpdated('person_gardener', entryId: 'saw_light'));
      // The event reaches the button within a frame or two; a third of the
      // pulse later the button is swollen either way.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(scale(), greaterThan(1));

      await tester.pumpFor();
      expect(scale(), 1);
    });
  });
}
