# DetectiveDark

[![CI](https://github.com/asklife23/DetectiveDark/actions/workflows/ci.yml/badge.svg)](https://github.com/asklife23/DetectiveDark/actions/workflows/ci.yml)

A noir, 2.5D point-and-click detective game for Android, iOS and Steam (Windows), built with Flutter.

Explore moody, hand-crafted scenes, tap on details others would miss, collect items and
documents, crack the puzzles and convince the police with the evidence you found.

> 🚧 Work in progress. Phase 1 (the game engine and a playable vertical slice with a villa, a market square
> and two people to question) is done; saving, the story and the real artwork come next. See
> [`plan.md`](plan.md) for the roadmap.

| | |
|---|---|
| ![The villa at night, with the detective's first line](docs/screenshots/01_villa.jpg) | ![A key glimmers behind the statue's ear](docs/screenshots/02_statue_key.jpg) |
| ![The plaque in the inspection panel](docs/screenshots/03_inspection.jpg) | ![The collected letter in the notebook](docs/screenshots/05_notebook.jpg) |
| ![The market square with the pharmacist and the café owner](docs/screenshots/06_market.jpg) | ![The questions the pharmacist can be asked](docs/screenshots/08_dialogue_questions.jpg) |

_Screenshots of the vertical slice. The pictures are placeholder drawings made in code (`CustomPainter`);
the real artwork arrives in Phase 7._

## Features

What the vertical slice already does:

- **Scenes and close-ups.** Locations form a parent → child tree. Tapping a door or a statue fades to its
  close-up; Back (button, Android system back or `Esc`) returns to the parent. No zoom, a calm 150 ms fade.
- **Hotspots without types.** Every tappable area carries an ordered list of rules: a condition and the
  effects it triggers. The first rule whose condition holds runs. New puzzles are new JSON, not new code.
- **Items.** Pick things up (they fly into the panel on the right), select one, then tap where to use it.
  The wrong place only earns a dry remark; the right place consumes the item and changes the scene.
- **Object layer.** Things that can be taken are separate pictures on top of the background and vanish with
  their hotspot, so a scene needs one background instead of one per combination of collected objects.
- **Notebook.** Documents, observations and people, with an unread badge. A person's file grows line by
  line as they make statements. In the finale the evidence will be picked from here.
- **Conversations.** Tap a figure and the dialogue panel opens at once: a portrait, lines typed one by one,
  and a list of written questions. Questions appear as the player learns things, are marked once asked and
  can be read again. The story does not branch; questions only bring out information.
- **Showing evidence and giving items.** Tap an item while talking, or pick a note with "Show evidence":
  the right person reacts, anyone else shrugs. No penalty for trying.
- **Triggers.** "Both of them were asked about the villa" is written once, as a rule that fires the first
  time its condition holds, whichever order the player chose.
- **Travel without a map.** Locations are reached through signposts and exits in the scenes themselves; a
  validation check makes sure no location is a dead end.
- **Inspection panel.** A look-only detail (a plaque, later a clock or a photo) opens in a small window
  without leaving the scene.
- **The detective's inner voice.** A one-way message bar that types each line and then gets out of the way,
  with a history of everything said.
- **Text is never baked into pictures.** House numbers, inscriptions and later codes and clock times are
  drawn by the game on top of the image, so puzzle answers are always legible and translatable.
- **One noir look.** A shared grain, vignette and tint layer makes every picture look like the same film.
- **Touch and mouse.** The same interactions on a phone and in a desktop window; the scene keeps its 16:9
  shape on every screen and hotspots scale with it.
- **Content safety net.** A validation test loads all game content on every push and rejects broken
  references, missing texts, misspelled flags, unreachable scenes and hotspots hidden under the interface.
- **Developer menu (dev builds only).** Jump to any scene, add items, notes and flags, or load a named
  game state. Only the `dev` entry point imports it, so the other builds do not contain its code.

## Tech stack

| Area | Choice |
|---|---|
| Framework | Flutter (Dart 3) |
| Platforms | Android, iOS, Windows (Steam) |
| Architecture | Feature-first Clean Architecture |
| State management | `flutter_bloc` + `equatable` |
| Dependency injection | `get_it` |
| Routing | `go_router` (app screens), scene navigation stack (in-game) |
| Localization | `gen-l10n` (ARB); English at launch, new languages by adding files |
| Fonts | Courier Prime + IBM Plex Sans (bundled, OFL, Latin Extended) |
| Local storage | Drift (SQLite) — planned (Phase 2) |
| Backend | Supabase (Auth, Postgres + RLS, Edge Functions) — planned (Phase 3) |
| CI | GitHub Actions (format, analyze, test, Windows build, Android build) |

## Architecture

Feature-first Clean Architecture. Each feature is split into `domain` (pure Dart: entities, rules, use
cases), `data` (JSON parsing, storage) and `presentation` (blocs, widgets). Dependencies point inwards only,
and a feature may import nothing but the `domain` of another feature. The `app/` layer is the single place
that puts several features on one screen.

```mermaid
flowchart TB
    subgraph app["app/ — composition root"]
        GameScreen["GameScreen / GameHud"]
    end

    subgraph features["features/"]
        direction LR
        scene["scene_engine<br/>scenes, hotspots, rules"]
        inventory["inventory<br/>item panel"]
        notebook["notebook<br/>collected notes"]
        dialogue["dialogue<br/>conversations"]
        chat["detective_chat<br/>inner voice"]
        progress["progress<br/>GameProgress, save"]
    end

    subgraph core["core/"]
        direction LR
        events["GameEventBus"]
        content["content texts"]
        theme["theme tokens"]
        di["di (get_it)"]
    end

    GameScreen --> scene & inventory & notebook & dialogue & chat
    dialogue -- domain only --> scene
    scene -- domain only --> progress
    inventory -- domain only --> progress
    notebook -- domain only --> progress
    chat -- domain only --> progress
    scene -. events .-> events
    events -. events .-> GameScreen & chat
```

Inside a feature:

```mermaid
flowchart LR
    presentation["presentation<br/>Bloc / Cubit, widgets"] --> domain["domain<br/>entities, services, use cases<br/>(pure Dart)"]
    data["data<br/>DTOs, repositories"] --> domain
```

The progress (`GameProgress`) is the single source of truth: the scene, the item panel, the notebook and
the message bar all read from `ProgressRepository`, and one tap is saved as one atomic change. Everything
that changes the progress (a tap, entering a scene, asking a question, showing evidence, the developer
menu) goes through one `EffectPipeline`: effects, then triggers, then a single save, then the events.
Features never depend on each other in a circle. The rules are enforced by a test that reads the import
lines of every file (`test/architecture/dependency_rules_test.dart`). Decisions are recorded in
[`docs/adr/`](docs/adr/).

### The interaction system

Hotspots have no type. A hotspot is a rectangle (normalized 0–1, relative to the scene image) with an
ordered list of rules; a rule is an optional condition (`when`) and a list of effects (`do`). This is the
lock of the front door, straight from the game content:

```json
{
  "id": "lock",
  "rect": {"x": 0.585, "y": 0.44, "width": 0.11, "height": 0.20},
  "labelKey": "hotspot_lock",
  "visibleWhen": {"notFlag": "front_door_open"},
  "interactions": [
    {
      "when": {"usingItem": "brass_key"},
      "do": [
        {"setFlag": "front_door_open"},
        {"consumeItem": "brass_key"},
        {"say": "say_door_unlocked"}
      ]
    },
    {"do": [{"say": "say_door_locked"}]}
  ]
}
```

Tapped with the brass key selected, the first rule runs: the door opens, the key is used up and the
detective comments. Tapped with nothing, the second rule answers "Locked." Tapped with any other item, only
a generic remark is given, so a wrong item can never trigger the normal interaction.

| Conditions | Effects |
|---|---|
| `flag`, `notFlag`, `hasItem`, `usingItem`, `hasNote`, `all`, `any`, `not`, `atLeast`, `visited`, `inScene`, `topicAsked` | `goToScene`, `giveItem`, `consumeItem`, `addNote`, `addNoteEntry`, `setFlag`, `hideHotspot`, `say`, `inspect`, `talk` |

What happens on a tap:

```mermaid
sequenceDiagram
    participant UI as HotspotLayer
    participant Bloc as SceneBloc
    participant UC as TapHotspot (use case)
    participant Rules as InteractionResolver
    participant Pipe as EffectPipeline
    participant Repo as ProgressRepository
    participant Bus as GameEventBus

    UI->>Bloc: HotspotTapped(id, selected item)
    Bloc->>UC: call
    UC->>Rules: which rule runs?
    Rules-->>UC: its effects
    UC->>Pipe: run(effects)
    Pipe->>Pipe: apply effects, then triggers until nothing new fires
    Pipe->>Repo: save (one atomic write)
    Repo-->>Bloc: progress changed → new scene state
    Pipe->>Bus: ItemObtained, DetectiveSaid, ... (only after the save)
    Bus-->>UI: animations (item flight, typewriter)
```

`InteractionResolver`, `EffectApplier` and the trigger runner are pure Dart with no side effects, which is
why the whole puzzle logic is covered by plain unit tests.

### Conversations

A character is an ordinary hotspot with a `talk` effect; what they say lives in `dialogues.json`. This is
the pharmacist, shortened:

```json
{
  "id": "pharmacist",
  "nameKey": "char_pharmacist_name",
  "portrait": {"placeholderStyle": "portrait_pharmacist"},
  "greeting": {"first": "dlg_pharmacist_hello", "then": "dlg_pharmacist_again"},
  "noReactionKey": "dlg_pharmacist_no_reaction",
  "topics": [
    {
      "id": "about_villa",
      "promptKey": "dlg_pharmacist_q_villa",
      "answer": ["dlg_pharmacist_villa_1", "dlg_pharmacist_villa_2"],
      "do": [{"addNoteEntry": {"note": "person_pharmacist", "entry": "knows_villa"}}]
    },
    {
      "id": "ask_pills",
      "visibleWhen": {"hasItem": "pill_bottle"},
      "promptKey": "dlg_pharmacist_q_pills",
      "answer": ["dlg_pharmacist_pills_1", "dlg_pharmacist_pills_2"],
      "do": [{"say": "say_pills_owner_known"}]
    },
    {
      "id": "give_pills",
      "trigger": {"showItem": "pill_bottle"},
      "promptKey": "dlg_pharmacist_q_give_pills",
      "answer": ["dlg_pharmacist_give_pills_1", "dlg_pharmacist_give_pills_2"],
      "do": [
        {"consumeItem": "pill_bottle"},
        {"addNoteEntry": {"note": "person_pharmacist", "entry": "pills_prescribed"}}
      ]
    }
  ]
}
```

The first question is always there; the second appears while the bottle is in the pocket; the third is
never offered as a question: it plays when the player shows him the bottle, and handing it over is simply
the `consumeItem` in its effects. Effects run the first time a topic is asked; asking again only repeats
the answer. Shown anything he has no topic for, he says his `noReactionKey` line and nothing changes.

A trigger reacts to a combination, wherever it comes about (`triggers.json`):

```json
{
  "id": "both_asked_about_villa",
  "when": {"atLeast": {"count": 2, "of": [
    {"topicAsked": "pharmacist/about_villa"},
    {"topicAsked": "cafe_owner/about_villa"}
  ]}},
  "do": [{"say": "say_stories_do_not_match"}, {"addNote": "obs_stories_do_not_match"}]
}
```

### Game content

Everything the player sees and solves lives in `assets/content/` as JSON: scenes, hotspots, items, notes,
inspections, dialogues, triggers and texts. No scene text, coordinate or puzzle solution is written in
code; a new scene is a new JSON entry plus a picture.

```
assets/content/
  common/text_en.json              # shared texts
  cases/case01/
    case.json                      # chapters and their entry scenes
    chapters/ch01/
      scenes.json  items.json  notes.json  inspections.json
      dialogues.json  triggers.json  # optional
      text_en.json                 # a new language = a new text_xx.json
```

A chapter with fifty scenes does not have to be one file: each kind may be a single file (`scenes.json`)
or a folder (`scenes/*.json`, read in name order). A later chapter extends the content of an earlier one
from its own files (`sceneExtensions`, `dialogueExtensions`, `noteExtensions`: a new hotspot in an old
room, a new question for a known character) without editing the earlier chapter. A chapter listed in
`case.json` but missing from the package is skipped, which is how the demo build ships with chapter one
only.

## Getting started

### Requirements

- Flutter 3.44 (stable) / Dart 3.12
- Android SDK (Android Studio)
- Visual Studio with "Desktop development with C++" (for the Windows build)

### Run

The app has three flavors, each with its own entry point and environment file:

| Flavor | Android app ID | Launcher name | Backend |
|---|---|---|---|
| `dev` | `io.github.asklife23.detectivedark.dev` | DD Dev | staging |
| `staging` | `io.github.asklife23.detectivedark.stg` | DD Staging | staging |
| `prod` | `io.github.asklife23.detectivedark` | DetectiveDark | production |

All three can be installed side by side on one device.

```bash
# 1. Create your local env files from the template (they are git-ignored).
cp env/example.json env/dev.json
cp env/example.json env/staging.json
cp env/example.json env/prod.json

# 2. Run a flavor.
flutter pub get
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json
```

The template sets `SHOW_DEBUG_OVERLAY` to `false`. To see the "DEV" badge, set it to `true` in
`env/dev.json` (or delete the key: without it the badge is on for `dev` only).

Android Studio picks up ready-made `dev`, `staging` and `prod` run configurations from `.run/`.

In a `dev` build the wrench button in the top right corner opens the developer menu. Named game states
come from `assets/dev/presets.json`, which is bundled in the `dev` flavor only (so the list is empty on
Windows, where there are no flavors).

| Env key | Meaning |
|---|---|
| `SUPABASE_URL` | Supabase project URL (filled in Phase 3) |
| `SUPABASE_ANON_KEY` | Supabase anon / publishable key — never the service role key |
| `SHOW_DEBUG_OVERLAY` | Shows the flavor badge on screen. Optional; when the key is missing: on for `dev` only |

iOS flavors are set up in Phase 10.

### Windows (Steam build)

Windows has no native flavors; the entry point selects the build. Requires Visual Studio with the
"Desktop development with C++" workload.

```bash
cp env/example.json env/steam.json

# Steam build (prod flavor, Steam platform services)
flutter run -d windows -t lib/main_steam.dart --dart-define-from-file=env/steam.json

# Quick development testing on the desktop, without a phone
flutter run -d windows -t lib/main_dev.dart --dart-define-from-file=env/dev.json
```

The window opens with a 1280×720 (16:9) game area and cannot be made smaller than 960×540.

### Quality checks

```bash
dart run build_runner build   # only after changing a DTO
dart format .
flutter analyze
flutter test
```

`flutter test` includes the acceptance scenario of the vertical slice, played end to end on the real game
screen with touch and mouse, and the content validation test. The same scenario also runs inside the real
app on a device:

```bash
# In a Windows window
flutter test integration_test/acceptance_test.dart -d windows --dart-define-from-file=env/dev.json

# On a connected Android phone
flutter test integration_test/acceptance_test.dart -d <device id> --flavor dev --dart-define-from-file=env/dev.json

# Frame times in profile mode (summary in build/performance/)
flutter drive --profile -d windows --driver=test_driver/performance_driver.dart \
  --target=integration_test/performance_test.dart --dart-define-from-file=env/dev.json
```

Developer tools: `flutter test tool/render_scenes_test.dart` draws every scene with its hotspot outlines to
`build/scene_previews/`; `flutter test tool/render_screenshots_test.dart` renders the screenshots above.

## Project docs

- [`plan.md`](plan.md) — roadmap (Turkish)
- [`docs/game_design.md`](docs/game_design.md) — game design (Turkish)
- [`docs/adr/`](docs/adr/) — architecture decision records
- [`docs/devlog/`](docs/devlog/) — development log (Turkish)

## License

Source available for viewing only; all rights reserved. See [`LICENSE`](LICENSE).

The bundled fonts (Courier Prime, IBM Plex Sans) keep their own license, the SIL Open Font License 1.1
(`assets/fonts/*/OFL.txt`).
