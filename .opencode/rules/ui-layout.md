# UI Layout Quality — RTL, overflow, accessibility, structure

Sizes come from tokens and `Responsive` (`responsive.md`). This file covers how layouts behave.

- UI-5  RTL-safe: use `EdgeInsetsDirectional`, `AlignmentDirectional`, `start`/`end`,
        `PositionedDirectional`. Never `left`/`right` for layout. Mirror directional icons.
- UI-6  Overflow-safe: no fixed height on a container that holds text; use flexible layouts
        (`Expanded`, `Flexible`, `Wrap`, constraints). Must not overflow on small screens or at
        a large font scale.
- UI-7  Accessibility: every interactive element has a localized semantic label or tooltip and a
        tap target of at least `kMinInteractiveDimension` (scaled sizes must never shrink it).
- UI-8  Widget structure and performance:
        - Build UI from small `StatelessWidget` classes, not helper methods returning widgets;
          one public widget per file (FILE-2).
        - Use `const` constructors and widgets wherever possible.
        - Lists use `ListView.builder` / slivers; never build large lists eagerly.
        - Widgets contain no business logic (ARCH-2) and no data fetching in `build()`.
- UI-9  After any `await` in a widget, check `if (!context.mounted) return;` before using
        `context`. Dispose the text, scroll, and focus controllers you create. Animation
        controllers exist only inside `core/animations/` (ANIM-2).
