---
description: Before building, list which core pieces to reuse and what core lacks (read-only)
---
Need: $ARGUMENTS

Read-only. Do not write or edit anything.
1. Read `.opencode/rules/core-first.md`, `docs/CORE_MAP.md`, then the barrels and READMEs of the
   core areas relevant to the need (`core/widgets/widgets.dart`, `core/animations/README.md`,
   `core/responsive/responsive.dart`, constants, router, errors, network).
2. Also check whether a feature already has a similar widget: `grep -ril "<name>" lib/features`.
3. Answer in exactly this shape:
   - Reuse: `<core piece>` → what it does for this need (real names only, verified in the files)
   - Compose: combinations of core pieces that cover a part of the need
   - Gap: what core lacks, and where it should be built (feature widget, or approved core extension)
   - Promote: feature widgets that should move to `core/widgets/` (WIDGET-3)
4. Never invent a name. If you cannot verify it in a file, say so.
