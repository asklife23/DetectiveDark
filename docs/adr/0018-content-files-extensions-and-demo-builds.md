# 0018. Content files: multiple files per chapter, chapter extensions, demo builds

- **Status:** Accepted
- **Date:** 2026-11-14

## Context

A chapter folder holds one file per content type (`scenes.json`, `notes.json`, ...). Three problems appear
before the first real chapter is written:

- With 40–50 scenes, `scenes.json` becomes several thousand lines: hard to review and to edit.
- A later chapter changes places of an earlier one: a new hotspot in the villa hall, a new question for the
  pharmacist, a new line in a person's file. Editing the chapter 1 files for chapter 2 would ship paid
  content inside the free chapter and make chapter 1 depend on chapter 2.
- The Steam demo must be buildable with chapter 1 only.

These decisions shape the content files. Changing them after chapters have been written means rewriting
those files, so they are made now. They do not touch the save format.

## Decision

**One file or one folder per type.** In a chapter folder each type is either a single file (`scenes.json`)
or a folder (`scenes/*.json`); the same holds for the other catalogs, `dialogues` and `triggers`. Files are
listed from the asset manifest and read in name order. Having both the file and the folder is an error.
`dialogues` and `triggers` are optional.

**A later chapter extends earlier content in its own files:**

```json
"sceneExtensions": [{"scene": "villa_hall",
  "hotspots": [ ...new hotspots (appended)... ],
  "rules": [{"hotspot": "chest", "interactions": [ ...placed BEFORE the existing rules... ]}],
  "visualVariants": [ ...placed BEFORE the existing ones... ]}]
"dialogueExtensions": [{"dialogue": "pharmacist", "topics": [ ...appended... ]}]
"noteExtensions": [{"note": "person_pharmacist", "entries": [ ...appended... ]}]
```

- Extensions sit next to the normal list of the same type (`sceneExtensions` in a scenes file, and so on)
  and may only target content of an **earlier** chapter.
- New rules and visual variants go in front because the first matching rule wins: the newer chapter gets
  the first say. New hotspots, topics and entries are appended.
- Merging happens in the `data` layer. The domain sees one merged `CaseContent`; the save format is
  unchanged.
- Extensions are **not** switched on by the player's chapter. The author guards them with conditions. A
  "chapter reached" condition arrives with the chapter flow (phase 5.4).

**Missing chapters are skipped.** A chapter listed in `case.json` whose folder has no files in the bundle is
left out. A chapter that is only partly present is an error. Packaging a build without the paid chapters is
phase 11 work.

**Validation per prefix.** The content validation test validates every chapter prefix on its own (chapter
1; chapters 1–2; ...). An earlier chapter can therefore never depend on an ID, a flag or a text of a later
one, which is exactly what the demo build ships.

**Warnings.** The validator gets a second severity. Errors fail the test, warnings are reported. An unused
text key is a warning.

## Consequences

- Chapter files stay reviewable; a location can have its own file.
- Chapter 1 is frozen content once released: later chapters add to it from the outside.
- Content loading needs a file listing (asset manifest) instead of fixed paths, and `pubspec.yaml` must list
  every content folder.
- Extension order matters and is not visible in the extended file; the validator reports unknown targets
  and ID clashes, and the dev menu (phase 1b) helps to inspect the merged result.
- Hiding paid content from a free build relies on the files being absent, never on a flag in the save.
