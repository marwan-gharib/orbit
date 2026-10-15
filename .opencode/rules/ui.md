# UI, Theming, Localization

## Theming and shared UI

- UI-1  All styling comes from `Theme.of(context)`: colors from a `ThemeExtension`
        (e.g. `AppColorsExtension`), text from `theme.textTheme`. A widget never references a
        raw `AppColors` / `AppTextStyles` constant, a hex color, or a hardcoded `TextStyle`.
- UI-2  Reuse `core/widgets/` (`AppButton`, `AppTextField`, `AppLoader`, `AppSnackBar`...).
        Check `docs/CORE_MAP.md` first. Never re-implement a shared component. A component
        needed by 2+ features is added to `core/widgets/`.
- UI-3  Any `context` access used in 2+ places is wrapped in a `BuildContext` extension
        (`core/extensions/`).

## Localization

- UI-4  No hardcoded user-facing string, ever (including semantics labels, tooltips,
        dialog text, snackbars). Use `context.t.<feature>.<key>`.
        Add keys to **every** `assets/i18n/*.json`, then run `dart run slang`.
        Never edit slang's generated output.

## Layout quality

- UI-5  RTL-safe: use `EdgeInsetsDirectional`, `AlignmentDirectional`, `start`/`end`,
        `PositionedDirectional`. Never `left`/`right` for layout. Mirror directional icons.
- UI-6  Responsive and text-scale safe: no fixed heights on containers holding text; use
        flexible layouts (`Expanded`, `Flexible`, `Wrap`, constraints). Must not overflow on
        small screens or large font scale.
- UI-7  Accessibility: every interactive element has a localized semantic label or tooltip
        and a tap target of at least 48x48.

## Widget structure and performance

- UI-8  - Build UI from small `StatelessWidget` classes, not helper methods returning widgets.
        - Use `const` constructors/widgets wherever possible.
        - Lists use `ListView.builder` / slivers; never build large lists eagerly.
        - Widgets contain no business logic (ARCH-2) and no data fetching in `build()`.
- UI-9  After any `await` in a widget, check `if (!context.mounted) return;` before using
        `context`. Dispose controllers, focus nodes, and animation controllers.
