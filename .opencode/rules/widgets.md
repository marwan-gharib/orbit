# Widgets — core first, feature widget only if missing, promote when reused

Read with `core-first.md` (BASE-1..6), `responsive.md`, `animations.md`, `ui-foundation.md`.

- WIDGET-1  Compose every screen from `core/widgets/` first. Read the barrel
            `core/widgets/widgets.dart` and `docs/CORE_MAP.md` (BASE-1). When a core component
            exists for the job, use it and choose its variant instead of building a lookalike
            (BASE-3). Plain layout primitives (`Scaffold`, `Column`, `Row`, `Stack`, `ListView`,
            `Text`...) are fine.
- WIDGET-2  A widget that core does not have is created inside the feature that needs it:
            `features/<feature>/presentation/widgets/`, one public widget per file (FILE-2).
            Build it from core pieces (tokens, `Responsive`, core widgets, core animations). It has
            no business logic, no Cubit creation, no `getIt`; data comes through constructor
            parameters and callbacks. Record it (name + one line) in that feature's `FEATURE.md`
            section 3 so other features can find it.
- WIDGET-3  Promotion. The moment a second feature (or core code) needs a widget that lives in a
            feature, promote it in the same task. Never import it across features (ARCH-1) and
            never copy it. Steps:
            1. Move it to `core/widgets/<snake_name>.dart` and export it from
               `core/widgets/widgets.dart`. Delete the old file and update every importer
               (pre-approved by this rule, CORE-9).
            2. Generalize it so it is multi-use: remove feature-specific imports, entities, view
               models, Cubits, i18n keys, and constants. Take everything through constructor
               parameters and callbacks. Text comes from the caller (localized at the call site).
               Add optional parameters or variants whose defaults keep the original feature
               unchanged. Keep theme, `Responsive`, and core-animation usage.
            3. Update the original feature to use the promoted widget; its look and behavior
               stay the same.
            4. Move and adapt its tests to `test/core/widgets/` (TEST-5) and add a test for each
               new option.
            5. Update `docs/CORE_MAP.md` (Shared widgets) and both features' `FEATURE.md`
               (file map, Depends on `core/widgets`, changelog).
- WIDGET-4  Core widgets stay backward compatible. Changing one is additive (BASE-5): new optional
            parameters or variants only, existing callers untouched, tests added. A breaking
            change needs approval.
- WIDGET-5  Before creating a widget in a feature, check whether another feature already has a
            similar one (`docs/FEATURES_INDEX.md` → the other `FEATURE.md` file maps, or
            `grep -ril <name> lib/features`). Found → promote it (WIDGET-3), do not write a second one.
- WIDGET-6  Every widget honours the base: sizes via tokens and `Responsive` (RESP-2), motion via
            core (ANIM-1), text via i18n (UI-4), colors via the theme (UI-1).
