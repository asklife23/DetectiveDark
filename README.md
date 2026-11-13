# DetectiveDark

[![CI](https://github.com/asklife23/DetectiveDark/actions/workflows/ci.yml/badge.svg)](https://github.com/asklife23/DetectiveDark/actions/workflows/ci.yml)

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
| Localization | `gen-l10n` (ARB); English at launch, new languages by adding files |
| Fonts | Courier Prime + IBM Plex Sans (bundled, OFL, Latin Extended) |
| Local storage | Drift (SQLite) — planned (Phase 2) |
| Backend | Supabase (Auth, Postgres + RLS, Edge Functions) — planned (Phase 3) |
| CI | GitHub Actions (format, analyze, test, Windows build, Android build) |

## Architecture

_Diagram and overview coming in Phase 1._

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
dart format .
flutter analyze
flutter test
```

## Project docs

- [`plan.md`](plan.md) — roadmap (Turkish)
- [`docs/game_design.md`](docs/game_design.md) — game design (Turkish)
- [`docs/adr/`](docs/adr/) — architecture decision records
- [`docs/devlog/`](docs/devlog/) — development log (Turkish)

## License

_To be decided._
