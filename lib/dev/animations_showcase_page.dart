// Developer-only animation showcase for `core/animations`.
//
// It is not part of the shipped app and is never registered in the
// production router. Two rule exceptions were approved for this file
// (asked and confirmed by the project owner):
// - UI-4 (no hardcoded user-facing strings): every label here is developer
//   English; none of it ships to users, so no slang keys exist for it.
// - H-5 (navigation through go_router): the Navigation section pushes demo
//   pages with `Navigator.of(context).push` to exercise `AppPageTransitions`
//   visually — the same mechanism go_router uses internally.
//
// How to open: push `AnimationsShowcasePage` from a debug menu, or run
// `runApp(const MaterialApp(home: AnimationsShowcasePage()))` from a dev
// entry point.
//
// Toggles: "RTL layout" flips `Directionality` for the content below, and
// "Disable animations" sets `MediaQuery.disableAnimations` for it. Overlay
// *entrance* styles are read at the call site, so dialogs, sheets and
// snackbars honour the toggle too; their inner content is built by route
// entries above this page and follows the app-level settings instead.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/animations/animations.dart';

/// Dev screen with one section per animation group: entrance, staggered,
/// feedback, loading, state, navigation, overlays, scroll and lottie.
class AnimationsShowcasePage extends StatefulWidget {
  const AnimationsShowcasePage({super.key});

  @override
  State<AnimationsShowcasePage> createState() => _AnimationsShowcasePageState();
}

class _AnimationsShowcasePageState extends State<AnimationsShowcasePage> {
  bool _rtl = false;
  bool _reduceMotion = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animations showcase')),
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: _reduceMotion),
        child: Directionality(
          textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
          child: ListView(
            padding: const EdgeInsets.all(_pad),
            children: [
              _ControlsCard(
                rtl: _rtl,
                reduceMotion: _reduceMotion,
                onRtlChanged: (value) => setState(() => _rtl = value),
                onReduceMotionChanged: (value) =>
                    setState(() => _reduceMotion = value),
              ),
              const _EntranceSection(),
              const _StaggeredSection(),
              const _FeedbackSection(),
              const _LoadingSection(),
              const _StateSection(),
              const _NavigationSection(),
              const _OverlaysSection(),
              const _ScrollSection(),
              const _LottieSection(),
            ],
          ),
        ),
      ),
    );
  }
}

/// The RTL and reduce-motion switches at the top of the showcase.
class _ControlsCard extends StatelessWidget {
  const _ControlsCard({
    required this.rtl,
    required this.reduceMotion,
    required this.onRtlChanged,
    required this.onReduceMotionChanged,
  });

  final bool rtl;
  final bool reduceMotion;
  final ValueChanged<bool> onRtlChanged;
  final ValueChanged<bool> onReduceMotionChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('RTL layout'),
            subtitle: const Text('Flips Directionality for everything below'),
            value: rtl,
            onChanged: onRtlChanged,
          ),
          SwitchListTile(
            title: const Text('Disable animations'),
            subtitle: const Text('Simulates the system reduce-motion setting'),
            value: reduceMotion,
            onChanged: onReduceMotionChanged,
          ),
          Padding(
            padding: const EdgeInsets.all(_pad),
            child: Text(
              'The toggles cover this page. Overlay entrance styles follow '
              'the call site, so dialogs and sheets honour them as well; '
              'content inside those routes reads the app-level settings.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared section shell: a titled card for one animation group.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: _sectionGap),
      child: Padding(
        padding: const EdgeInsets.all(_pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: _gap),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// A demo widget with a small label under it.
class _Caption extends StatelessWidget {
  const _Caption({required this.text, required this.child});

  final String text;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: _captionGap),
        Text(text, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

/// A labeled, theme-colored box used as demo content.
class _LabelBox extends StatelessWidget {
  const _LabelBox(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _pad,
          vertical: _boxPad,
        ),
        child: Text(text, style: theme.textTheme.labelLarge),
      ),
    );
  }
}

/// A button that remounts its section's demos (entrances play once, so
/// replaying means building them again under a new key).
class _ReplayButton extends StatelessWidget {
  const _ReplayButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) =>
      FilledButton.tonal(onPressed: onPressed, child: const Text('Replay'));
}

