---
description: Build or reshape one screen from core widgets, core animations, and the responsive system
---
Screen: $ARGUMENTS

1. Load the rule files of the "New screen / widget / UI change" row and the skills `ui-from-core`, `clean-code`.
   Read `docs/CORE_MAP.md`, `core/widgets/widgets.dart`, `core/animations/README.md`, `core/responsive/responsive.dart`,
   and the feature's `FEATURE.md`. Print `Rules loaded:`, `Skills loaded:`, `Core reuse: ... | Core gap: ...`.
2. List in one short block: the core widgets, animations, and responsive helpers you will use, and
   any widget core lacks. A missing widget is built in the feature (WIDGET-2); one that another feature
   already has is promoted first (WIDGET-5). Then continue unless something blocks (ask ONE question).
3. Build the screen: state-driven with `AppAnimatedSwitcher` over loading / content / empty / error
   (ANIM-4), text from i18n, colors from the theme, every size via tokens or `Responsive`, one
   public widget per file, no file over 300 lines.
4. Add widget tests with `ResponsiveScope` at two sizes and a large text scale (TEST-8).
5. Update `FEATURE.md`, add the `testers_release_note.txt` item, run the Definition of Done, report (CORE-23).
