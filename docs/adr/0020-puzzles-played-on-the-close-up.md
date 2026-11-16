# 0020. Puzzle framework: puzzles are played on the close-up picture

- **Status:** Accepted
- **Date:** 2026-11-16

## Context

Until now every puzzle was built from the rule language alone: use the right item in the right place. Chapter 1
needs locks with a code and, later, objects that must be turned the right way. Those need interface state the rule
language cannot express (digits typed so far, the direction of each piece) and a moment of "solved" that runs
effects.

The obvious design is a generic puzzle panel drawn by the game: a keypad widget in a dialog. It was rejected. A
window that looks the same on a strongbox, a gate and a telephone breaks the atmosphere the art exists for, and it
would be the only part of the game not drawn through the shared picture pipeline (ADR 0011: overlay text, noir
filter).

## Decision

- **A puzzle is a close-up picture with interaction regions on top.** The puzzle view covers the scene area and is
  drawn through the same pipeline as a scene: background → overlay text and whatever the puzzle draws (typed
  digits, turning pieces) → noir filter → interaction regions. Regions are normalized rectangles in the JSON, like
  hotspots. Digits and letters are drawn by the game, never baked into the picture (ADR 0011).
- **A new feature, `features/puzzles/`.** Content lives in `puzzles.json` (optional per chapter; one file or a
  folder, ADR 0018). Every puzzle has `id`, `type`, `visual` (the same shape as a scene's visual), type-specific
  fields, `onSolved` (allowed effects: `say`, `setFlag`, `addNote`, `addNoteEntry`, `giveItem`) and an optional
  `wrongSay`. The first types are `keypad` and `directions`; each further type is its own decision.
- **New effect `{"openPuzzle": "id"}`.** Like `inspect` and `talk` it is interface state: it does not change the
  navigation stack and is not saved. It is allowed only in hotspot rules, at most once per rule, and never together
  with `goToScene`, `inspect` or `talk`. Back closes the puzzle first. For a puzzle that is already solved the
  effect is ignored; content swaps the hotspot's behaviour with a condition.
- **New condition `{"puzzleSolved": "id"}`.** (The class is named `HasSolved`; `PuzzleSolved` is the event.)
- **Solving goes through the effect pipeline (ADR 0014):** the "solved" mark, the `onSolved` effects and the
  triggers they fire are one save. Event: `PuzzleSolved`.
- **Save:** `solvedPuzzles` (a set) and `puzzleStates` (puzzle ID → list of integers, for half-finished settings).
  Typed keypad digits are not saved. The payload version goes up by one, with a migration.
- **A wrong attempt costs nothing.** The optional `wrongSay` lets the detective comment.
- **Layering.** `puzzles` depends on `scene_engine`'s domain only (`Effect`, `SceneVisual`, the pipeline, the
  `RuleParser`, which also parses a `visual` for other features). The scene engine knows puzzles only as IDs. The
  puzzle view is assembled in `app/`, the one layer that may combine the presentation of two features: the scene
  engine's picture widget gets a slot for extra content under the filter, and the puzzle supplies a drawing layer
  and a tap layer.

## Consequences

- A new puzzle of an existing type is data plus one picture; no code.
- Every puzzle needs its own close-up picture, produced by the same art pipeline as scenes. Keys are painted in
  the picture without legible digits, or the digits are overlays; the display is painted empty.
- Puzzle regions obey the same rules as hotspots (0–1 coordinates, outside the message bar strip), so the content
  validator and the planned editor (7.2) cover them.
- Two more members of the sealed `Effect` / `Condition` classes: every `switch` over them must be extended.
- The shared `RuleParser` interface grows (visual parsing), and the scene picture widget gains a slot it did not
  need for scenes alone.
- Lock types other than the keypad (dial, clock face, letter lock) are not built. Record inspection (`playMedia`)
  is postponed: the story does not use it.
