import 'package:detective_dark/features/inventory/domain/entities/item_definition.dart';
import 'package:detective_dark/features/notebook/domain/entities/note_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/case_content.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/condition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/effect.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_definition.dart';
import 'package:detective_dark/features/scene_engine/domain/entities/scene_visual.dart';
import 'package:detective_dark/features/scene_engine/domain/services/content_checks.dart';
import 'package:detective_dark/features/scene_engine/domain/services/content_issue.dart';
import 'package:detective_dark/features/scene_engine/domain/services/interaction_resolver.dart';
import 'package:equatable/equatable.dart';

export 'package:detective_dark/features/scene_engine/domain/services/content_issue.dart';

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
  static const _triggerEffects =
      'say, setFlag, addNote, addNoteEntry, giveItem';

  /// Validates a case on its own: everything [validateWith] checks, plus
  /// the flags.
  ///
  /// [reservedBottomStrip] is the share of the scene height, along its
  /// bottom edge, that the interface keeps for itself (the detective
  /// message bar). No hotspot may reach into it.
  ///
  /// [dialogueTopics] are the conversations that exist (dialogue ID → topic
  /// IDs), for the references of `talk` and `topicAsked`.
  ///
  /// [usedTextKeys], when given, is filled with every text key the content
  /// refers to. Hand the set to [unusedTextWarnings] once every validator
  /// has run.
  List<ContentIssue> validate({
    required CaseContent content,
    required Map<String, ItemDefinition> items,
    required Map<String, NoteDefinition> notes,
    required Map<String, Set<String>> textKeysByLanguage,
    required KnownStyleNames styles,
    double reservedBottomStrip = 0,
    Map<String, Set<String>> dialogueTopics = const {},
    Set<String>? usedTextKeys,
  }) {
    final checks = ContentChecks(
      content: content,
      items: items,
      notes: notes,
      textKeysByLanguage: textKeysByLanguage,
      dialogueTopics: dialogueTopics,
      usedTextKeys: usedTextKeys,
    );
    validateWith(
      checks,
      styles: styles,
      reservedBottomStrip: reservedBottomStrip,
    );
    checks.flagIssues();
    return checks.issues;
  }

  /// Checks scenes, inspections, items, notes and triggers, and writes what
  /// it finds into [checks]. Returns the issues of this call.
  ///
  /// It does **not** check the flags: when the dialogue validator runs on
  /// the same [checks] afterwards, a flag set by a dialogue topic counts
  /// too. Call `checks.flagIssues()` after the last validator.
  List<ContentIssue> validateWith(
    ContentChecks checks, {
    required KnownStyleNames styles,
    double reservedBottomStrip = 0,
  }) {
    final before = checks.issues.length;
    final content = checks.content;
    final run = _Run(checks, styles, reservedBottomStrip)
      ..text('common texts', InteractionResolver.genericItemNoEffectKey);
    content.scenes.values.forEach(run.scene);
    for (final inspection in content.inspections.values) {
      final where = 'inspection ${inspection.id}';
      run
        ..text(where, inspection.textKey)
        ..optionalText(where, inspection.titleKey)
        ..visual(where, inspection.visual);
    }
    for (final item in checks.items.values) {
      final where = 'item ${item.id}';
      run
        ..text(where, item.nameKey)
        ..text(where, item.descriptionKey);
      if (!styles.placeholderStyles.contains(item.iconStyle)) {
        run.add(where, 'unknown icon style "${item.iconStyle}"');
      }
    }
    for (final note in checks.notes.values) {
      final where = 'note ${note.id}';
      run
        ..text(where, note.titleKey)
        ..text(where, note.bodyKey);
      final seen = <String>{};
      for (final entry in note.entries) {
        if (!seen.add(entry.id)) {
          run.add(where, 'duplicate entry ID "${entry.id}"');
        }
        run.text('$where / entry ${entry.id}', entry.textKey);
      }
    }
    run
      ..triggers()
      ..reachability()
      ..trapLocations();

    return checks.issues.sublist(before);
  }

  /// A warning for every text key that nothing refers to: most likely the
  /// text of something that was removed or renamed.
  ///
  /// [usedKeys] is what the validators collected (`usedTextKeys`). Only
  /// meaningful for a whole case: a text of chapter 1 may be used by
  /// chapter 2 only.
  static List<ContentIssue> unusedTextWarnings({
    required Map<String, Set<String>> textKeysByLanguage,
    required Set<String> usedKeys,
  }) {
    final unused = <String>{
      for (final keys in textKeysByLanguage.values) ...keys,
    }.difference(usedKeys).toList()..sort();
    return [
      for (final key in unused)
        ContentIssue(
          'texts',
          'text "$key" is never used',
          severity: ContentSeverity.warning,
        ),
    ];
  }
}

/// The scene side of one validation run. The checks shared with other
/// validators live in [ContentChecks].
class _Run {
  _Run(this.checks, this.styles, this.reservedBottomStrip);

  /// Absorbs floating point noise such as `0.76 + 0.11 = 0.8700000000000001`.
  static const _tolerance = 1e-9;

  final ContentChecks checks;
  final KnownStyleNames styles;
  final double reservedBottomStrip;

  CaseContent get content => checks.content;

  void add(String where, String message) => checks.add(where, message);

  void warn(String where, String message) => checks.warn(where, message);

