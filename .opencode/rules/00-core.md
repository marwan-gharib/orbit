# 00 — Core Rules: start protocol, working agreement, workflow (always loaded)

Rule IDs are stable. Cite them (e.g. `ARCH-3`) when explaining a decision or flagging a conflict.
Other always-loaded files: `00-style.md`, `00-done.md`, `core-first.md`, `file-size.md`, `release-notes.md`.

## A. Task start protocol (mandatory, in this order)

- CORE-1  Classify the task with the routing table in `AGENTS.md`.
- CORE-2  Read `docs/FEATURES_INDEX.md`, then the target feature's `FEATURE.md`.
          Read source files only after that, and only the ones you need.
- CORE-3  Read every rule file the routing table requires, and `docs/CORE_MAP.md` plus the core
          files you will use (BASE-1). Never work from memory.
- CORE-4  When creating anything new, read the reference feature and mirror it.
- CORE-5  Before the first edit print exactly these three lines (always-loaded rule files are
          implicit, list only the routed ones):
          ```text
          Rules loaded: <routed rule file names>
          Skills loaded: <names> | none
          Core reuse: <core pieces you will use> | Core gap: <what core lacks, where you create it>
          ```
          Several task types apply → load the union.

## B. Working agreement

- CORE-6  Ambiguity that blocks correct work → ask ONE focused question before coding.
          Ambiguity that does not block → choose the conservative option and state it as a single
          `Assumption:` line. No assumptions → print nothing.
- CORE-7  Never guess a file path, class name, parameter name, or API. Search or read it, or ask.
- CORE-8  Smallest change that solves the problem. No drive-by refactor, rename, or reformat of
          untouched code. The only structural exceptions are pre-approved by a rule:
          BASE-5 (additive core extension), WIDGET-3 (promotion), FILE-2 (splitting).
- CORE-9  Never rename, move, or delete files without explicit instruction. Same exceptions as
          CORE-8: WIDGET-3 may move and delete the promoted widget's old file; FILE-2 only creates files.
- CORE-10 Never modify `pubspec.yaml`, `analysis_options.yaml`, generated files, `android/`,
          `ios/`, or env files without explicit approval. A new package is never added;
          propose it and wait.
- CORE-11 If a request conflicts with a rule, name the rule ID and ask. Do not silently
          override it and do not silently comply.
- CORE-12 Legacy code that violates these rules: follow the rules in new and changed code only,
          leave the rest alone, report it under `Noticed:`. Over-limit legacy files: FILE-3.
- CORE-13 Never run `git commit` / `git push` (both are denied in `opencode.json`). When the user
          asks, prepare the commit message, branch name, or PR text with the `git-workflow`
          skill and let the user run git.

## C. Workflow per change

1. Task start protocol (section A), including the core check (BASE-1).
2. Read the code you will touch.
3. Apply the smallest correct change, layer by layer in this order:
   constants → domain → data → presentation → DI → route → i18n → tests → docs → release note.
4. Run the Definition of Done (`00-done.md`, section G).
5. Run the self-review checklist (`00-done.md`, section H).
6. Report using the format in `00-style.md` (CORE-23).
