import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:orbit/features/onboarding/presentation/constants/onboarding_svg_palette.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';

/// Resolves the 16 placeholder hex values baked into the onboarding SVG
/// layers to the active theme's tokens (light or dark) at render time.
///
/// The mapped ARGB values are frozen at construction and the mapper has value
/// equality: flutter_svg uses the mapper as part of its cache key, so an
/// equal mapper keeps the parsed vector cached and an unequal one (a theme
/// switch) parses the recolored variant.
@immutable
class OnboardingSvgColorMapper extends ColorMapper {
  OnboardingSvgColorMapper.fromColors(AppColorsExtension colors)
    : _resolved = <int>[
        colors.surface.toARGB32(),
        colors.onPrimary.toARGB32(),
        colors.background.toARGB32(),
        colors.border.toARGB32(),
        colors.borderStrong.toARGB32(),
        colors.textDisabled.toARGB32(),
        colors.primary.toARGB32(),
        colors.primarySoft.toARGB32(),
        colors.primaryContainer.toARGB32(),
        colors.secondary.toARGB32(),
        colors.success.toARGB32(),
        colors.successSoft.toARGB32(),
        colors.successContainer.toARGB32(),
        colors.warning.toARGB32(),
        colors.warningContainer.toARGB32(),
        colors.error.toARGB32(),
      ];

  /// The theme colors in [OnboardingSvgPalette.all] order.
  final List<int> _resolved;

  /// The theme color that replaces [hex]; unknown values pass through as a
  /// fully opaque color.
  Color colorFor(int hex) {
    final index = OnboardingSvgPalette.all.indexOf(hex & 0xFFFFFF);
    return index < 0 ? Color(hex | 0xFF000000) : Color(_resolved[index]);
  }

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) => colorFor(color.toARGB32()).withValues(alpha: color.a);

  @override
  bool operator ==(Object other) =>
      other is OnboardingSvgColorMapper &&
      listEquals(other._resolved, _resolved);

  @override
  int get hashCode => Object.hashAll(_resolved);
}
