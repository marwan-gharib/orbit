# UI Foundation — theme, shared components, context helpers, localization

Also read for UI work: `core-first.md` (always loaded), `widgets.md`, `responsive.md`,
`animations.md`, `ui-layout.md`.

## Theme and shared UI

- UI-1  All styling comes from the theme. Colors: `context.colors` (`AppColorsExtension`).
        Text: `context.textStyles` (`AppTextStylesExtension`) or `Theme.of(context).textTheme`.
        Spacing and radius: `AppSpacing` and `AppRadius` (they scale through `Responsive`).
        A widget never references the raw palette `AppColors` or the raw type scale
        `AppTextStyles`, a hex color, `Color(0x...)`, `Colors.*` (except `Colors.transparent`),
        or a hand-built `TextStyle`.
- UI-2  Shared components come from `core/widgets/` and `core/animations/` and are chosen by the
        core-first and widget rules (`core-first.md` BASE-3, `widgets.md`). Check
        `docs/CORE_MAP.md` first. Never re-implement a shared component.
- UI-3  Any `context` access used in 2+ places is wrapped in a `BuildContext` extension
        (`core/extensions/`). Check the existing extensions first (BASE-1).

## Localization

- UI-4  No hardcoded user-facing string, ever (including semantics labels, tooltips,
        dialog text, snackbars). Use `context.t.<feature>.<key>`.
        Add keys to **every** `assets/i18n/*.json`, then run `dart run slang`.
        Never edit slang's generated output (`core/i18n/`).
