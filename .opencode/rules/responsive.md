# Responsive — all UI is built on `core/responsive/`

`core/responsive/` is the app's single responsive system (the `Responsive` facade,
`ResponsiveScope`, and the scalers). `AppTheme` already routes font sizes, spacing, and radius
through it, so theme tokens are responsive by construction.

- RESP-1  Before writing any widget, read `core/responsive/responsive.dart` and use only the API it
          exposes (width, height, radius, font, and adapt scaling, plus the responsive helpers on
          the `BuildContext` extension). Never guess a method name (CORE-7).
- RESP-2  Every UI dimension is a theme token or goes through `Responsive`: width, height, padding,
          margin, gap, radius, icon size, font size, border width, constraints. A bare number is
          not allowed. Bare numbers stay fine for non-sizes: `0`, `flex`, aspect ratios, opacity and
          other 0..1 fractions, counts, and indexes. Prefer the tokens (`AppSpacing`, `AppRadius`,
          text styles) and use `Responsive` for any other size. A size that repeats becomes a
          named constant next to its widget, still passed through `Responsive`.
- RESP-3  Screen size, orientation, and breakpoints come only from the core responsive helpers.
          Features never use `MediaQuery.of(context).size`, `MediaQuery.sizeOf`, `Platform` checks, or
          `LayoutBuilder` thresholds with magic numbers for layout. If the helper you need does not
          exist, stop and ask: the responsive system changes only on explicit request (BASE-6).
- RESP-4  No scaling or responsive package is imported outside `core/responsive/` (the package
          behind `ScreenUtilScaler`, `sizer`, `responsive_framework`, and similar). ARCH-5.
- RESP-5  `ResponsiveScope` wraps `MaterialApp` once, in `main.dart`. A feature never wraps it
          again. Widget tests must provide it (TEST-8).
- RESP-6  Layouts adapt, not only scale. A screen stays usable on a small phone, a large phone, and
          a tablet width, and at a large font scale: no overflow (UI-6), content scrolls when it
          must, and the widget tests cover two surface sizes (TEST-8).
