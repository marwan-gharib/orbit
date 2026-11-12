import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';
import 'package:orbit/features/opportunities/presentation/widgets/opportunity_header.dart';

/// Pinned bar of the detail page: transparent while the header is on screen
/// (just the back button), then its surface and the compact title fade in as
/// the page scrolls. [collapse] goes 0 → 1 over the header fade distance.
class DetailAppBar extends StatelessWidget {
  const DetailAppBar({super.key, required this.collapse, required this.title});

  final ValueListenable<double> collapse;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SliverAppBar(
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      leading: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: ValueListenableBuilder<double>(
        valueListenable: collapse,
        builder: (context, progress, _) => DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: progress),
            border: Border(
              bottom: BorderSide(
                color: colors.border.withValues(alpha: progress),
              ),
            ),
          ),
          child: const SizedBox.expand(),
        ),
      ),
      title: ValueListenableBuilder<double>(
        valueListenable: collapse,
        builder: (context, progress, child) => Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, (1 - progress) * AppSpacing.sm),
            child: child,
          ),
        ),
        child: Text(
          title,
          style: context.textStyles.titleMedium.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// Natural-height header that fades and lags slightly behind the scroll.
class DetailHeaderSliver extends StatelessWidget {
  const DetailHeaderSliver({
    super.key,
    required this.collapse,
    required this.opportunity,
  });

  final ValueListenable<double> collapse;
  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ValueListenableBuilder<double>(
        valueListenable: collapse,
        builder: (context, progress, child) {
          final reduceMotion = MediaQuery.disableAnimationsOf(context);
          return Opacity(
            opacity: 1 - progress,
            child: Transform.translate(
              offset: Offset(
                0,
                reduceMotion
                    ? 0
                    : progress * OpportunityLayoutConstants.headerParallaxShift,
              ),
              child: child,
            ),
          );
        },
        child: OpportunityHeader(opportunity: opportunity),
      ),
    );
  }
}
