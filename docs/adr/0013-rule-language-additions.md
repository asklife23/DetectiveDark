# 0013. Rule language additions: conditions, first/then lines, chat log cap

- **Status:** Accepted
- **Date:** 2026-11-14

## Context

The vertical slice proved the condition + effect system, but an engine review against a 50-scene chapter
found gaps that content authors would otherwise paper over with extra flags:

- There is no general negation (`notFlag` only negates flags) and no "at least N of these" (two of three
  witnesses questioned).
- Rules cannot ask where the player is or has been, although the progress already stores both.
- A hotspot that is tapped twice repeats the same long line. The only workaround is a flag per line.
- `chatLog` grows without limit and is part of every save.

## Decision

**New conditions** (sealed `Condition`):

| JSON | True when |
|---|---|
| `{"not": <condition>}` | the inner condition is false |
| `{"atLeast": {"count": 2, "of": [<condition>, ...]}}` | at least `count` of the listed conditions are true |
| `{"visited": "sceneId"}` | the scene has been entered at least once |
| `{"inScene": "sceneId"}` | the scene is the current scene (top of the navigation stack) |

`notFlag` stays (existing content, and it reads better). `usingItem` is not allowed inside `not` or
`atLeast`: "tapped with anything but the key" would make the wrong-item rule ambiguous. The validator
rejects it; the resolver therefore never looks for `usingItem` inside them. `topicAsked` is added with the
dialogue system (ADR 0016).

**`say` takes two forms:**

```json
{"say": "say_door_locked"}
{"say": {"first": "say_statue_body", "then": "say_statue_body_again"}}
```

The second form says `first` the first time and `then` every time after. What has been said is stored in
the progress as the set `spokenLines`, keyed by the `first` key; `first` keys are therefore unique inside a
case (validated).

**`chatLog` is capped** at the last 200 entries (one constant in `progress/domain`). Older entries are
dropped when a new one is appended. No game logic may read `chatLog`: it is a display history. That is why
first/then has its own set instead of searching the log.

## Consequences

- Fewer helper flags; rules read closer to the design sentence they implement.
- Four more cases in the evaluator, codec, resolver and validator, all exhaustively switched and unit tested.
- The save gains `spokenLines` (Phase 2.2 payload) and has a bounded size.
- A player who scrolls the message history sees at most 200 lines; nothing else depends on it.
- `inScene` and `visited` make triggers (ADR 0014) useful without a flag per scene.
