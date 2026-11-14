import 'package:detective_dark/features/inventory/domain/entities/item_definition.dart';
import 'package:detective_dark/features/notebook/domain/entities/note_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/case_content.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_visual.dart';
import 'package:detective_dark/features/scene_engine/domain/services/interaction_resolver.dart';
import 'package:equatable/equatable.dart';

/// One problem found in the game content.
class ContentIssue extends Equatable {
  const ContentIssue(this.location, this.message);

  /// Where it is, e.g. `scene villa_hall / hotspot desk_paper`.
  final String location;

  final String message;

  @override
  List<Object?> get props => [location, message];

  @override
  String toString() => '$location: $message';
}

/// Names that exist in code and are only referenced by content.
class KnownStyleNames extends Equatable {
  const KnownStyleNames({
    required this.overlayStyles,
    required this.filterPresets,
    required this.placeholderStyles,
  });

  final Set<String> overlayStyles;
  final Set<String> filterPresets;
  final Set<String> placeholderStyles;

  @override
  List<Object?> get props => [overlayStyles, filterPresets, placeholderStyles];
}

/// Checks a whole case for mistakes a player would otherwise find: broken
/// references, missing texts, misspelled flags, unreachable scenes.
///
/// Pure Dart. The content validation test runs it on the real content on
/// every push; with 50+ scenes per chapter it is the safety net. An empty
/// result means the content is consistent.
class ContentValidator {
  const ContentValidator();

  /// Effects allowed in `onFirstEnter`.
  static const _firstEnterEffects = 'say, setFlag, addNote, giveItem';

  /// Effects allowed in a trigger.
  static const _triggerEffects = 'say, setFlag, addNote, giveItem';

  /// [reservedBottomStrip] is the share of the scene height, along its
  /// bottom edge, that the interface keeps for itself (the detective
  /// message bar). No hotspot may reach into it.
  List<ContentIssue> validate({
    required CaseContent content,
    required Map<String, ItemDefinition> items,
    required Map<String, NoteDefinition> notes,
    required Map<String, Set<String>> textKeysByLanguage,
    required KnownStyleNames styles,
    double reservedBottomStrip = 0,
  }) {
    final run = _Run(
      content,
      items,
      notes,
      textKeysByLanguage,
      styles,
      reservedBottomStrip,
    )..text('common texts', InteractionResolver.genericItemNoEffectKey);
    content.scenes.values.forEach(run.scene);
    for (final inspection in content.inspections.values) {
      final where = 'inspection ${inspection.id}';
      run
        ..text(where, inspection.textKey)
        ..optionalText(where, inspection.titleKey)
        ..visual(where, inspection.visual);
    }
    for (final item in items.values) {
      final where = 'item ${item.id}';
      run
        ..text(where, item.nameKey)
        ..text(where, item.descriptionKey);
      if (!styles.placeholderStyles.contains(item.iconStyle)) {
        run.add(where, 'unknown icon style "${item.iconStyle}"');
      }
    }
    for (final note in notes.values) {
      run
        ..text('note ${note.id}', note.titleKey)
        ..text('note ${note.id}', note.bodyKey);
    }
    run
      ..triggers()
      ..flags()
      ..reachability();

    return List.unmodifiable(run.issues);
  }
}

/// The state of one validation run.
class _Run {
  _Run(
    this.content,
    this.items,
    this.notes,
    this.textKeys,
    this.styles,
    this.reservedBottomStrip,
  );

  /// Absorbs floating point noise such as `0.76 + 0.11 = 0.8700000000000001`.
  static const _tolerance = 1e-9;

  static const _insideNotOrAtLeast = 'inside not / atLeast';

  final CaseContent content;
  final Map<String, ItemDefinition> items;
  final Map<String, NoteDefinition> notes;
  final Map<String, Set<String>> textKeys;
  final KnownStyleNames styles;
  final double reservedBottomStrip;

  final issues = <ContentIssue>[];
  final _flagsRead = <String, String>{};
  final _flagsSet = <String>{};
  final _firstLines = <String, String>{};

  void add(String where, String message) =>
      issues.add(ContentIssue(where, message));

  /// [key] must exist in every supported language.
  void text(String where, String key) {
    textKeys.forEach((language, keys) {
      if (!keys.contains(key)) add(where, 'missing text "$key" ($language)');
    });
  }

  void optionalText(String where, String? key) {
    if (key != null) text(where, key);
  }

