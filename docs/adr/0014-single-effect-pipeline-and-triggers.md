# 0014. Single effect pipeline and triggers

- **Status:** Accepted
- **Date:** 2026-11-14

## Context

After phase 1 three use cases write the progress, each with its own copy of "apply, save, publish":
`TapHotspot`, `EnterScene` and `MarkNoteRead`. Dialogue topics, the developer menu and, in phase 5, puzzle
`onSolved` effects would add more copies.

Some story beats also depend on a *combination* of things done in any order ("once both shopkeepers have
been asked about the villa, the detective notices their stories differ"). Written as hotspot or topic rules,
the same check and the same effects would have to be repeated at every place that can complete the
combination, and forgetting one place is a silent bug.

## Decision

**One pipeline.** Every use case that changes the progress goes through `EffectPipeline`
(`scene_engine/domain`), in this fixed order:

1. apply the caller's own change and effects with the pure `EffectApplier` (one new progress);
2. evaluate **triggers** on that progress until nothing new fires;
3. **one** atomic `ProgressRepository.save` (skipped when nothing changed);
4. only after a successful save, publish the collected events.

`TapHotspot` and `EnterScene` move onto it without a change in behaviour. Writes that run no effects but
could matter to a trigger also go through it (recording a heard greeting in `spokenLines`, ADR 0016).

**One exception: `MarkNoteRead`** keeps calling `ProgressRepository.save` directly. Two options were weighed:

- *Move the pipeline to a neutral place both features can depend on.* The pipeline needs `EffectApplier`,
  `TriggerRunner`, `Condition` and `Effect`, so all of those would have to leave `scene_engine` as well: a
  large move for one caller.
- *Exempt `MarkNoteRead`.* No code changes. It only flips `isRead`, which no condition can read, so it can
  never fire a trigger; it runs no effects and publishes no events. Nothing the pipeline guarantees is lost.

The exemption is the smaller change and was chosen. Putting `MarkNoteRead` on the pipeline where it lives now
was ruled out: `notebook` would import `scene_engine` while `scene_engine` already imports `notebook`, and
features must not depend on each other in both directions.

Two architecture tests enforce this: `ProgressRepository.save` is called only from the pipeline, from
`MarkNoteRead` (allowed by name) and inside repository implementations; and the dependency graph between
features, built from import lines, has no cycle.

**Triggers** live in `triggers.json` in the chapter folder: rules with an `id`, a `when` and a `do` that run
**once**, the first time their condition holds.

```json
{"formatVersion": 1, "triggers": [
  {"id": "both_asked_about_villa",
   "when": {"atLeast": {"count": 2, "of": [
     {"topicAsked": "pharmacist/about_villa"}, {"topicAsked": "cafe_owner/about_villa"}]}},
   "do": [{"say": "say_stories_do_not_match"}, {"addNote": "obs_stories_do_not_match"}]}
]}
```

- Fired trigger IDs are stored in the progress (`firedTriggers`); IDs are unique inside a case.
- Evaluation is in file order (chapters in play order), repeated to a fixed point: a trigger may satisfy
  another one. Each trigger fires at most once, so the loop ends; a pass limit guards against engine bugs.
- Allowed effects: `say`, `setFlag`, `addNote`, `addNoteEntry`, `giveItem`. No navigation, no panels, no
  `hideHotspot`, no `consumeItem`: a trigger reacts to what the player did, it does not act for them.
- `usingItem` has no meaning in a trigger condition and is rejected.

## Consequences

- A combination is written once, wherever the player completes it.
- The effects of a tap and of every trigger it sets off land in the same save: no half-applied state on
  disk or on screen, also with asynchronous saves (phase 2).
- New progress-changing features (dialogue, puzzles, dev menu) need no save or event code of their own.
- Triggers are global: every pipeline run evaluates the triggers that have not fired yet. With hundreds of
  triggers this is still a few hundred pure condition checks per tap.
- A trigger cannot be re-armed. Repeating reactions stay ordinary rules.
- If a condition ever reads a note's read state, the `MarkNoteRead` exemption must be revisited.
- The no-cycle rule fixes the direction of every feature dependency (`dialogue` → `scene_engine`, never
  back); shared checks receive plain IDs instead of another feature's entities.
- The save gains `firedTriggers` (phase 2.2 payload).
