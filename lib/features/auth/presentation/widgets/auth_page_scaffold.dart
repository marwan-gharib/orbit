import 'package:flutter/material.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';

import '../constants/auth_layout_constants.dart';

/// Shared frame for every auth screen: two soft brand glows behind a
/// scrollable content column that is capped to [AuthLayout.contentMaxWidth]
/// and stays clear of the keyboard and system bars.
///
/// The layout is intentionally top-aligned: auth forms grow downward as
/// validation and banners appear, so centring would make the form jump.
class AuthPageScaffold extends StatelessWidget {
  const AuthPageScaffold({required this.children, this.footer, super.key});

  /// Main content, in order, laid out full width inside the cap.
  final List<Widget> children;

  /// Optional bottom slot (navigation link, legal note).
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          PositionedDirectional(
            top: AuthLayout.glowOffset,
            end: AuthLayout.glowOffset,
            child: _Glow(color: colors.primarySoft),
          ),
          PositionedDirectional(
            bottom: AuthLayout.glowOffset,
            start: AuthLayout.glowOffset,
            child: _Glow(color: colors.primarySoft),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsetsDirectional.only(
                start: AppSpacing.md,
                end: AppSpacing.md,
                top: AppSpacing.xl,
                bottom: AppSpacing.xxl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: AuthLayout.contentMaxWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...children,
                      if (footer case final footerWidget?) ...[
                        SizedBox(height: AppSpacing.lg),
                        footerWidget,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A non-interactive radial tint derived from a theme colour.
class _Glow extends StatelessWidget {
  const _Glow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: Container(
          width: AuthLayout.glowSize,
          height: AuthLayout.glowSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: AuthLayout.glowStartOpacity),
                color.withValues(alpha: AuthLayout.glowEndOpacity),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
