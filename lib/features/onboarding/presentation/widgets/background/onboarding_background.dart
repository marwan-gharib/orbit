import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';

/// Animated background with 3 gradient blobs that interpolate position and tint
/// across all 4 slides based on the PageController's fractional page value.
class OnboardingBackground extends StatelessWidget {
  const OnboardingBackground({required this.pageValue, super.key});

  /// Fractional page index from PageController (e.g., 0.0, 0.5, 1.0, 2.3, 3.0).
  final double pageValue;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // 3 blobs, each with 4 keyframes (one per slide)
    final blobs = [
      _BlobData(
        positions: [
          Offset(0.15, 0.1), // Slide 0: top-left
          Offset(0.2, 0.15), // Slide 1
          Offset(0.25, 0.2), // Slide 2
          Offset(0.3, 0.15), // Slide 3
        ],
        radii: [
          0.35, // Slide 0
          0.4, // Slide 1
          0.35, // Slide 2
          0.3, // Slide 3
        ],
        colorStops: [
          colors.primaryContainer.withValues(alpha: 0.15), // Slide 0
          colors.primaryContainer.withValues(alpha: 0.12), // Slide 1
          colors.secondaryContainer.withValues(alpha: 0.1), // Slide 2
          colors.surfaceVariant.withValues(alpha: 0.08), // Slide 3
        ],
      ),
      _BlobData(
        positions: [
          Offset(0.85, 0.2), // Slide 0: top-right
          Offset(0.8, 0.3), // Slide 1
          Offset(0.75, 0.4), // Slide 2
          Offset(0.7, 0.35), // Slide 3
        ],
        radii: [
          0.3, // Slide 0
          0.35, // Slide 1
          0.4, // Slide 2
          0.35, // Slide 3
        ],
        colorStops: [
          colors.secondaryContainer.withValues(alpha: 0.12), // Slide 0
          colors.surfaceVariant.withValues(alpha: 0.1), // Slide 1
          colors.primaryContainer.withValues(alpha: 0.1), // Slide 2
          colors.primaryContainer.withValues(alpha: 0.12), // Slide 3
        ],
      ),
      _BlobData(
        positions: [
          Offset(0.5, 0.85), // Slide 0: bottom-center
          Offset(0.5, 0.8), // Slide 1
          Offset(0.5, 0.75), // Slide 2
          Offset(0.5, 0.7), // Slide 3
        ],
        radii: [
          0.4, // Slide 0
          0.35, // Slide 1
          0.3, // Slide 2
          0.25, // Slide 3
        ],
        colorStops: [
          colors.surfaceVariant.withValues(alpha: 0.1), // Slide 0
          colors.primaryContainer.withValues(alpha: 0.1), // Slide 1
          colors.secondaryContainer.withValues(alpha: 0.08), // Slide 2
          colors.surfaceVariant.withValues(alpha: 0.06), // Slide 3
        ],
      ),
    ];

    // One LayoutBuilder supplies the stack size to every blob, so each blob
    // can be a direct Positioned child (a Positioned inside a LayoutBuilder
    // gets BoxParentData and asserts instead of positioning).
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return Stack(
          fit: StackFit.expand,
          children: [
            for (final blob in blobs)
              _InterpolatedBlob(blob: blob, pageValue: pageValue, size: size),
          ],
        );
      },
    );
  }
}

class _BlobData {
  const _BlobData({
    required this.positions,
    required this.radii,
    required this.colorStops,
  });

  /// Normalized positions (0..1) for each of the 4 slides.
  final List<Offset> positions;

  /// Normalized radii (fraction of min(width, height)) for each slide.
  final List<double> radii;

  /// Colors for each slide.
  final List<Color> colorStops;
}

class _InterpolatedBlob extends StatelessWidget {
  const _InterpolatedBlob({
    required this.blob,
    required this.pageValue,
    required this.size,
  });

  final _BlobData blob;
  final double pageValue;

  /// Full background size from the enclosing [LayoutBuilder].
  final Size size;

  @override
  Widget build(BuildContext context) {
    // Clamp page value to valid range
    final clampedPage = pageValue.clamp(0.0, 3.0).toDouble();
    final index = clampedPage.floor().clamp(0, 2);
    final nextIndex = (index + 1).clamp(0, 3);
    final t = clampedPage - index;

    // Interpolate position
    final pos = Offset.lerp(
      blob.positions[index],
      blob.positions[nextIndex],
      t,
    )!;

    // Interpolate radius
    final radius = lerpDouble(blob.radii[index], blob.radii[nextIndex], t)!;

    // Interpolate color
    final color = Color.lerp(
      blob.colorStops[index],
      blob.colorStops[nextIndex],
      t,
    )!;

    final minDim = size.shortestSide;
    final blobSize = radius * minDim;
    return PositionedDirectional(
      start: pos.dx * size.width - blobSize / 2,
      top: pos.dy * size.height - blobSize / 2,
      child: IgnorePointer(
        child: Container(
          width: blobSize,
          height: blobSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withValues(alpha: 0.0)],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
