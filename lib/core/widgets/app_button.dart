import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:orbit/core/responsive/responsive.dart';
import 'package:orbit/core/theme/app_radius.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';

enum AppButtonVariant { filled, elevated, outlined, text }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    this.variant = AppButtonVariant.filled,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.semanticLabel,
    this.destructive = false,
    this.cornerRadius,
    this.padding,
    this.minimumSize,
    super.key,
  }) : content = null,
       mirrorInRtl = false,
       size = null;

  /// Creates a filled button (primary action).
  const AppButton.filled({
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.semanticLabel,
    this.destructive = false,
    this.cornerRadius,
    this.padding,
    this.minimumSize,
    super.key,
  }) : variant = AppButtonVariant.filled,
       content = null,
       mirrorInRtl = false,
       size = null;

  /// Creates a text button (secondary action).
  const AppButton.text({
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.semanticLabel,
    this.destructive = false,
    this.minimumSize,
    super.key,
  }) : variant = AppButtonVariant.text,
       content = null,
       cornerRadius = null,
       padding = null,
       mirrorInRtl = false,
       size = null;

  /// Creates an outlined button.
  const AppButton.outlined({
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.semanticLabel,
    this.destructive = false,
    this.minimumSize,
    super.key,
  }) : variant = AppButtonVariant.outlined,
       content = null,
       cornerRadius = null,
       padding = null,
       mirrorInRtl = false,
       size = null;

  /// Creates an elevated button.
  const AppButton.elevated({
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.semanticLabel,
    this.destructive = false,
    this.minimumSize,
    super.key,
  }) : variant = AppButtonVariant.elevated,
       content = null,
       cornerRadius = null,
       padding = null,
       mirrorInRtl = false,
       size = null;

  /// Creates an icon-only button. [icon] is the glyph (or any widget);
  /// [semanticLabel] is required because an icon carries no text for
  /// assistive tech. A back/forward arrow glyph stays visually identical
  /// across directions when [mirrorInRtl] flips it in RTL.
  ///
  /// [variant] picks the surface family: filled/tonal/outlined/ghost for
  /// emphasized/soft/bordered/plain icon actions.
  const AppButton.icon({
    required this.icon,
    required this.semanticLabel,
    this.variant = AppButtonVariant.filled,
    this.onPressed,
    this.mirrorInRtl = false,
    this.isLoading = false,
    this.destructive = false,
    this.size,
    super.key,
  }) : label = '',
       content = null,
       cornerRadius = null,
       padding = null,
       minimumSize = null;

  /// Creates a button that renders caller [content] instead of the standard
  /// label row, on one of the variant surfaces. Overrides only the surface
  /// shape ([cornerRadius], [padding]); colors and states stay the variant's,
  /// so a custom-content button keeps the app's button identity. The caller
  /// owns the colors of its own content.
  const AppButton.content({
    required Widget this.content,
    this.variant = AppButtonVariant.filled,
    this.onPressed,
    this.semanticLabel,
    this.cornerRadius,
    this.padding,
    this.minimumSize,
    super.key,
  }) : label = '',
       icon = null,
       isLoading = false,
       destructive = false,
       mirrorInRtl = false,
       size = null;

  final String label;
  final AppButtonVariant variant;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final String? semanticLabel;
  final BorderRadius? cornerRadius;
  final EdgeInsetsGeometry? padding;

  /// Marks a dangerous action (delete, remove). Uses the theme's error colors
  /// for the surface (filled) or for the label, icon and outline (the other
  /// variants). Ignored by [AppButton.content], whose caller owns its colors.
  final bool destructive;

  /// Caller-rendered content replacing the standard label row
  /// ([AppButton.content] only).
  final Widget? content;

  /// Surface minimum size override ([AppButton.icon] uses [size] instead);
  /// null keeps the Material default for the variant.
  final Size? minimumSize;

  /// Side of the square icon button ([AppButton.icon] only). Never smaller
  /// than the shared 48 dp touch target; null keeps exactly that 48 dp.
  final double? size;

  /// Flips the icon horizontally in RTL, so one arrow glyph points the same
  /// visual way in both directions ([AppButton.icon] only).
  final bool mirrorInRtl;

  /// Color of the label, icon and outline of non-filled surfaces.
  Color _accent(AppColorsExtension colors) =>
      destructive ? colors.error : colors.primary;

  /// Color of content drawn on a filled surface.
  Color _onAccent(AppColorsExtension colors) =>
      destructive ? colors.onError : colors.onPrimary;

  /// Outline in the error color for destructive outlined buttons. Returns
  /// null for the disabled state so the theme's disabled outline is kept.
  WidgetStateProperty<BorderSide?> _destructiveSide(AppColorsExtension colors) {
    return WidgetStateProperty.resolveWith<BorderSide?>(
      (states) => states.contains(WidgetState.disabled)
          ? null
          : BorderSide(color: colors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final isDisabled = onPressed == null || isLoading;

    Widget button;
    if (icon != null && content == null && label.isEmpty) {
      button = _buildIconButton(context, colors, isDisabled);
    } else {
      button = _buildLabelButton(context, colors, textStyles, isDisabled);
    }

    if (semanticLabel != null) {
      button = Semantics(
        label: semanticLabel,
        button: true,
        enabled: !isDisabled,
        excludeSemantics: true,
        child: button,
      );
    }

    return button;
  }

  /// One Material IconButton per variant family, styled from the shared
  /// tokens: the filled face for the primary action, the tonal face for the
  /// soft one, the outlined face for the bordered one and the plain
  /// IconButton for ghost actions. The theme supplies the 48 dp minimum tap
  /// target; [size] grows it further.
  Widget _buildIconButton(
    BuildContext context,
    AppColorsExtension colors,
    bool isDisabled,
  ) {
    Widget glyph = icon ?? const SizedBox.shrink();
    if (mirrorInRtl) {
      glyph = Transform.flip(
        flipX: Directionality.of(context) == TextDirection.rtl,
        child: glyph,
      );
    }

    final isFilled = variant == AppButtonVariant.filled;
    final child = isLoading
        ? SizedBox(
            width: Responsive.adapt(24),
            height: Responsive.adapt(24),
            child: CircularProgressIndicator(
              strokeWidth: Responsive.adapt(2),
              valueColor: AlwaysStoppedAnimation(
                isFilled ? _onAccent(colors) : _accent(colors),
              ),
            ),
          )
        : glyph;

    final side = size == null
        ? null
        : math.max(size!, kMinInteractiveDimension);

    // Padding stays zero so the icon centers in whatever tap target the
    // caller sizes (or in the theme's 48 dp minimum).
    var style = IconButton.styleFrom(
      foregroundColor: isFilled ? _onAccent(colors) : _accent(colors),
      backgroundColor: isFilled && destructive ? colors.error : null,
      fixedSize: side == null ? null : Size.square(side),
      padding: EdgeInsets.zero,
    );
    if (variant == AppButtonVariant.outlined && destructive) {
      style = style.copyWith(side: _destructiveSide(colors));
    }

    // A loading button must not be tappable.
    final effectiveOnPressed = isDisabled ? null : onPressed;

    return switch (variant) {
      AppButtonVariant.filled => IconButton.filled(
        onPressed: effectiveOnPressed,
        style: style,
        icon: child,
      ),
      AppButtonVariant.elevated => IconButton.filledTonal(
        onPressed: effectiveOnPressed,
        style: style,
        icon: child,
      ),
      AppButtonVariant.outlined => IconButton.outlined(
        onPressed: effectiveOnPressed,
        style: style,
        icon: child,
      ),
      AppButtonVariant.text => IconButton(
        onPressed: effectiveOnPressed,
        style: style,
        icon: child,
      ),
    };
  }

  Widget _buildLabelButton(
    BuildContext context,
    AppColorsExtension colors,
    AppTextStylesExtension textStyles,
    bool isDisabled,
  ) {
    final effectiveOnPressed = isDisabled ? null : onPressed;
    final isFilled = variant == AppButtonVariant.filled;

    // The label style bakes in its own color, so a destructive button must
    // recolor the text itself. Disabled buttons keep the standard style.
    final labelStyle = destructive && !isDisabled
        ? textStyles.labelLarge.copyWith(
            color: isFilled ? _onAccent(colors) : _accent(colors),
          )
        : textStyles.labelLarge;

    final Widget child =
        content ??
        (isLoading
            ? SizedBox(
                width: textStyles.labelLarge.fontSize ?? Responsive.adapt(24),
                height: textStyles.labelLarge.fontSize ?? Responsive.adapt(24),
                child: CircularProgressIndicator(
                  strokeWidth: Responsive.adapt(2),
                  valueColor: AlwaysStoppedAnimation(
                    isFilled ? _onAccent(colors) : _accent(colors),
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[icon!, SizedBox(width: AppSpacing.xs)],
                  Text(label, style: labelStyle),
                ],
              ));

    final shape = RoundedRectangleBorder(
      borderRadius: cornerRadius ?? AppRadius.borderSm,
    );
    final effectivePadding = padding ?? AppSpacing.button;

    switch (variant) {
      case AppButtonVariant.filled:
        return FilledButton(
          onPressed: effectiveOnPressed,
          style: FilledButton.styleFrom(
            padding: effectivePadding,
            minimumSize: minimumSize,
            shape: shape,
            backgroundColor: destructive ? colors.error : null,
            foregroundColor: destructive ? colors.onError : null,
          ),
          child: child,
        );
      case AppButtonVariant.elevated:
        return ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            padding: effectivePadding,
            minimumSize: minimumSize,
            shape: shape,
            foregroundColor: destructive ? colors.error : null,
          ),
          child: child,
        );
      case AppButtonVariant.outlined:
        final base = OutlinedButton.styleFrom(
          padding: effectivePadding,
          minimumSize: minimumSize,
          shape: shape,
          foregroundColor: destructive ? colors.error : null,
        );
        return OutlinedButton(
          onPressed: effectiveOnPressed,
          style: destructive
              ? base.copyWith(side: _destructiveSide(colors))
              : base,
          child: child,
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            padding: effectivePadding,
            minimumSize: minimumSize,
            shape: shape,
            foregroundColor: destructive ? colors.error : null,
          ),
          child: child,
        );
    }
  }
}
