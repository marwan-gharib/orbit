---
name: ui-from-core
description: Build or change any Flutter UI (screen, widget, layout, loading or empty state, dialog, animation) strictly on this project's lib/core - core widgets first, core animations only, core/responsive for every size, theme tokens and i18n for style and text. Use before writing or editing any widget code, or when asked to build a screen, make a layout responsive, or add motion.
---

# UI from Core

Every pixel of UI is assembled from `lib/core/`. You compose; you do not invent. Rules:
`core-first.md` (BASE), `widgets.md` (WIDGET), `responsive.md` (RESP), `animations.md` (ANIM),
`ui-foundation.md`, `ui-layout.md`. Rules always win over this skill.

## When to use
Any widget or screen work, loading/empty/error states, dialogs and sheets, motion, responsiveness.

## Procedure

1. **Read the base (BASE-1).** `docs/CORE_MAP.md`, `core/widgets/widgets.dart`,
   `core/animations/README.md`, `core/responsive/responsive.dart`. Open the file of every piece you
   will call to confirm its constructor (CORE-7).
2. **Map the design to core, before coding.** For each element write the core piece you will use:

   | Need | Look in core first |
   |---|---|
   | Button, text field, card, badge, empty/error state, dialogs | `core/widgets/` (`AppButton`, `AppTextField`, `AppCard`, `StatusBadge`, `EmptyState`, `ErrorState`, `AppDialog`, `ConfirmDialog`) |
   | Entrance, list stagger, tap feedback, state change, loading, overlays, scroll, route, hero | `core/animations/` (facade `.fadeIn()` etc., `AppAnimatedSwitcher`, `Staggered*`, `ShimmerScope`, `AppRoute.create`, `AppHero`, `AppHaptics`) |
   | Any size, gap, radius, font, breakpoint | theme tokens (`AppSpacing`, `AppRadius`, `context.textStyles`) then `core/responsive/` |
   | Colors, text styles | `context.colors`, `context.textStyles` |
   | Text | slang (`context.t...`), failures via `context.failureText` |
3. **A piece is missing?** Search other features (`grep -ril`, `FEATURES_INDEX.md`). Found → promote
   it (WIDGET-3, `/promote-widget`). Not found → compose core pieces first; if still missing, build
   it in the feature (`presentation/widgets/`, one public widget per file, WIDGET-2), from core pieces,
   and list it in `FEATURE.md` section 3. Motion missing → compose, else STOP and ask (ANIM-3).
4. **Build.**
   - State-driven screens switch loading / content / empty / error through `AppAnimatedSwitcher` (ANIM-4).
   - No bare numbers for sizes (RESP-2); sizes and breakpoints only via tokens and `Responsive`.
   - No `Animation*`, `Hero`, `showDialog`, `Navigator`, `HapticFeedback`, `Curves` in features (ANIM-2).
   - Directional layout (`start`/`end`) for RTL; scrolls rather than overflows; touch targets and semantics (UI-5..7).
   - Split before 300 lines: one public widget per file, `build()` extracted into widget classes (FILE-1, UI-8).
5. **Test (TEST-8).** Wrap with `ResponsiveScope`, pump two surface sizes and a large text scale,
   check every state.
6. **Check.** `bash .opencode/scripts/check_rules.sh`. Then update `FEATURE.md` and the tester note.

## Before / after

```dart
// Before: raw widgets, bare numbers, custom motion
Container(width: 320, padding: const EdgeInsets.all(16),
  child: AnimatedOpacity(opacity: v, duration: const Duration(milliseconds: 300), child: ...));

// After: core card, token spacing, core animation (ADAPT parameter names to core)
AppCard(child: content).fadeIn()
```

## Precedence
`AGENTS.md` and `.opencode/rules/` override this skill. On conflict, cite the rule ID and follow the rule.