// ---------------------------------------------------------------------------
// Entrance
// ---------------------------------------------------------------------------

class _EntranceSection extends StatefulWidget {
  const _EntranceSection();

  @override
  State<_EntranceSection> createState() => _EntranceSectionState();
}

class _EntranceSectionState extends State<_EntranceSection> {
  int _replay = 0;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Entrance — plays once, never replays',
      children: [
        Wrap(
          spacing: _gap,
          runSpacing: _gap,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Caption(text: 'fadeIn', child: const Text('Fade in').fadeIn()),
            _Caption(
              text: 'slideIn',
              child: const Icon(Icons.arrow_upward).slideIn(),
            ),
            _Caption(
              text: 'scaleIn',
              child: const Icon(Icons.zoom_in_outlined).scaleIn(),
            ),
            _Caption(
              text: 'fadeSlideIn',
              child: const Card(child: _LabelBox('Card')).fadeSlideIn(),
            ),
            _Caption(
              text: 'blurIn',
              child: const Card(child: _LabelBox('Focused')).blurIn(),
            ),
          ],
        ),
        const SizedBox(height: _gap),
        // A new key remounts the subtree, which replays every entrance.
        KeyedSubtree(
          key: ValueKey<int>(_replay),
          child: FadeSlideIn(
            delay: AppDurations.stagger,
            child: const Card(child: _LabelBox('FadeSlideIn with delay')),
          ),
        ),
        const SizedBox(height: _gap),
        _ReplayButton(onPressed: () => setState(() => _replay++)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Staggered
// ---------------------------------------------------------------------------

class _StaggeredSection extends StatefulWidget {
  const _StaggeredSection();

  @override
  State<_StaggeredSection> createState() => _StaggeredSectionState();
}

class _StaggeredSectionState extends State<_StaggeredSection> {
  int _replay = 0;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Staggered — index delays, never replays on scroll-back',
      children: [
        KeyedSubtree(
          key: ValueKey<int>(_replay),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StaggeredColumn(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LabelBox('First in'),
                  _LabelBox('Second in'),
                  _LabelBox('Third in'),
                ],
              ),
              const SizedBox(height: _gap),
              for (var index = 0; index < _staggeredRows; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: _captionGap),
                  child: _LabelBox('List row $index').staggered(index: index),
                ),
              const SizedBox(height: _gap),
              GridView.count(
                crossAxisCount: _gridColumns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: _gap,
                mainAxisSpacing: _gap,
                childAspectRatio: _gridAspect,
                children: [
                  for (var index = 0; index < _gridCells; index++)
                    StaggeredGridItem(
                      index: index ~/ _gridColumns,
                      child: const _LabelBox('Grid cell'),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: _gap),
        _ReplayButton(onPressed: () => setState(() => _replay++)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Feedback
// ---------------------------------------------------------------------------

class _FeedbackSection extends StatefulWidget {
  const _FeedbackSection();

  @override
  State<_FeedbackSection> createState() => _FeedbackSectionState();
}

class _FeedbackSectionState extends State<_FeedbackSection> {
  final ShakeController _shake = ShakeController();
  final BounceController _bounce = BounceController();
  int _taps = 0;
  bool _pulseActive = true;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Feedback — press, shake, pulse, bounce',
      children: [
        Wrap(
          spacing: _gap,
          runSpacing: _gap,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Caption(
              text: 'tapScale (${_taps > 0 ? '$_taps taps' : 'tap me'})',
              child: const _LabelBox('Tappable').tapScale(
                haptic: HapticType.light,
                onTap: () => setState(() => _taps++),
              ),
            ),
            _Caption(
              text: 'shake (haptic error)',
              child: const _LabelBox('Invalid').shake(_shake, haptic: true),
            ),
            _Caption(
              text: 'pulse',
              child: const _LabelBox('Badge').pulse(active: _pulseActive),
            ),
            _Caption(
              text: 'bounce',
              child: const _LabelBox('Landed').bounce(_bounce),
            ),
          ],
        ),
        const SizedBox(height: _gap),
        Wrap(
          spacing: _gap,
          runSpacing: _gap,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.tonal(
              onPressed: _shake.shake,
              child: const Text('Shake'),
            ),
            FilledButton.tonal(
              onPressed: _bounce.bounce,
              child: const Text('Bounce'),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Pulse loop'),
                Switch(
                  value: _pulseActive,
                  onChanged: (value) => setState(() => _pulseActive = value),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Loading
// ---------------------------------------------------------------------------

class _LoadingSection extends StatefulWidget {
  const _LoadingSection();

  @override
  State<_LoadingSection> createState() => _LoadingSectionState();
}

class _LoadingSectionState extends State<_LoadingSection> {
  double _progress = _initialProgress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return _Section(
      title: 'Loading — shimmer, pulse, progress',
      children: [
        Text(
          'One ShimmerScope sweeps every box inside',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: _captionGap),
        ShimmerScope(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SkeletonListTile(),
              const SizedBox(height: _gap),
              const SkeletonCard(),
              const SizedBox(height: _gap),
              const Row(
                children: [
                  ShimmerBox.circle(width: _placeholderSize),
                  SizedBox(width: _gap),
                  ShimmerBox.textLine(width: _textLineWidth),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: _gap),
        Text(
          'PulsingPlaceholder — cheaper in long lists',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: _captionGap),
        const Wrap(
          spacing: _gap,
          runSpacing: _gap,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            PulsingPlaceholder.circle(width: _placeholderSize),
            PulsingPlaceholder.textLine(width: _textLineWidth),
            PulsingPlaceholder(
              height: _placeholderSize,
              width: _placeholderSize,
            ),
          ],
        ),
        const SizedBox(height: _gap),
        Text('Determinate progress', style: theme.textTheme.bodySmall),
        const SizedBox(height: _captionGap),
        AnimatedProgressBar(progress: _progress),
        Slider(
          value: _progress,
          onChanged: (value) => setState(() => _progress = value),
        ),
        Text('Indeterminate progress', style: theme.textTheme.bodySmall),
        const SizedBox(height: _captionGap),
        const AnimatedProgressBar(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class _StateSection extends StatefulWidget {
  const _StateSection();

  @override
  State<_StateSection> createState() => _StateSectionState();
}

class _StateSectionState extends State<_StateSection> {
  bool _visible = true;
  bool _wide = false;
  int _total = _counterStart;
  int _switcherIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return _Section(
      title: 'State — visibility, size, counter, expand, switch',
      children: [
        Wrap(
          spacing: _gap,
          runSpacing: _gap,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('AnimatedVisibility'),
            Switch(
              value: _visible,
              onChanged: (value) => setState(() => _visible = value),
            ),
            const Text('AnimatedSizeWrapper'),
            Switch(
              value: _wide,
              onChanged: (value) => setState(() => _wide = value),
            ),
          ],
        ),
        const SizedBox(height: _captionGap),
        AnimatedVisibility(
          visible: _visible,
          child: const Card(
            child: _LabelBox('Banner that fades and collapses'),
          ),
        ),
        const SizedBox(height: _gap),
        AnimatedSizeWrapper(
          alignment: AlignmentDirectional.topStart,
          child: _wide
              ? const Card(
                  child: Padding(
                    padding: EdgeInsets.all(_pad),
                    child: Text('A wider child, resized smoothly'),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: _gap),
        Wrap(
          spacing: _gap,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AnimatedCounter(
              value: _total,
              locale: Localizations.localeOf(context),
              style: theme.textTheme.headlineSmall,
            ),
            FilledButton.tonal(
              onPressed: () => setState(() => _total += _counterStep),
              child: const Text('Add 1,000'),
            ),
          ],
        ),
        const SizedBox(height: _gap),
        const ExpandableSection(
          header: Text('Advanced filters'),
          body: Padding(
            padding: EdgeInsets.symmetric(vertical: _pad),
            child: Text('The body expands and collapses with the arrow.'),
          ),
        ),
        const SizedBox(height: _gap),
        Text(
          'AppAnimatedSwitcher between three states',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: _captionGap),
        AppAnimatedSwitcher(
          child: KeyedSubtree(
            key: ValueKey<int>(_switcherIndex),
            child: _switcherChild(_switcherIndex),
          ),
        ),
        const SizedBox(height: _gap),
        FilledButton.tonal(
          onPressed: () => setState(
            () => _switcherIndex = (_switcherIndex + 1) % _switcherStates,
          ),
          child: const Text('Next state'),
        ),
      ],
    );
  }

  Widget _switcherChild(int index) => switch (index % _switcherStates) {
    0 => const Card(child: _LabelBox('Content')),
    1 => const Card(
      child: Padding(
        padding: EdgeInsets.all(_pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedProgressBar(),
            SizedBox(height: _gap),
            Text('Loading…'),
          ],
        ),
      ),
    ),
    _ => const Card(
      child: Padding(
        padding: EdgeInsets.all(_pad),
        child: Row(
          children: [
            Icon(Icons.error_outline),
            SizedBox(width: _gap),
            Text('Something went wrong'),
          ],
        ),
      ),
    ),
  };
}

// ---------------------------------------------------------------------------
// Navigation
// ---------------------------------------------------------------------------

class _NavigationSection extends StatelessWidget {
  const _NavigationSection();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return _Section(
      title: 'Navigation — AppPageTransitions',
      children: [
        Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (final AppPageTransition transition in AppPageTransition.values)
              FilledButton.tonal(
                onPressed: () => _pushDemoPage(context, transition),
                child: Text(transition.name),
              ),
          ],
        ),
        const SizedBox(height: _gap),
        Text(
          'Each button pushes a demo page with the app\'s real transition; '
          'go back with the arrow or the back swipe.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  /// Pushes [title]'s demo page with the given transition. See the file
  /// header for the approved H-5 exception.
  void _pushDemoPage(BuildContext context, AppPageTransition transition) {
    final CustomTransitionPage<Object?> page = AppPageTransitions.page<Object?>(
      transition: transition,
      context: context,
      state: _demoRouterState(transition.name),
      child: _TransitionDemoPage(title: transition.name),
    );
    Navigator.of(context).push(page.createRoute(context));
  }
}

/// The minimal [GoRouterState] `AppPageTransitions.page` needs: the page
/// builder reads only `pageKey`, so the rest is a throwaway configuration
/// around the synthetic root location. Dev-only.
GoRouterState _demoRouterState(String key) => GoRouterState(
  RouteConfiguration(
    ValueNotifier<RoutingConfig>(
      RoutingConfig(
        routes: <RouteBase>[
          GoRoute(
            path: _rootLocation,
            builder: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    ),
    navigatorKey: GlobalKey<NavigatorState>(),
  ),
  uri: Uri(path: _rootLocation),
  matchedLocation: _rootLocation,
  fullPath: _rootLocation,
  pathParameters: const <String, String>{},
  pageKey: ValueKey<String>(key),
);

/// The destination pushed by the Navigation section.
class _TransitionDemoPage extends StatelessWidget {
  const _TransitionDemoPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Transition: $title')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.open_in_new, size: _heroIconSize),
            const SizedBox(height: _gap),
            Text(
              'A page pushed with $title.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: _gap),
            Text(
              'Go back with the arrow or the back swipe.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Overlays
// ---------------------------------------------------------------------------

class _OverlaysSection extends StatelessWidget {
  const _OverlaysSection();

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Overlays — dialogs, sheets, snackbars, menus',
      children: [
        Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            FilledButton.tonal(
              onPressed: () => _showDemoDialog(context),
              child: const Text('Dialog'),
            ),
            FilledButton.tonal(
              onPressed: () => _showDemoSheet(context),
              child: const Text('Bottom sheet'),
            ),
            FilledButton.tonal(
              onPressed: () =>
                  _showDemoSnackbar(context, AppSnackbarType.success),
              child: const Text('Snackbar (success)'),
            ),
            FilledButton.tonal(
              onPressed: () =>
                  _showDemoSnackbar(context, AppSnackbarType.error),
              child: const Text('Snackbar (error)'),
            ),
            AppPopupMenu<String>(
              tooltip: 'More actions',
              onSelected: (value) => _showPickedMessage(context, value),
              items: const [
                PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                PopupMenuItem<String>(value: 'archive', child: Text('Archive')),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showDemoDialog(BuildContext context) => AppDialog.show<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete project?'),
      content: const Text('This removes the project and all its reports.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  Future<void> _showDemoSheet(BuildContext context) =>
      AppBottomSheet.show<void>(
        context: context,
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit row'),
                onTap: () => Navigator.pop(sheetContext),
              ),
              ListTile(
                leading: const Icon(Icons.archive_outlined),
                title: const Text('Archive row'),
                onTap: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        ),
      );

  Future<void> _showDemoSnackbar(BuildContext context, AppSnackbarType type) =>
      AppSnackbar.show(
        context,
        message: type == AppSnackbarType.success
            ? 'Project saved'
            : 'Save failed',
        type: type,
      );

  Future<void> _showPickedMessage(BuildContext context, String value) =>
      AppSnackbar.show(
        context,
        message: 'Picked $value',
        type: AppSnackbarType.info,
      );
}

// ---------------------------------------------------------------------------
// Scroll
// ---------------------------------------------------------------------------

class _ScrollSection extends StatelessWidget {
  const _ScrollSection();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return _Section(
      title: 'Scroll — reveal, parallax, collapsing header, bar fade',
      children: [
        SizedBox(
          height: _scrollDemoHeight,
          child: Stack(
            children: [
              AppBarFadeOnScroll(
                child: CustomScrollView(
                  slivers: [
                    CollapsingHeader(
                      expandedHeight: _collapseHeaderHeight,
                      title: const Text('Profile'),
                      background: ColoredBox(
                        color: scheme.tertiaryContainer,
                        child: Center(
                          child: Icon(
                            Icons.person,
                            size: _heroIconSize,
                            color: scheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(_pad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: _parallaxDemoHeight,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ParallaxWidget(
                                    child: ColoredBox(
                                      color: scheme.secondaryContainer,
                                      child: Center(
                                        child: Icon(
                                          Icons.landscape,
                                          size: _heroIconSize,
                                          color: scheme.onSecondaryContainer,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional.bottomStart,
                                    child: Padding(
                                      padding: const EdgeInsets.all(_pad),
                                      child: Text(
                                        'Parallax background',
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                              color:
                                                  scheme.onSecondaryContainer,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: _gap),
                            for (
                              var index = 0;
                              index < _scrollDemoRows;
                              index++
                            )
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: _captionGap,
                                ),
                                child: RevealOnScroll(
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(_pad),
                                      child: Text(
                                        'Row ${index + 1} — revealed on scroll',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PositionedDirectional(
                top: 0,
                start: 0,
                end: 0,
                child: FadeOnScrollBar(
                  backgroundColor: scheme.surface,
                  child: SizedBox(
                    height: kToolbarHeight,
                    child: Center(
                      child: Text(
                        'Scroll me',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Lottie
// ---------------------------------------------------------------------------

class _LottieSection extends StatelessWidget {
  const _LottieSection();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return _Section(
      title: 'Lottie — AppLottie wrappers',
      children: [
        Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: const [
            _Caption(
              text: 'success',
              child: AppLottie.success(size: _lottieDemoSize),
            ),
            _Caption(
              text: 'loading',
              child: AppLottie.loading(size: _lottieDemoSize),
            ),
            _Caption(
              text: 'error',
              child: AppLottie.error(size: _lottieDemoSize),
            ),
            _Caption(
              text: 'empty',
              child: AppLottie.empty(size: _lottieDemoSize),
            ),
          ],
        ),
        const SizedBox(height: _gap),
        Text(
          'Drop success.json, error.json, empty.json and loading.json into '
          'assets/animations/ — until then each box shows its fallback icon, '
          'which is the intended degraded state.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Layout constants (dev-only; animation values always come from tokens)
// ---------------------------------------------------------------------------

const double _pad = 16;
const double _gap = 12;
const double _boxPad = 8;
const double _radius = 12;
const double _sectionGap = 8;
const double _captionGap = 4;
const double _placeholderSize = 40;
const double _textLineWidth = 200;
const double _scrollDemoHeight = 360;
const double _collapseHeaderHeight = 220;
const double _parallaxDemoHeight = 120;
const double _heroIconSize = 48;
const double _lottieDemoSize = 56;
const double _gridAspect = 1.8;
const int _gridColumns = 2;
const int _gridCells = 4;
const int _staggeredRows = 4;
const int _scrollDemoRows = 6;
const int _switcherStates = 3;
const int _counterStart = 1240;
const int _counterStep = 1000;
const double _initialProgress = 0.35;
const String _rootLocation = '/';
