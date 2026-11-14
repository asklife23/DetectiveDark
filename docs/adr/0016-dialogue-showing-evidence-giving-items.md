# 0016. Dialogue system, showing evidence and giving items

- **Status:** Accepted
- **Date:** 2026-11-14

## Context

The first design kept every other character off screen: suspects existed only as notebook files. Planning
chapter 1 showed that a detective who never questions anyone has to learn everything from paper, which is
both implausible and monotonous. The game still must not become a branching dialogue game: the story is a
single path and the inner voice stays one-way.

## Decision

**A new feature, `features/dialogue/`.** A character is an ordinary hotspot with a silhouette `sprite`.
Tapping it opens the dialogue panel directly (no "Talk" step in between) through a new effect:

```json
{"talk": "pharmacist"}
```

`talk` is UI state like `inspect`: it does not change the navigation stack and is not saved. A rule has at
most one `talk` and never combines it with `goToScene` or `inspect`. Back (system back and Esc included)
closes the panel first; while it is open the scene ignores taps.

**Content** lives in `dialogues.json` in the chapter folder:

```json
{"formatVersion": 1, "dialogues": [{
  "id": "pharmacist",
  "nameKey": "char_pharmacist_name",
  "portrait": {"placeholderStyle": "silhouette_pharmacist"},
  "greeting": {"first": "dlg_pharmacist_hello", "then": "dlg_pharmacist_again"},
  "noReactionKey": "dlg_pharmacist_no_reaction",
  "topics": [
    {"id": "about_villa", "promptKey": "...", "answer": ["...", "..."],
     "do": [{"addNoteEntry": {"note": "person_pharmacist", "entry": "knows_villa"}}]},
    {"id": "ask_pills", "visibleWhen": {"hasItem": "pill_bottle"}, "promptKey": "...", "answer": ["..."],
     "do": [{"say": "say_pills_owner_known"}]},
    {"id": "give_pills", "trigger": {"showItem": "pill_bottle"}, "promptKey": "...", "answer": ["..."],
     "do": [{"consumeItem": "pill_bottle"},
            {"addNoteEntry": {"note": "person_pharmacist", "entry": "pills_prescribed"}}]},
    {"id": "show_letter", "trigger": {"showNote": "hall_letter"}, "promptKey": "...", "answer": ["..."]}
  ]}]}
```

Rules:

- The player only picks prewritten questions. Questions reveal information; they never branch the story.
- `answer` holds the character's lines. They appear one at a time with a typewriter effect: a tap completes
  the line, the next tap advances; after the last line the question list returns.
- The detective's own comment is a `say` in `do` and arrives through the message bar: the inner voice is
  unchanged. The conversation itself is **not** written to `chatLog`.
- `do` runs only the **first** time a topic is asked, through the effect pipeline (ADR 0014). Asking again
  only replays the answer.
- Asked topics are saved as `askedTopics` (`dialogueId/topicId`) and can be read by rules with the new
  condition `{"topicAsked": "dialogueId/topicId"}`.
- **Visibility = asked OR (no `trigger` AND `visibleWhen` holds).** A topic that was asked once stays in the
  list and can be reread even if its condition later fails (the bottle was given away).
- A visible, unasked topic carries a "new" label in the panel; an asked one is marked. Nothing marks the
  silhouette in the scene: the player is not led from character to character.
- The panel shows four questions without scrolling at the smallest supported phone height; more scroll.
- Topic effects: `say`, `setFlag`, `addNote`, `addNoteEntry`, `giveItem`, `consumeItem`. Navigation,
  `inspect`, `talk` and `hideHotspot` are not allowed; a character who leaves is a flag plus `visibleWhen`
  on the hotspot.
- The greeting takes the `first`/`then` form of `say` (ADR 0013) and uses the same `spokenLines` set.
  Recording that the first greeting was heard is the one progress change caused by opening the panel. It is
  written by the `StartConversation` use case through the effect pipeline, not by the `talk` effect.

**Showing evidence and giving items.** A topic with a `trigger` is not in the question list at first. It
plays when the matching item or note is shown, then stays in the list under its `promptKey` as asked.
Giving is simply `consumeItem` in `do`.

- Item, from the scene: with an item selected, tapping a hotspot whose normally matching rule contains
  `talk` opens the panel and shows the item. This is one resolver rule; hotspots do not need a `usingItem`
  rule per item. An explicit `usingItem` rule on the hotspot still wins.
- Item, with the panel open: a single tap on the item in the side panel shows it.
- Note: "Show evidence" opens the notebook in selection mode; the open note has a "Show" button. Notes can
  be shown **only to characters**. Scene objects use `hasNote`; there is no `usingNote` condition.
- No matching topic (or its condition fails): the character answers with `noReactionKey`. No penalty, no
  mark, nothing saved.

## Consequences

- Reverses "other characters are not shown" in the game design (change log 2026-11-14). The single path
  and the one-way inner voice are untouched.
- New content file, DTOs, a use case for asking and one for showing, a cubit and a panel; `SceneBloc` gains
  an active-dialogue state next to the active inspection.
- The save gains `askedTopics`; opening and closing a conversation is not saved.
- Art needs a silhouette sprite and a portrait per character (placeholders first).
- Authors must make sure a topic cannot be lost for good when it gates progress: a `visibleWhen` that
  depends on an item the player may already have given away hides an unasked question forever. The
  walkthrough check (phase 7.4) is the safety net.
- `dialogue/data` keeps its own DTOs. Conditions and effects are parsed through `RuleParser`, an interface in
  `scene_engine/domain` implemented by the codecs in `scene_engine/data` and handed over by DI, because a
  feature's data layer may not import another feature's data layer (ADR 0001).
- The dependency runs one way, `dialogue` → `scene_engine` (ADR 0014 forbids cycles). `talk` and
  `topicAsked` carry plain IDs, the scene validator receives the known dialogue and topic IDs as data, and
  dialogues are checked by a `DialogueValidator` in `dialogue/domain`.