  void scene(SceneDefinition scene) {
    final where = 'scene ${scene.id}';
    text(where, scene.titleKey);
    _parents(scene);

    visual(where, scene.visual);
    for (final variant in scene.visualVariants) {
      condition('$where / visual variant', variant.when);
      visual('$where / visual variant', variant.visual);
    }

    for (final effect in scene.onFirstEnter) {
      final allowed =
          effect is Say ||
          effect is SetFlag ||
          effect is AddNote ||
          effect is GiveItem;
      if (!allowed) {
        add(
          '$where / onFirstEnter',
          '${effect.runtimeType} is not allowed here '
              '(only ${ContentValidator._firstEnterEffects})',
        );
      }
      this.effect('$where / onFirstEnter', effect);
    }

    final seen = <String>{};
    for (final hotspot in scene.hotspots) {
      final at = '$where / hotspot ${hotspot.id}';
      if (!seen.add(hotspot.id)) add(at, 'duplicate hotspot ID in this scene');
      if (!hotspot.rect.isValid) add(at, 'rect is outside 0–1 or empty');
      if (hotspot.rect.bottom > 1 - reservedBottomStrip + _tolerance) {
        add(
          at,
          'reaches into the bottom strip kept for the message bar '
          '(bottom ${hotspot.rect.bottom.toStringAsFixed(3)}, limit '
          '${(1 - reservedBottomStrip).toStringAsFixed(3)})',
        );
      }
      text(at, hotspot.labelKey);
      if (hotspot.visibleWhen case final visibleWhen?) {
        condition('$at / visibleWhen', visibleWhen);
      }
      if (hotspot.sprite case final sprite?) {
        if (!sprite.rect.isValid) {
          add(at, 'sprite rect is outside 0–1 or empty');
        }
        if (!styles.placeholderStyles.contains(sprite.placeholderStyle)) {
          add(
            at,
            'unknown sprite placeholder style "${sprite.placeholderStyle}"',
          );
        }
      }

      for (final (index, rule) in hotspot.interactions.indexed) {
        final ruleAt = '$at / rule ${index + 1}';
        if (rule.when case final ruleCondition?) {
          condition(ruleAt, ruleCondition);
        }
        if (rule.effects.isEmpty) add(ruleAt, 'has no effects');
        for (final ruleEffect in rule.effects) {
          effect(ruleAt, ruleEffect);
        }

        final inspects = rule.effects.whereType<Inspect>().length;
        if (inspects > 1) add(ruleAt, 'more than one inspect effect');
        if (inspects > 0 && rule.effects.any((e) => e is GoToScene)) {
          add(ruleAt, 'inspect cannot be combined with goToScene');
        }
      }
    }
  }

  void _parents(SceneDefinition scene) {
    final visited = <String>{scene.id};
    var parentId = scene.parentId;
    while (parentId != null) {
      final parent = content.scenes[parentId];
      if (parent == null) {
        add('scene ${scene.id}', 'unknown parent scene "$parentId"');
        return;
      }
      if (!visited.add(parentId)) {
        add('scene ${scene.id}', 'parent chain loops at "$parentId"');
        return;
      }
      parentId = parent.parentId;
    }
  }

  void visual(String where, SceneVisual visual) {
    if (!styles.placeholderStyles.contains(visual.placeholderStyle)) {
      add(where, 'unknown placeholder style "${visual.placeholderStyle}"');
    }
    final preset = visual.filterPreset;
    if (preset != null && !styles.filterPresets.contains(preset)) {
      add(where, 'unknown filter preset "$preset"');
    }
    for (final overlay in visual.overlays) {
      if (!overlay.rect.isValid) {
        add(where, 'overlay rect is outside 0–1 or empty');
      }
      switch (overlay) {
        case TextOverlay(:final textKey, :final style):
          text('$where / overlay', textKey);
          if (!styles.overlayStyles.contains(style)) {
            add(where, 'unknown overlay style "$style"');
          }
      }
    }
  }

