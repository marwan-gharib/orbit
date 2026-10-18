import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/features/splash/presentation/constants/splash_animation_constants.dart';
import 'package:orbit/features/splash/presentation/constants/splash_layout_constants.dart';
import 'package:orbit/features/splash/presentation/widgets/module_keywords_widget.dart';
import 'package:orbit/features/splash/presentation/widgets/module_nodes_painter.dart';
import 'package:orbit/features/splash/presentation/widgets/orbit_rings_painter.dart';
import 'package:orbit/features/splash/presentation/widgets/splash_composition.dart';
import 'package:orbit/features/splash/presentation/widgets/tagline_reveal_widget.dart';

/// Regression tests for the splash layout/positioning/sizing bugs: elements
/// pinned to the top, orbit elements on the screen edges, and the content
/// collapsing to the top-left when the timeline completes.
///
/// The composition is pumped directly on a controllable clock so the exact
/// capture frames of the 4000ms timeline can be inspected.
class _Screen {
  const _Screen(this.name, this.size);
  final String name;
  final Size size;
}

const _screens = <_Screen>[
  _Screen('small phone', Size(360, 640)),
  _Screen('large phone', Size(412, 915)),
  _Screen('tablet portrait', Size(800, 1280)),
  _Screen('phone landscape', Size(915, 412)),
];

/// Capture points across the 4000ms timeline (hold phase is 3300-3600ms).
const _captureMs = <int>[0, 1000, 2000, 3000, 3600, 4000];

// Minimal localized-content stand-ins; these tests assert layout, not copy.
const _taglineWords = <String>[
  'Every',
  'project.',
  'Every',
  'team.',
  'One',
  'orbit.',
];
const _moduleKeywords = <String>[
  'Projects',
  'People',
  'Finance',
  'Clients',
  'Insights',
];

const _logoAsset = 'assets/images/orbit_logo_whiting_backround.png';

/// Harness: owns the animation controller (tree-owned so its ticker is
/// disposed with the tree), mounts the composition once per screen, and
/// advances the clock frame by frame to each capture point.
class SplashTestHarness extends StatefulWidget {
  const SplashTestHarness({super.key, required this.tester});

  final WidgetTester tester;

  @override
  State<SplashTestHarness> createState() => SplashTestHarnessState();
}

class SplashTestHarnessState extends State<SplashTestHarness>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  int _elapsedMs = 0;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: SplashAnimationConstants.totalDurationMs,
      ),
    );
    // Same as SplashScreen: the timeline starts once the first frame is out.
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SplashComposition(
        controller: controller,
        logoAsset: _logoAsset,
        taglineWords: _taglineWords,
        moduleKeywords: _moduleKeywords,
      ),
    );
  }

  /// Advances the clock to [targetMs] from the start of the animation, in
  /// frame-sized steps so painters and post-frame measurement settle.
  Future<void> pumpTo(int targetMs) async {
    while (_elapsedMs < targetMs) {
      final stepMs = (targetMs - _elapsedMs).clamp(1, 16);
      _elapsedMs += stepMs;
      await widget.tester.pump(Duration(milliseconds: stepMs));
    }
    // One extra frame so post-frame stage-center measurement applies.
    await widget.tester.pump();
  }
}

/// Mounts the harness on a [size]-sized screen and returns its state so the
/// test can drive the animation clock.
Future<SplashTestHarnessState> mountSplash(
  WidgetTester tester,
  Size size,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: SplashTestHarness(tester: tester),
    ),
  );
  return tester.state<SplashTestHarnessState>(find.byType(SplashTestHarness));
}

/// Layout-space top-left of [box]: walks `parentData.offset` up the render
/// tree, so paint-only transforms (exit scale, opacity) do not move it.
Offset _layoutTopLeft(RenderBox box) {
  var offset = Offset.zero;
  RenderObject? current = box;
  while (current != null) {
    final parentData = current.parentData;
    if (parentData is BoxParentData) {
      offset += parentData.offset;
    }
    current = current.parent;
  }
  return offset;
}

/// Layout-space rect of [finder]'s render box: same constraints, same sizes,
/// same positions — ignoring paint transforms.
Rect _layoutRect(WidgetTester tester, Finder finder) {
  final box = tester.renderObject<RenderBox>(finder);
  return _layoutTopLeft(box) & box.size;
}

/// Finds the stage [CustomPaint] painted by the given painter type.
Finder _painterFinder(Type painterType) => find.byWidgetPredicate(
  (widget) =>
      widget is CustomPaint && widget.painter.runtimeType == painterType,
);

