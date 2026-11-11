# 0002. State management with flutter_bloc

- **Status:** Accepted
- **Date:** 2026-11-11

## Context

The game is event-heavy: a tap on a hotspot resolves rules, applies effects, may start a transition,
change the inventory, add a note and make the detective speak. These flows must be predictable, easy to
trace while debugging and fully testable without widgets. Common options are `flutter_bloc`, Riverpod,
Provider/ChangeNotifier and signals.

## Decision

- Use **`flutter_bloc`** with **`equatable`**.
  - **Bloc** for complex event flows (e.g. `SceneBloc`: taps, back, transition phases).
  - **Cubit** for simple state (e.g. inventory selection, notebook tabs).
- States are immutable; Dart 3 `sealed class` hierarchies where a state has distinct shapes.
- Blocs know nothing about `BuildContext` or widgets; dependencies (use cases, repository interfaces) come
  through the constructor.
- Every Bloc/Cubit has `bloc_test` tests (with `mocktail` for dependencies).
- A global `BlocObserver` logs state changes and errors.

## Consequences

- Every state change is an explicit event → state transition: easy to log, replay in tests and explain.
- `bloc_test` makes the acceptance scenarios testable before any UI exists.
- More ceremony than ChangeNotifier for trivial state; Cubit keeps that cost low.
- Widely used in industry, which helps the project as a portfolio piece.
