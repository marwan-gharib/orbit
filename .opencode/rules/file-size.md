# File Size — maximum 300 lines per file (always loaded)

Short files are read, reviewed, and edited more reliably, by you and by the agent.

- FILE-1  No file may exceed 300 lines, counting blank lines and comments. It applies to every
          file you create or edit by hand: Dart (`lib` and `test`), markdown, JSON, YAML, scripts,
          text. The only exception is generated files nobody edits by hand (`*.g.dart`, slang
          output under `core/i18n/`, lock files).
- FILE-2  Split by responsibility BEFORE you report done. Never shrink blank lines or comments
          just to fit. How to split:
          - widgets: one public widget per file; a big `build()` becomes widget classes in
            `presentation/widgets/` (private helper widgets may share a file while it stays short);
          - Cubit/Bloc, usecase, model: split by concern, one class per file;
          - constants: a new file by purpose in `core/constants/` (ARCH-10);
          - tests: one test file per unit under test, mirroring `lib/` (TEST-5);
          - docs and notes: split by area and keep an index file.
          Do not use `part` / `part of` to dodge the limit. New files follow `folder-structure.md`.
          Splitting for FILE-1 is allowed and required: it is a pre-approved exception to CORE-8
          and CORE-9. Create the new files, move only the code you must, keep public names and
          behavior, keep the original file as the main one (no rename, no delete).
- FILE-3  An existing file that is already over 300 lines: do not make it longer. Put new code in a
          new file and touch the big file minimally (an import, one call site). An edit that keeps
          or shortens it is fine. Report `Noticed: <path> has <n> lines (FILE-1)`. Splitting the
          legacy file itself happens only on request (`/file-size`, `refactoring` skill).
- FILE-4  Before finishing, check every file you created or changed:
          `bash .opencode/scripts/check_rules.sh` (or `wc -l <files>`). Over the limit → split now.