  /// [noUsingItem] names a place where `usingItem` is forbidden ("in a
  /// trigger"); null where it is allowed. Inside `not` and `atLeast` it is
  /// always forbidden, at any depth.
  void condition(String where, Condition condition, {String? noUsingItem}) {
    void inner(Condition c, {String? ban}) =>
        this.condition(where, c, noUsingItem: noUsingItem ?? ban);

    switch (condition) {
      case FlagSet(:final flag) || FlagNotSet(:final flag):
        _flagsRead.putIfAbsent(flag, () => where);
      case HasItem(:final itemId):
        if (!items.containsKey(itemId)) add(where, 'unknown item "$itemId"');
      case UsingItem(:final itemId):
        if (!items.containsKey(itemId)) add(where, 'unknown item "$itemId"');
        if (noUsingItem != null) {
          add(where, 'usingItem cannot be used $noUsingItem');
        }
      case HasNote(:final noteId):
        if (!notes.containsKey(noteId)) add(where, 'unknown note "$noteId"');
      case AllOf(:final conditions) || AnyOf(:final conditions):
        conditions.forEach(inner);
      case Not(condition: final negated):
        inner(negated, ban: _insideNotOrAtLeast);
      case AtLeast(:final count, :final conditions):
        if (count < 1 || count > conditions.length) {
          add(
            where,
            'atLeast count $count must be between 1 and '
            '${conditions.length}',
          );
        }
        for (final c in conditions) {
          inner(c, ban: _insideNotOrAtLeast);
        }
      case Visited(:final sceneId) || InScene(:final sceneId):
        if (!content.scenes.containsKey(sceneId)) {
          add(where, 'unknown scene "$sceneId"');
        }
    }
  }

  void effect(String where, Effect effect) {
    switch (effect) {
      case GoToScene(:final sceneId):
        if (!content.scenes.containsKey(sceneId)) {
          add(where, 'unknown scene "$sceneId"');
        }
      case GiveItem(:final itemId) || ConsumeItem(:final itemId):
        if (!items.containsKey(itemId)) add(where, 'unknown item "$itemId"');
      case AddNote(:final noteId):
        if (!notes.containsKey(noteId)) add(where, 'unknown note "$noteId"');
      case SetFlag(:final flag):
        _flagsSet.add(flag);
      case Say(:final messageKey, :final repeatKey):
        text(where, messageKey);
        if (repeatKey != null) {
          text(where, repeatKey);
          firstLine(where, messageKey);
        }
      case Inspect(:final inspectionId):
        if (!content.inspections.containsKey(inspectionId)) {
          add(where, 'unknown inspection "$inspectionId"');
        }
      case HideHotspot():
        break;
    }
  }

  void triggers() {
    final seen = <String>{};
    for (final trigger in content.triggers) {
      final where = 'trigger ${trigger.id}';
      if (!seen.add(trigger.id)) add(where, 'duplicate trigger ID');
      condition(where, trigger.when, noUsingItem: 'in a trigger');
      if (trigger.effects.isEmpty) add(where, 'has no effects');
      for (final effect in trigger.effects) {
        final allowed =
            effect is Say ||
            effect is SetFlag ||
            effect is AddNote ||
            effect is GiveItem;
        if (!allowed) {
          add(
            where,
            '${effect.runtimeType} is not allowed here '
            '(only ${ContentValidator._triggerEffects})',
          );
        }
        this.effect(where, effect);
      }
    }
  }

  /// The `first` key of a two-form line must be unique in the case: it is
  /// the key under which "already said" is saved, so a second use would
  /// start out as already spoken.
  void firstLine(String where, String key) {
    final earlier = _firstLines[key];
    if (earlier == null) {
      _firstLines[key] = where;
    } else {
      add(where, 'first line "$key" is already used at $earlier');
    }
  }

  /// A flag that is read but never set is almost always a typo.
  void flags() {
    _flagsRead.forEach((flag, where) {
      if (!_flagsSet.contains(flag)) {
        add(where, 'flag "$flag" is read but never set');
      }
    });
  }

  /// Every scene of a chapter must be reachable from the entry scene of
  /// that chapter, by `goToScene` effects and by Back (to the parent).
  void reachability() {
    for (final chapter in content.definition.chapters) {
      if (!content.scenes.containsKey(chapter.entrySceneId)) {
        add(
          'chapter ${chapter.id}',
          'unknown entry scene "${chapter.entrySceneId}"',
        );
        continue;
      }

      final reached = <String>{};
      final queue = [chapter.entrySceneId];
      while (queue.isNotEmpty) {
        final scene = content.scenes[queue.removeLast()];
        if (scene == null || !reached.add(scene.id)) continue;
        if (scene.parentId case final parentId?) queue.add(parentId);
        for (final hotspot in scene.hotspots) {
          for (final rule in hotspot.interactions) {
            queue.addAll(
              rule.effects.whereType<GoToScene>().map((e) => e.sceneId),
            );
          }
        }
      }

      content.sceneChapters.forEach((sceneId, chapterId) {
        if (chapterId == chapter.id && !reached.contains(sceneId)) {
          add('scene $sceneId', 'cannot be reached from the chapter entry');
        }
      });
    }
  }
}
