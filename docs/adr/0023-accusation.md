# 0023. The accusation

- **Status:** Accepted
- **Date:** 2026-11-16

## Context

The case ends with the player presenting a name and evidence to the police. The design fixes the shape (nine
suspects, a name plus two or three pieces of evidence, two attempts, then "play again" or "see the solution") but
several rules were open: what exactly counts as evidence, whether extra evidence hurts, and whether a right name
with weak evidence costs an attempt.

Like every other part of the game the finale must be data: the culprit and the valid evidence may not appear in
code, and the rules must be testable without an interface.

## Decision

- **Definition in `case.json`:** `accusation` → `suspects` (IDs of person notes), `culprit`, `evidence` (a list of
  `{"note": id}` or `{"note": id, "entry": id}`: a whole note or one line of a person's file, ADR 0015),
  `minValid` (2), `maxPicked` (3), `attempts` (2), `solutionTextKey` and an optional `onSolved` (the usual
  state-changing effects plus `goToScene`, e.g. to a final scene).
- **New effect `{"openAccusation": true}`**, used on a hotspot (the police station); content writes its condition.
  It is interface state like `talk`: not saved, no change to the navigation stack, only in hotspot rules, never
  combined with `goToScene`, `inspect`, `talk` or `openPuzzle`.
- **Flow:** pick a suspect (portrait grid) → pick up to `maxPicked` pieces of evidence from the notebook → confirm.
  Leaving before confirming costs nothing.
- **Verdict (a pure service, `AccusationJudge`):** accepted when the name is right **and** at least `minValid` of
  the picked pieces are valid. An unrelated extra piece does no harm. Wrong name → "not convinced". Right name,
  too little valid evidence → "the evidence is weak". **Both cost an attempt.**
- **Out of attempts:** "Play again" (progress and play time are reset) or "See the solution".
- **Result screen:** number of attempts, total play time, hints used. It can be shared as text that contains no
  spoiler (no name, no evidence).
- **Save:** `accusation` → the attempts (`suspect`, `evidence`, `atUtcMs`, `verdict`) and `outcome` (`none` /
  `solved` / `revealed`). Attempts left are computed from the list. Every change goes through the effect pipeline
  (ADR 0014). The payload version goes up by one.
- **Suspects need a portrait.** A person note gets an optional `portrait` (the same shape as in dialogues); it is
  required for every note listed in `suspects`.
- The feature lives in `features/case_flow/`.

## Consequences

- A new case brings its own accusation as data; the rules are covered by unit tests on plain values.
- "The evidence is weak" tells the player the name was right. That is accepted: the second attempt then turns on
  the evidence, which is where the design wants the difficulty.
- Because unrelated extra evidence is harmless, picking three is never worse than picking two. The limit of three
  keeps the choice meaningful.
- Witnesses have files but are not suspects; who is a suspect is decided by the case, not by the note category.
- The solution sits in a content file. The repository must be private before real content is written (7.0); the
  demo accusation in the vertical slice has nothing to do with the story.
- The play time is counted by the save layer (ADR 0019), so the result screen and "play again" need a small domain
  interface to read the live value and to reset the counter.
