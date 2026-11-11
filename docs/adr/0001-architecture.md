# 0001. Feature-first Clean Architecture

- **Status:** Accepted
- **Date:** 2026-11-11

## Context

DetectiveDark will grow to hundreds of scenes, puzzles, a save system, cloud sync, store purchases and
two platform families (mobile stores and Steam). Some infrastructure is expected to change later — the
backend may move from Supabase to a custom FastAPI service, and purchases and saves work differently on
mobile and on Steam. The project is also a portfolio piece, so the structure itself must be easy to read
and to test.

## Decision

- **Feature-first folders** under `lib/features/` (`scene_engine`, `inventory`, `notebook`,
  `detective_chat`, `progress`, `auth`, `sync`, ...), plus `lib/core/` for shared infrastructure and
  `lib/app/` for composition.
- **Three layers per feature:** `domain` (entities, abstract repositories, use cases; pure Dart, only
  `equatable`), `data` (data sources, DTOs, repository implementations) and `presentation` (blocs, pages,
  widgets).
- **Dependency rules:** `data → domain`, `presentation → domain`; presentation never imports data. A feature
  may import only another feature's `domain`. Only `app/` combines presentation layers of different
  features (e.g. `GameScreen`).
- **Cross-feature events** flow through a `GameEventBus` of sealed `GameEvent`s in `core/events`.
- **Errors:** the data layer catches exceptions and returns `Result<T>` (`Success` / `Failed` with a sealed
  `Failure`); the UI never sees raw exceptions.
- **Single source of truth** for game state: `ProgressRepository`.
- **Platform services** (purchases, accounts, cloud saves) sit behind domain interfaces; the build target
  picks the implementation in DI. Game code never checks `Platform.isX`.
- **DI** with `get_it`, registered per feature in `core/di/`; **routing** with `go_router` for app screens
  only (in-game scene changes are a navigation stack in `SceneBloc`, not routes).

## Consequences

- Domain logic (the interaction resolver, migrations, sync rules) is plain Dart and unit-testable without
  Flutter.
- Replacing a backend or a platform service touches one `data` implementation and one DI line.
- More files and some boilerplate (DTO ↔ entity mapping, repository interfaces) than a flat structure.
- The rules must be kept by discipline and review; they are written down in `CLAUDE.md` section 3.
