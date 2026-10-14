# `core/animations` — Orbit's animation foundation

One import gives every feature its motion:

```dart
import 'package:orbit/core/animations/animations.dart';
```

Interactive gallery of everything below: `lib/dev/animations_showcase_page.dart`.

## The token system

Widgets never hardcode a duration, curve or magic number — they read it from
one of the three token classes, so the whole motion profile is retuned in one
place:

| Token class             | Holds                                                                  |
|-------------------------|------------------------------------------------------------------------|
| `AppDurations`          | `fast` (150ms), `normal` (300ms), `slow` (500ms), `stagger` (50ms), plus loading loops (`shimmer`, `pulse`, `indeterminate`) and `messageVisible` |
| `AppCurves`             | `standard`, `enter` (content arriving), `exit` (content leaving), `spring`, `bounce`, `linear`, `pulse` |
| `AppAnimationConstants` | Numeric constants: slide offsets, scale bounds, skeleton sizes, amplitudes, thresholds |

```dart
// Passing a token — never a Duration(...):
FadeIn(delay: AppDurations.stagger * index, child: row)
```

## Cheat sheet

### Entrance — plays once on first build, never replays on rebuild

```dart
const Text('Saved').fadeIn()
const DrawerPanel().slideIn()                    // rises from the bottom
SlideIn.fromStart(child: panel)                  // leading edge; mirrors in RTL
const Icon(Icons.check).scaleIn()
Card(child: chart).fadeSlideIn(delay: AppDurations.stagger * index)
AlertDialog(...).blurIn()                        // dialogs and overlay content
```

The `.fadeSlideIn()`, `.fadeIn()`, `.slideIn()`, `.scaleIn()` and `.blurIn()`
methods come from the `WidgetAnimations` extension (same defaults, less
wrapping); anything more (duration, curve, offset, other edges) is the widget
itself.

### Staggered — index-delayed entrances for lists and grids, no replay on scroll-back

```dart
StaggeredColumn(children: [kpiRow, chart, recentOrders])

ListView.builder(
  itemCount: orders.length,
  itemBuilder: (context, index) =>
      OrderRow(order: orders[index]).staggered(index: index),
)

GridView.builder(
  itemBuilder: (context, i) =>
      KpiCard(kpi: kpis[i]).staggered(index: i ~/ 2), // one delay per row
)
```

### Feedback — interaction motion (press, shake, pulse, bounce)

```dart
FilledButton(...).tapScale(onTap: submit, haptic: HapticType.light)

final shake = ShakeController();
LoginForm().shake(shake, haptic: true);  // shake.shake() from a BlocListener
Badge(count: n).pulse();                 // loops while active, stops when off
final bounce = BounceController();
RowIcon().bounce(bounce);                // bounce.bounce() from a BlocListener

AppHaptics.light();                      // all haptics through one kill switch
```

`trigger:` counters (`ShakeWidget(trigger: state.shakeTrigger)`) are the
state-driven alternative to controllers — let the Cubit bump the counter.

### Loading — skeletons, placeholders, progress

```dart
ShimmerScope(                       // one ticker sweeps every box inside
  child: Column(children: [
    const SkeletonListTile(),
    const SkeletonCard(),
    ShimmerBox.textLine(width: 180),
  ]),
)

PulsingPlaceholder.circle(width: 40)   // cheaper in long lists
PulsingPlaceholder.textLine(width: 200)

AnimatedProgressBar(progress: report.progress)  // determinate
AnimatedProgressBar()                           // indeterminate
```

### State — transitions between loading, content, error, expanded, visible

```dart
AppAnimatedSwitcher(                // cross-fade + scale between states
  child: KeyedSubtree(
    key: ValueKey(state.runtimeType),
    child: switch (state) { /* loading | content | error | empty */ },
  ),
)

AnimatedVisibility(visible: showBanner, child: const PromoBanner())
AnimatedSizeWrapper(child: showDetails ? const Details() : const SizedBox.shrink())
AnimatedCounter(value: total, locale: Localizations.localeOf(context))
ExpandableSection(header: Text(t.filters), body: const FiltersPanel())
```

### Overlays — one motion profile for every modal surface

```dart
await AppDialog.show<bool>(context: context, builder: (_) => const Confirm());
await AppBottomSheet.show<ProjectFilter>(context: context, builder: (_) => sheet);
await AppSnackbar.show(context, message: t.saved, type: AppSnackbarType.success);
AppPopupMenu<String>(onSelected: run, items: [...]);   // anchored dropdown

showDialog(context: context, animationStyle: AppOverlayMotion.modalOf(context), ...)
```

### Scroll — driven by the nearest scroll position

```dart
ReportCard().revealOnScroll()                     // fades in entering the viewport
ParallaxWidget(child: Image.network(cover, fit: BoxFit.cover))  // slower background

CustomScrollView(slivers: [
  CollapsingHeader(expandedHeight: 220, title: Text(t.profile), background: photo),
  ...
])

AppBarFadeOnScroll(child: FadeOnScrollBar(backgroundColor: scheme.surface, child: bar))
```

### Navigation — one default for every route

```dart
GoRouter(
  routes: [
    AppRoute.create(path: RoutePaths.orders, builder: (_, _) => const OrdersScreen()),
    AppRoute.create(path: RoutePaths.orderDetails, transition: AppPageTransition.slide, builder: ...),
  ],
)
```

`AppHero` and `AppContainerTransform` fly a shared element between routes.

### Lottie — the only place the `lottie` package is wrapped

```dart
AppLottie.success(size: 96, onCompleted: () => Navigator.of(context).pop());
AppLottie.loading(size: 24);
AppLottie.error(size: 64, fallback: const SizedBox.shrink());
AppLottie.asset(AppLottieAssets.onboarding(1), repeat: false);
```

Files live in `assets/animations/`; paths come from `AppLottieAssets`.

## Rules the foundation keeps for you

- **Reduce motion.** Every animated widget checks
  `MediaQuery.disableAnimations` and renders the final state immediately.
- **RTL.** Horizontal motion mirrors through `Directionality`; use
  `fromStart`/`fromEnd`/`AlignmentDirectional`, never left/right.
- **Rebuild safety.** Entrances play once; a parent rebuild never replays
  them. Looping widgets (shimmer, pulse) own and dispose their controllers.
- **Performance.** Animated subtrees are built once and passed via `child`;
  skeletons paint inside one `RepaintBoundary` per scope.

## Do / don't

- **Do** stagger list entrances with `AppDurations.stagger * index`; keep
  durations in the 150–300ms band (`fast`/`normal`).
- **Do** wrap a whole skeleton screen in one `ShimmerScope`; use
  `PulsingPlaceholder` inside long scrolling lists.
- **Do** fire feedback from state (`trigger:` counters or controllers in a
  `BlocListener`), not from `build`.
- **Don't** animate every list item on every visit — staggered entrances are
  one-shot; `RevealOnScroll` is for content that scrolls into view once.
- **Don't** write `Duration(...)`, `Curves.*` or bare numbers in a widget —
  add or use a token instead.
- **Don't** nest shimmer scopes, stack `ExpandableSection`s of the same
  panel, or use `slow` inside lists.
