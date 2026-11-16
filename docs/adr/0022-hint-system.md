# 0022. Hint system: asked for, tiered, objective-based

- **Status:** Accepted
- **Date:** 2026-11-16

## Context

A point-and-click game loses players who get stuck. The earlier plan had two helpers: tiered hints on request, and
the detective nudging the player by himself after a long time without progress.

The second one conflicts with a principle the design now states outright: **nothing is found for the player.** The
detective says what he sees; he does not say where to go. A hint that arrives unasked takes the puzzle away from
the player. There is also no time mechanic in the game world, and an idle timer is one.

Hints must also be data: with 50+ scenes per chapter they cannot be written in code, and they must follow the
player's actual state, not the scene they happen to stand in.

## Decision

- **Hints come only when the player asks.** A hint button sits in the HUD. Unprompted nudging is off; no code for
  it is written in this phase.
- **The button also works while a puzzle is open:** that is where a stuck player most wants a hint. The text shows
  in the message bar strip, which a puzzle never covers, and the "show the tappable spots" step marks the puzzle's
  interaction regions instead of the scene's hotspots. The button is inactive while the dialogue panel, the
  inspection panel, the notebook, the accusation or the gate screen is open.
- **Objectives in content.** `hints.json` (optional per chapter) is an ordered list of
  `{id, when, tiers: [textKey, ...]}`. `when` means "this objective is still open". The **first** objective whose
  condition holds is the current one. Chapter N's objectives are wrapped with `chapterReached N` (ADR 0021).
- **Presses advance one step per objective:** (1) show the tappable spots; (2..n) the objective's tiers, from a
  direction to the answer. After the last tier the same text is shown again and not counted. With no open
  objective a general line is shown, not counted.
- **Hint text is the detective's inner voice** and goes through the effect pipeline as a `say` (ADR 0014): message
  bar and history, one save.
- **Unlimited and free; 60 seconds between presses.** One constant, measured with the `Clock`, not saved. The
  number is tuned in the play test.
- **"Show the tappable spots"** marks the visible hotspots for about 1.5 seconds. The kind of mark (person, puzzle,
  transition, thing to pick up, other) is derived from the effects of the rule that would run right now; no field
  is added to the JSON. It is presentation only.
- **Save:** `hintsUsed` (a number, shown on the result screen) and `hintTiers` (objective ID → steps opened). The
  payload version goes up by one.

## Consequences

- Hints are written next to the chapter they belong to, in the same condition language as everything else, and are
  checked by the content validator.
- The author must keep objectives in a sensible order and close each one with its condition; a stale objective
  gives a stale hint. The chapter walkthrough test (7.4) can assert that no objective is open at the end.
- The first press on every new objective is the spot marker, even if the player already knows the scene. It is the
  cheapest help, so it comes first.
- The cooldown is forgotten when the app restarts. Accepted: it is a brake against mindless tapping, not a rule.
- A player who never presses the button gets no help at all. That is the point; the play test will show whether
  the button is found.
- No ads and no paid hints (game design 7.1); the counter exists only for the result screen.