  void text(String where, String key) => checks.text(where, key);

  void optionalText(String where, String? key) =>
      checks.optionalText(where, key);

  void condition(String where, Condition condition, {String? noUsingItem}) =>
      checks.condition(where, condition, noUsingItem: noUsingItem);

  void effect(String where, Effect effect) => checks.effect(where, effect);

  void scene(SceneDefinition scene) {
    final where = 'scene ${scene.id}';
    text(where, scene.titleKey);
    _parents(scene);

    visual(where, scene.visual);
    for (final variant in scene.visualVariants) {
      condition('$where / visual variant', variant.when);
      visual('$where / visual variant', variant.visual);
    }

    checks.restrictedEffects(
      '$where / onFirstEnter',
      scene.onFirstEnter,
      allowed: (effect) =>
          effect is Say ||
          effect is SetFlag ||
          effect is AddNote ||
          effect is GiveItem,
      allowedNames: ContentValidator._firstEnterEffects,
    );

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
        overlays('$at / sprite', sprite.overlays);
      }

      for (final (index, rule) in hotspot.interactions.indexed) {
        final ruleAt = '$at / rule ${index + 1}';
        if (rule.when case final ruleCondition?) {
          condition(ruleAt, ruleCondition);
        }
        if (rule.effects.isEmpty) add(ruleAt, 'has no effects');
        for (final ruleEffect in rule.effects) {
          effect(ruleAt, ruleEffect);
          if (ruleEffect is GoToScene) crossLink(ruleAt, scene, ruleEffect);
        }

        final goesAway = rule.effects.any((e) => e is GoToScene);
        final inspects = rule.effects.whereType<Inspect>().length;
        if (inspects > 1) add(ruleAt, 'more than one inspect effect');
        if (inspects > 0 && goesAway) {
          add(ruleAt, 'inspect cannot be combined with goToScene');
        }
        // `talk` opens a panel like `inspect` does: one per rule, and never
        // together with another panel or a scene change.
        final talks = rule.effects.whereType<Talk>().length;
        if (talks > 1) add(ruleAt, 'more than one talk effect');
        if (talks > 0 && (goesAway || inspects > 0)) {
          add(ruleAt, 'talk cannot be combined with goToScene or inspect');
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
    overlays(where, visual.overlays);
  }

  /// Overlay text of a visual or of an object in a scene.
  void overlays(String where, List<VisualOverlay> overlays) {
    for (final overlay in overlays) {
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

  void triggers() {
    final seen = <String>{};
    for (final trigger in content.triggers) {
      final where = 'trigger ${trigger.id}';
      if (!seen.add(trigger.id)) add(where, 'duplicate trigger ID');
      condition(where, trigger.when, noUsingItem: 'in a trigger');
      if (trigger.effects.isEmpty) add(where, 'has no effects');
      checks.restrictedEffects(
        where,
        trigger.effects,
        allowed: (effect) =>
            effect is Say ||
            effect is SetFlag ||
            effect is AddNote ||
            effect is AddNoteEntry ||
            effect is GiveItem,
        allowedNames: ContentValidator._triggerEffects,
      );
    }
  }

  /// Travel without a map (ADR 0017) keeps the game readable when every
  /// `goToScene` leads to a close-up of the scene, back to its parent or to
  /// a main location. Anything else (a jump into the close-up of another
  /// place) may be intended, so it is only a warning.
  void crossLink(String where, SceneDefinition from, GoToScene effect) {
    final target = content.scenes[effect.sceneId];
    if (target == null || target.id == from.id) return;
    final isChild = target.parentId == from.id;
    final isParent = from.parentId == target.id;
    final isMainLocation = target.parentId == null;
    if (!isChild && !isParent && !isMainLocation) {
      warn(
        where,
        'goToScene "${target.id}" is neither a close-up of this scene, its '
        'parent nor a main location (cross link)',
      );
    }
  }

  /// The scenes reachable from [startId] by `goToScene` effects and by Back
  /// (to the parent). Conditions are not looked at: this proves that a way
  /// is *written*, not that it is open at every moment.
  Set<String> _reachableFrom(String startId) {
    final reached = <String>{};
    final queue = [startId];
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
    return reached;
  }

  /// No location may be a trap (ADR 0017): from every main location (a
  /// scene without a parent) there must be a way back to the entry scene of
  /// its chapter. There is no map to escape with.
  void trapLocations() {
    final entries = {
      for (final chapter in content.definition.chapters)
        chapter.id: chapter.entrySceneId,
    };
    for (final scene in content.scenes.values) {
      if (scene.parentId != null) continue;
      final entry = entries[content.sceneChapters[scene.id]];
      if (entry == null || !content.scenes.containsKey(entry)) continue;
      // A scene nothing leads to is reported as unreachable already.
      if (!_reachableFrom(entry).contains(scene.id)) continue;
      if (!_reachableFrom(scene.id).contains(entry)) {
        add(
          'scene ${scene.id}',
          'trap location: no way leads from here back to "$entry", the '
              'entry scene of its chapter',
        );
      }
    }
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

      final reached = _reachableFrom(chapter.entrySceneId);

      content.sceneChapters.forEach((sceneId, chapterId) {
        if (chapterId == chapter.id && !reached.contains(sceneId)) {
          add('scene $sceneId', 'cannot be reached from the chapter entry');
        }
      });
    }
  }
}
