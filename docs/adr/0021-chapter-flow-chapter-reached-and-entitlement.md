# 0021. Chapter flow, the `chapterReached` condition and entitlement

- **Status:** Accepted
- **Date:** 2026-11-16

## Context

The case has four chapters. Chapter 1 is free (mobile) or the demo (Steam); the rest is paid. Three things were
undefined:

1. **When a chapter ends.** `case.json` listed chapters but had no end condition.
2. **What a later chapter may show.** A later chapter extends the scenes and dialogues of an earlier one in its own
   files (ADR 0018), but nothing tied those extensions to the player's chapter: the author had to guard each one by
   hand, and a forgotten guard would leak chapter 2 content into chapter 1.
3. **What happens at the paywall.** The game design says the game never stops between chapters, with one exception:
   the end of chapter 1.

Purchase state must not be trusted from the local save (CLAUDE.md §8).

## Decision

- **End condition in content.** Each chapter in `case.json` gets `titleKey` and an optional `completeWhen`
  condition.
- **Completion is part of the effect pipeline (ADR 0014).** After the triggers have settled, if the `completeWhen`
  of the chapter the player is in holds, the chapter is marked completed in the **same save**. Event:
  `ChapterCompleted`. The game does not stop; a short banner is shown.
- **Advancing is a separate use case** (`AdvanceChapter`, in the new feature `features/case_flow/`), because it
  asks a platform service and may fail. It runs when a chapter completes, at start-up and whenever entitlement
  changes. If the next chapter is not in the build (demo) or not owned, the chapter does not advance: the game is
  **at the gate**. That state is derived, never saved.
- **Save:** `completedChapters` (`[{chapterId, completedAtUtcMs}]`) and `reachedChapters` (a set; the first chapter
  is in it from the start). `chapterId` stays "the chapter the player is in". The payload version goes up by one.
- **New condition `{"chapterReached": "ch02"}`.** It reads the set; pure.
- **Extensions open by chapter, automatically.** While content is merged (data layer), everything chapter N adds to
  earlier chapters is wrapped as `all[chapterReached N, <its own condition>]`: the hotspots, rules and visual
  variants of `sceneExtensions`, the topics of `dialogueExtensions`, and chapter N's triggers and hint objectives.
  The resolvers and the evaluator do not change; they see ordinary conditions. Chapter N's own scenes are not
  wrapped (they are reachable only through a wrapped transition), and neither are `noteExtensions` (a line appears
  only through an effect).
- **`EntitlementRepository` (domain): "is this chapter unlocked?"** The implementation is chosen in DI. `dev`:
  everything unlocked, with a switch in the developer menu. Every other build: only chapter 1, until the real store
  (Phase 8) and Steam ownership (Phase 11) exist. A safe default: a bug can lock paid content, never unlock it.
- **The gate screen** appears only at the gate, in practice at the end of chapter 1: a purchase screen on mobile
  (its button is a placeholder until Phase 8), an end-of-demo screen on Steam. DI decides which; game code does not
  know the platform. **It can be closed:** the player keeps walking the chapter 1 world, chapter 2 content stays
  closed, and the HUD keeps an "unlock the full game" entry.

## Consequences

- An author writes an extension without thinking about the paywall; a forgotten guard is impossible.
- An earlier chapter cannot name a later one in `chapterReached`: prefix validation (ADR 0018) rejects it, so the
  demo build stays self-contained.
- The pipeline needs the chapter definitions as well as the triggers; its signature changes for every caller.
- Wrapping happens at load time, so a merged condition tree is slightly deeper than the author wrote. Content
  errors still point at the author's file.
- Ownership is asked every time; nothing in the save says "purchased". A player who loses entitlement keeps their
  progress but cannot advance further.
- Until Phases 8 and 11, non-dev builds (staging included) cannot reach chapter 2 at all. That is intended: the
  chapter 1 play test needs nothing more. The play test of chapters 2–4 (7.5) will need them unlocked in the
  staging build; how is decided when that step is detailed.
- The account-linking offer at the end of chapter 1 (Phase 3) is added to the mobile gate screen later.