void main() {
  for (final screen in _screens) {
    group('splash layout on ${screen.name} '
        '(${screen.size.width}x${screen.size.height})', () {
      testWidgets(
        'should keep the logo centered on the screen center at every frame',
        (tester) async {
          final harness = await mountSplash(tester, screen.size);

          var logoSeen = false;
          for (final ms in _captureMs) {
            await harness.pumpTo(ms);

            final logoFinder = find.byType(Image);
            if (logoFinder.evaluate().isEmpty) {
              continue; // Logo reveal starts at 300ms.
            }
            logoSeen = true;

            expect(
              tester.getCenter(logoFinder).dx,
              closeTo(screen.size.width / 2, 1.0),
              reason: 'logo center X must equal screen center X at ${ms}ms',
            );
          }
          expect(logoSeen, isTrue, reason: 'logo must mount after 300ms');
        },
      );

      testWidgets(
        'should keep logo, tagline and keywords non-overlapping and inside '
        'the safe area at the hold frame',
        (tester) async {
          final harness = await mountSplash(tester, screen.size);
          await harness.pumpTo(SplashAnimationConstants.holdStartMs + 100);

          final logo = tester.getRect(find.byType(Image));
          final tagline = tester.getRect(find.byType(TaglineRevealWidget));
          final keywords = tester.getRect(find.byType(ModuleKeywordsWidget));

          expect(logo.overlaps(tagline), isFalse, reason: 'logo/tagline');
          expect(logo.overlaps(keywords), isFalse, reason: 'logo/keywords');
          expect(
            tagline.overlaps(keywords),
            isFalse,
            reason: 'tagline/keywords',
          );

          // Every tagline word must be fully revealed by the hold frame
          // (the last word is the one a broken stagger can strand).
          final wordOpacities = tester
              .widgetList<Opacity>(
                find.descendant(
                  of: find.byType(TaglineRevealWidget),
                  matching: find.byType(Opacity),
                ),
              )
              .map((opacity) => opacity.opacity);
          expect(
            wordOpacities,
            everyElement(1.0),
            reason: 'all tagline words must be fully opaque at the hold frame',
          );

          for (final (name, rect) in [
            ('logo', logo),
            ('tagline', tagline),
            ('keywords', keywords),
          ]) {
            expect(rect.left, greaterThanOrEqualTo(-0.5), reason: '$name left');
            expect(
              rect.right,
              lessThanOrEqualTo(screen.size.width + 0.5),
              reason: '$name right',
            );
            expect(rect.top, greaterThanOrEqualTo(-0.5), reason: '$name top');
            expect(
              rect.bottom,
              lessThanOrEqualTo(screen.size.height + 0.5),
              reason: '$name bottom',
            );
          }
        },
      );

      testWidgets(
        'should render the final frame with the same layout position and size '
        'as the hold frame',
        (tester) async {
          final harness = await mountSplash(tester, screen.size);
          await harness.pumpTo(SplashAnimationConstants.holdStartMs + 100);

          final holdLogo = _layoutRect(tester, find.byType(Image));
          final holdTagline = _layoutRect(
            tester,
            find.byType(TaglineRevealWidget),
          );
          final holdKeywords = _layoutRect(
            tester,
            find.byType(ModuleKeywordsWidget),
          );

          await harness.pumpTo(SplashAnimationConstants.totalDurationMs);

          final finalLogo = _layoutRect(tester, find.byType(Image));
          final finalTagline = _layoutRect(
            tester,
            find.byType(TaglineRevealWidget),
          );
          final finalKeywords = _layoutRect(
            tester,
            find.byType(ModuleKeywordsWidget),
          );

          expect(finalLogo.topLeft, holdLogo.topLeft, reason: 'logo position');
          expect(finalLogo.size, holdLogo.size, reason: 'logo size');
          expect(
            finalTagline.topLeft,
            holdTagline.topLeft,
            reason: 'tagline position',
          );
          expect(
            finalKeywords.topLeft,
            holdKeywords.topLeft,
            reason: 'keywords position',
          );
        },
      );

      testWidgets(
        'should keep painted stage elements inside the screen minus page '
        'padding',
        (tester) async {
          final harness = await mountSplash(tester, screen.size);

          final page = AppSpacing.pageHorizontal.resolve(TextDirection.ltr);

          // Frame with the orbit rings drawn (100-500ms).
          await harness.pumpTo(400);
          final ringsFinder = _painterFinder(OrbitRingsPainter);
          expect(ringsFinder, findsOneWidget);
          final ringsRect = tester.getRect(ringsFinder);
          expect(
            ringsRect.left,
            greaterThanOrEqualTo(page.left - 0.5),
            reason: 'rings must stay inside the left page padding',
          );
          expect(
            ringsRect.right,
            lessThanOrEqualTo(screen.size.width - page.right + 0.5),
            reason: 'rings must stay inside the right page padding',
          );

          // Frame with the module nodes orbiting (500-2600ms).
          await harness.pumpTo(2000);
          final nodesFinder = _painterFinder(ModuleNodesPainter);
          expect(nodesFinder, findsOneWidget);
          final nodesRect = tester.getRect(nodesFinder);
          expect(
            nodesRect.left,
            greaterThanOrEqualTo(page.left - 0.5),
            reason: 'nodes must stay inside the left page padding',
          );
          expect(
            nodesRect.right,
            lessThanOrEqualTo(screen.size.width - page.right + 0.5),
            reason: 'nodes must stay inside the right page padding',
          );

          // Analytic bound: the outermost painted element (a node at its max
          // orbit plus its glow) must clear the screen minus page padding.
          final stageSide = SplashLayout.fromScreen(screen.size).stageSide;
          final maxPaintedRadius =
              (SplashLayoutRatios.nodeOrbits.first.a +
                  SplashLayoutRatios.nodeGlowRadiusOfStage) *
              stageSide;
          expect(
            screen.size.width / 2 - maxPaintedRadius,
            greaterThanOrEqualTo(page.left - 0.5),
            reason: 'node glow at max orbit must clear the page padding',
          );
        },
      );

      testWidgets(
        'should not position any content render object at the top-left corner '
        'at the final frame',
        (tester) async {
          final harness = await mountSplash(tester, screen.size);
          await harness.pumpTo(SplashAnimationConstants.totalDurationMs);

          for (final (name, finder) in [
            ('logo', find.byType(Image)),
            ('tagline', find.byType(TaglineRevealWidget)),
            ('keywords', find.byType(ModuleKeywordsWidget)),
          ]) {
            final topLeft = _layoutTopLeft(
              tester.renderObject<RenderBox>(finder),
            );
            expect(
              topLeft.dx,
              greaterThan(1.0),
              reason: '$name must not sit at the top-left corner (x)',
            );
            expect(
              topLeft.dy,
              greaterThan(1.0),
              reason: '$name must not sit at the top-left corner (y)',
            );
          }
        },
      );
    });
  }
}
