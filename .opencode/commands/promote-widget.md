---
description: Promote a feature widget to core/widgets/ and generalize it (WIDGET-3)
---
Widget to promote: $ARGUMENTS

1. Load `widgets`, `architecture`, `folder-structure`, `testing`, `feature-docs`, `core-first`, `responsive`,
   `animations`, and the skills `ui-from-core`, `clean-code`. Print `Rules loaded:` and `Skills loaded:`.
2. Find the widget and every feature that uses or needs it (`grep -rn`). Show the list in one block.
3. Follow WIDGET-3 steps 1..5 exactly: move to `core/widgets/<snake_name>.dart` and export it from
   `widgets.dart`; generalize with constructor parameters and callbacks only (no feature imports, no
   Cubits, no i18n keys, no constants of the feature); keep the first feature looking and behaving the same;
   use the promoted widget in the second feature; move and extend tests to `test/core/widgets/`;
   update `docs/CORE_MAP.md` and both `FEATURE.md` files.
4. Run the Definition of Done and `@reviewer`.
5. Add a `testers_release_note.txt` item for each screen that now uses the shared widget (what to check).
6. Report with the format in CORE-23.
