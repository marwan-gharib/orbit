---
description: Audit files over 300 lines; split one when a path is given
---
Target (optional path): $ARGUMENTS

Files over the limit:
!`find lib test docs .opencode -type f ! -name '*.g.dart' ! -path 'lib/core/i18n/*' -exec wc -l {} + 2>/dev/null | awk '$1>300 && $2!="total"' | sort -rn | head -40`

1. Load `file-size` and the skill `refactoring`.
2. No target: report the list above, grouped by folder, with the suggested split for each (one public
   widget per file, helpers to their own file, state/model split). Edit nothing.
3. With a target: split that file into files of 300 lines or fewer, one concern per file (FILE-2),
   updating every import, with behavior unchanged. Run tests and the Definition of Done. Update `FEATURE.md` (file map).
   No release-note item (no tester-visible change).
