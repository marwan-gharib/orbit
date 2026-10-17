import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/features/onboarding/presentation/constants/onboarding_illustration_constants.dart';
import 'package:orbit/features/onboarding/presentation/constants/onboarding_layout_constants.dart';
import 'package:orbit/features/onboarding/presentation/widgets/illustrations/illustration_motion.dart';
import 'package:orbit/features/onboarding/presentation/widgets/illustrations/onboarding_svg_color_mapper.dart';

/// One declarative layer of a [LayeredIllustration].
sealed class IllustrationLayer {
  const IllustrationLayer({required this.layerKey});

  /// Test-visible key; the layer's opacity root carries it.
  final Key layerKey;

  /// Entrance choreography of this layer.
  EntranceMotion get entrance;

  /// Optional idle loop, running only while the slide is active and settled.
  LayerIdle? get idle;
}

/// A full-square SVG asset layer, stacked at identical size with its siblings.
final class SvgLayer extends IllustrationLayer {
  const SvgLayer({
    required super.layerKey,
    required this.asset,
    required this.entrance,
    this.idle,
  });

  final String asset;

  @override
  final EntranceMotion entrance;

  @override
  final LayerIdle? idle;
}

/// A text slot (numbers are not part of the SVGs): positioned by a normalized
/// [rect] with `PositionedDirectional` outside the mirrored stack, so the
/// text itself never flips. [builder] receives the layer's eased entrance
/// progress and the square side, and owns formatting (slang / `NumberFormat`).
final class TextLayer extends IllustrationLayer {
  const TextLayer({
    required super.layerKey,
    required this.rect,
    required this.entrance,
    this.idle,
    required this.builder,
  });

  final Rect rect;

  @override
  final EntranceMotion entrance;

  @override
  final LayerIdle? idle;

  final Widget Function(BuildContext context, double eased, double side)
  builder;
}

/// Shared stage for the layered SVG onboarding illustrations.
///
/// Owns the theme color mapper (light/dark follow the active theme), the idle
/// activation gate, RTL mirroring of the artwork and paint isolation. Idle
/// loops start once the slide is the active settled page, and every layer
/// then runs its own loop clock. The layers are stacked at identical size and
/// animated with transform/fade only; the text overlay stays unflipped and is
/// positioned directionally.
///
/// For slides configured with [contentBounds] (1 and 3) the 400x400 canvas is
/// positioned so its settled content bounds fill [regionSize] instead of the
/// full square, which makes the artwork clearly larger. All translations stay
/// fractions of the canvas side; the text overlay, ring clipper and bezier
/// dot travel are mapped through the same transform, so everything stays
/// aligned.
class LayeredIllustration extends StatefulWidget {
  const LayeredIllustration({
    required this.progress,
    required this.isActive,
    required this.size,
    required this.layers,
    this.contentBounds,
    this.regionSize,
    super.key,
  }) : assert(
         contentBounds == null || regionSize != null,
         'regionSize is required when contentBounds is set',
       );

  /// Entrance progress: 0.0 → 1.0 during the slide's entrance animation.
  final double progress;

  /// Whether this slide is the active (center) page.
  final bool isActive;

  /// Allocated square size from the layout: the canvas side the 400x400 SVGs
  /// are painted at.
  final Size size;

  /// Layers in z order (back to front); text slots may interleave.
  final List<IllustrationLayer> layers;

  /// Optional settled content bounds (canvas ratios). When set, the canvas is
  /// positioned so these bounds fill [regionSize] (fit-to-content slides 1
  /// and 3); when null the canvas fills the square (slides 2 and 4).
  final Rect? contentBounds;

  /// The region the content fills (required when [contentBounds] is set);
  /// the canvas is centered in the host's illustration area through it.
  final Size? regionSize;

  @override
  State<LayeredIllustration> createState() => _LayeredIllustrationState();
}

class _LayeredIllustrationState extends State<LayeredIllustration> {
  OnboardingSvgColorMapper? _mapper;

  /// Canvas offset so the settled content bounds fill the region. In RTL the
  /// canvas is mirrored, so the mirrored bounds fill the region instead.
  double _canvasDx(double canvasSide, TextDirection direction) {
    final cb = widget.contentBounds!;
    return direction == TextDirection.rtl
        ? (cb.right - 1) * canvasSide
        : -cb.left * canvasSide;
  }

  /// One text slot rect in region space: authored LTR in canvas space and
  /// mapped through the fit-to-content transform. `PositionedDirectional`
  /// mirrors `start` in RTL, so [left] is the LTR start value.
  Rect _textRegionRect(Rect rect) {
    final cb = widget.contentBounds!;
    final region = widget.regionSize!;
    return Rect.fromLTWH(
      (rect.left - cb.left) / cb.width * region.width,
      (rect.top - cb.top) / cb.height * region.height,
      rect.width / cb.width * region.width,
      rect.height / cb.height * region.height,
    );
  }

  /// Settle pulse: during [0.88, 1.00] the whole layer stack scales
  /// 1.0 → 1.012 → 1.0 around its center; identity outside (and exactly at
  /// p = 1).
  double _settlePulseScale(double p) {
    final begin = OnboardingIllustrationSettle.settlePulseBegin;
    final end = OnboardingIllustrationSettle.settlePulseEnd;
    if (p <= begin || p >= end) {
      return 1.0;
    }
    final t = ((p - begin) / (end - begin)).clamp(0.0, 1.0);
    return 1.0 +
        OnboardingIllustrationSettle.settlePulseAmplitude *
            math.sin(math.pi * t);
  }

