---
name: performance-audit
description: Find and fix Flutter performance problems with measurement first - unnecessary rebuilds, heavy build methods, list and image handling, main-thread work, memory leaks, startup and network cost. Use when the app is janky, slow to start, uses too much memory, or when asked to optimize or audit performance.
metadata:
  opencode/slash: "true"
---

# Performance Audit

Measure first. Do not optimize without evidence. Premature optimization adds complexity for nothing.

## When to use
Jank, slow screens, slow startup, memory growth, battery complaints, "optimize this", before a release.

## Procedure

1. **Measure.** Run in profile mode on a real, ideally low-end device: `flutter run --profile`.
   Use DevTools: Performance (frame times, jank), CPU profiler, Memory, and Widget rebuild counts.
   Record the baseline numbers before changing anything.
2. **Locate the bottleneck.** UI thread (build, layout) or raster thread (painting, shaders, images)? Startup? Network?
3. **Fix the top cause only.** Re-measure. Keep the change only if the numbers improve.
4. **Record** the before and after in the report. Note non-obvious decisions in `FEATURE.md` section 10.

## Checklist by area

**Core first**
- Loading uses the core skeletons and `ShimmerScope`; motion comes from `core/animations/` (they honour `disableAnimations`).
- Never fix jank by writing a custom animation or caching layout numbers in a feature (ANIM-3, RESP-3).

**Rebuilds**
- `const` constructors and widgets everywhere possible.
- Split large widgets into classes so a rebuild touches a small subtree (UI-8).
- `BlocSelector` or `buildWhen` when only part of a state matters (STATE-8).
- No object, Cubit, controller, or future creation inside `build()`.

**Lists and scrolling**
- `ListView.builder` / slivers for long lists (UI-8). Stable `key`s on reorderable or changing items.
- Paginate instead of loading everything (DATA-7). Avoid `shrinkWrap: true` on long lists.

**Images**
- Decode at display size (`cacheWidth` / `cacheHeight`), use an image-caching mechanism that already exists in the project, avoid huge assets.

**Main thread**
- Heavy JSON parsing, sorting, or crypto on big data: move to an isolate (`Isolate.run` / `compute`).
- No synchronous file or storage work in `build()` or during animations.

**Painting**
- `RepaintBoundary` around frequently animating subtrees. Avoid `Opacity` on large trees (prefer `AnimatedOpacity` or `FadeTransition`), and avoid `saveLayer`-heavy effects.

**Memory**
- Dispose controllers, focus nodes, animation controllers, and stream subscriptions. Cancel timers. Close Cubits (provided via `BlocProvider`) (STATE-6, UI-9).

**Startup**
- Lazy registration in DI (`registerLazySingleton`, DI-3). Defer non-critical init until after the first frame.

**Network**
- Debounce search input (a Bloc case, STATE-1), cache per repository policy (DATA-8), avoid duplicate in-flight requests, paginate.

## Report format
```text
Baseline: <metric and value>
Bottleneck: <what and where, with evidence>
Change: <what was changed>
After: <metric and value>
Not changed (no evidence): <items>
```

## Precedence
`AGENTS.md` and `.opencode/rules/` override this skill. On conflict, cite the rule ID and follow the rule.
