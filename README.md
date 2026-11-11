# DetectiveDark

A noir, 2.5D point-and-click detective game for Android, iOS and Steam (Windows), built with Flutter.

Explore moody, hand-crafted scenes, tap on details others would miss, collect items and
documents, crack the puzzles and convince the police with the evidence you found.

> 🚧 Work in progress. See [`plan.md`](plan.md) for the roadmap.

## Features

_Coming soon._

## Tech stack

| Area | Choice |
|---|---|
| Framework | Flutter (Dart 3) |
| Platforms | Android, iOS, Windows (Steam) |
| Architecture | Feature-first Clean Architecture |
| State management | `flutter_bloc` + `equatable` |
| Dependency injection | `get_it` |
| Routing | `go_router` (app screens), scene navigation stack (in-game) |
| Local storage | Drift (SQLite) |
| Backend | Supabase (Auth, Postgres + RLS, Edge Functions) |
| CI | GitHub Actions |

## Architecture

_Diagram and overview coming in Phase 1._

## Getting started

### Requirements

- Flutter 3.44 (stable) / Dart 3.12
- Android SDK (Android Studio)
- Visual Studio with "Desktop development with C++" (for the Windows build)

### Run

```bash
flutter pub get
flutter run
```

Flavors (`dev` / `staging` / `prod`) and environment files are introduced in step 0.3.

### Quality checks

```bash
dart format .
flutter analyze
flutter test
```

## Project docs

- [`plan.md`](plan.md) — roadmap (Turkish)
- [`docs/game_design.md`](docs/game_design.md) — game design (Turkish)
- `docs/adr/` — architecture decision records
- `docs/devlog/` — development log (Turkish)

## License

_To be decided._