  @override
  Widget build(BuildContext context) {
    // One mapper per distinct palette: value equality keeps the instance (and
    // flutter_svg's parse cache) stable across rebuilds and animation frames.
    final mapper = OnboardingSvgColorMapper.fromColors(context.colors);
    if (_mapper != mapper) {
      _mapper = mapper;
    }

    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final side = widget.size.shortestSide;

    // Idle loops run only while this slide is the active settled page, on
    // squares big enough to afford them, and with animations enabled; each
    // layer then runs its own loop clock.
    final idleActive =
        widget.isActive &&
        widget.progress >= 1.0 &&
        side >= OnboardingLayoutRatios.lowEndMaxSide &&
        !MediaQuery.disableAnimationsOf(context);

    final pulse = _settlePulseScale(widget.progress);
    final scaledStack = Transform.scale(
      scale: pulse,
      alignment: Alignment.center,
      child: Transform.flip(
        flipX: isRtl,
        child: Stack(
          fit: StackFit.expand,
          children: _svgChildren(side, idleActive),
        ),
      ),
    );

    final svgStack = widget.contentBounds == null || widget.regionSize == null
        ? Positioned.fill(child: scaledStack)
        : Positioned(
            left: _canvasDx(
              side,
              isRtl ? TextDirection.rtl : TextDirection.ltr,
            ),
            top: -widget.contentBounds!.top * side,
            width: side,
            height: side,
            child: scaledStack,
          );

    return RepaintBoundary(
      child: ExcludeSemantics(
        child: Stack(
          fit: StackFit.expand,
          children: [svgStack, ..._overlayChildren(side, idleActive)],
        ),
      ),
    );
  }

  List<Widget> _svgChildren(double side, bool idleActive) {
    final mapper = _mapper!;
    return widget.layers.whereType<SvgLayer>().map((layer) {
      return _AnimatedSvgLayer(
        layer: layer,
        mapper: mapper,
        progress: widget.progress,
        side: side,
        idleActive: idleActive,
      );
    }).toList();
  }

  List<Widget> _overlayChildren(double side, bool idleActive) {
    return widget.layers.whereType<TextLayer>().map((layer) {
      final slot = widget.contentBounds == null
          ? _textSlotRect(layer.rect, side)
          : _textRegionRect(layer.rect);
      return PositionedDirectional(
        start: slot.left,
        top: slot.top,
        width: slot.width,
        height: slot.height,
        child: _AnimatedTextLayer(
          layer: layer,
          progress: widget.progress,
          side: side,
          idleActive: idleActive,
        ),
      );
    }).toList();
  }

  /// Text slot rect authored LTR in canvas space, mapped to the square.
  /// `PositionedDirectional` mirrors `start` in RTL, so this is the LTR value.
  Rect _textSlotRect(Rect rect, double side) => Rect.fromLTWH(
    rect.left * side,
    rect.top * side,
    rect.width * side,
    rect.height * side,
  );
}

/// One SVG layer with a cached [SvgPicture] instance: the picture is only
/// rebuilt when the color mapper changes, so animation frames reuse the same
/// widget (and flutter_svg's parsed vector).
class _AnimatedSvgLayer extends StatefulWidget {
  const _AnimatedSvgLayer({
    required this.layer,
    required this.mapper,
    required this.progress,
    required this.side,
    required this.idleActive,
  });

  final SvgLayer layer;
  final OnboardingSvgColorMapper mapper;
  final double progress;
  final double side;
  final bool idleActive;

  @override
  State<_AnimatedSvgLayer> createState() => _AnimatedSvgLayerState();
}

class _AnimatedSvgLayerState extends State<_AnimatedSvgLayer> {
  SvgPicture? _picture;
  OnboardingSvgColorMapper? _pictureMapper;

  @override
  Widget build(BuildContext context) {
    if (_picture == null || !identical(_pictureMapper, widget.mapper)) {
      _picture = SvgPicture.asset(
        widget.layer.asset,
        fit: BoxFit.contain,
        colorMapper: widget.mapper,
      );
      _pictureMapper = widget.mapper;
    }
    return _LayerOpacity(
      layer: widget.layer,
      progress: widget.progress,
      side: widget.side,
      idleActive: widget.idleActive,
      child: _picture!,
    );
  }
}

/// One text slot, positioned by the stage; entrance and idle wrap the text
/// but never mirror it.
class _AnimatedTextLayer extends StatelessWidget {
  const _AnimatedTextLayer({
    required this.layer,
    required this.progress,
    required this.side,
    required this.idleActive,
  });

  final TextLayer layer;
  final double progress;
  final double side;
  final bool idleActive;

  @override
  Widget build(BuildContext context) {
    return _LayerOpacity(
      layer: layer,
      progress: progress,
      side: side,
      idleActive: idleActive,
      child: layer.builder(context, layer.entrance.easedAt(progress), side),
    );
  }
}

/// Applies the shared pipeline to one layer: the entrance frame first, then
/// the idle loop outside it so loop transforms and clips scale together, all
/// wrapped in the keyed opacity root. A running idle that owns the fade turns
/// the root over to 1.0 and applies the fade inside its own loop frame.
class _LayerOpacity extends StatelessWidget {
  const _LayerOpacity({
    required this.layer,
    required this.progress,
    required this.side,
    required this.idleActive,
    required this.child,
  });

  final IllustrationLayer layer;
  final double progress;
  final double side;
  final bool idleActive;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final idle = layer.idle;
    var wrapped = layer.entrance.decorate(child, p: progress, side: side);
    if (idle != null) {
      wrapped = idle.decorate(wrapped, active: idleActive, side: side);
    }
    return Opacity(
      key: layer.layerKey,
      opacity: idleActive && idle != null && idle.ownsOpacity
          ? 1.0
          : layer.entrance.opacityAt(progress),
      child: wrapped,
    );
  }
}
