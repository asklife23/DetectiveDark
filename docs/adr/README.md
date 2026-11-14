# Architecture decision records

Short records of the important technical decisions in DetectiveDark: what was decided, why, and what it
costs. A new decision gets a new file; an outdated one is not deleted — its status changes to
`Superseded by NNNN` and the new record links back to it.

| # | Decision | Status |
|---|---|---|
| [0001](0001-architecture.md) | Feature-first Clean Architecture | Accepted |
| [0002](0002-state-management.md) | State management with flutter_bloc | Accepted |
| [0003](0003-local-database.md) | Local save game with Drift (SQLite) | Accepted |
| [0004](0004-backend.md) | Supabase backend, FastAPI as a later option | Accepted |
| [0005](0005-anonymous-first-auth.md) | Anonymous-first authentication | Accepted |
| [0006](0006-sync-and-conflicts.md) | Cloud sync with revisions and explicit conflicts | Accepted |
| [0007](0007-scene-transitions.md) | Scene transitions: fades, no zoom | Accepted |
| [0008](0008-flavors.md) | dev / staging / prod flavors | Accepted |
| [0009](0009-platform-targets-and-services.md) | Platform targets and platform services | Accepted |
| [0010](0010-inspect-effect.md) | Inspect effect | Accepted |
| [0011](0011-overlay-text-noir-filter-and-ai-art.md) | Overlay text, shared noir filter and AI-assisted art | Accepted |
| [0012](0012-object-layer.md) | Object layer: hotspot sprites | Accepted |
| [0013](0013-rule-language-additions.md) | Rule language additions: conditions, first/then lines, chat log cap | Accepted |
| [0014](0014-single-effect-pipeline-and-triggers.md) | Single effect pipeline and triggers | Accepted |
| [0015](0015-note-entries-and-people.md) | Note entries and the People category | Accepted |
| [0016](0016-dialogue-showing-evidence-giving-items.md) | Dialogue system, showing evidence and giving items | Accepted |
| [0017](0017-travel-without-a-map.md) | Travel between locations without a map | Accepted |
| [0018](0018-content-files-extensions-and-demo-builds.md) | Content files: multiple files per chapter, chapter extensions, demo builds | Accepted |

## Template

```markdown
# NNNN. Title

- **Status:** Proposed | Accepted | Superseded by NNNN
- **Date:** YYYY-MM-DD

## Context
The problem and the forces at play.

## Decision
What we do.

## Consequences
What becomes easier, what becomes harder, what we accept.
```
