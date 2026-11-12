import 'dart:async';

import 'package:flutter/material.dart';
import 'package:orbit/core/animations/feedback/shake_widget.dart';
import 'package:orbit/core/animations/state/animated_visibility.dart';
import 'package:orbit/core/animations/state/drawn_check.dart';
import 'package:orbit/core/animations/tokens/app_durations.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';
import 'package:orbit/core/theme/extensions/text_styles_extension.dart';
import 'package:orbit/core/utils/formatters.dart';
import 'package:orbit/core/widgets/app_card.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_status.dart';
import 'package:orbit/features/opportunities/presentation/constants/opportunity_layout_constants.dart';

/// Result banner for won / lost opportunities (open ones have none).
///
/// Each treatment plays once, when the banner first appears:
/// - won: the check draws itself with a small burst;
/// - lost: the card shakes, then the banner expands to reveal the reason.
class StatusBanner extends StatefulWidget {
  const StatusBanner({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  State<StatusBanner> createState() => _StatusBannerState();
}

class _StatusBannerState extends State<StatusBanner> {
  final _shake = ShakeController();
  Timer? _revealTimer;
  bool _reasonVisible = false;

  bool get _isLost => widget.opportunity.status == OpportunityStatus.lost;

  @override
  void initState() {
    super.initState();
    if (!_isLost) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _shake.shake();
      _revealTimer = Timer(AppDurations.slow, () {
        if (mounted) setState(() => _reasonVisible = true);
      });
    });
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opportunity = widget.opportunity;
    if (opportunity.status == OpportunityStatus.open ||
        opportunity.status == OpportunityStatus.unknown) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;
    final textStyles = context.textStyles;
    final t = context.t.crm.crmOpportunities.detail;
    final isWon = !_isLost;
    final iconBox = OpportunityLayoutConstants.statusIconSize;
    final closedAt = opportunity.closedAt;
    final reason = opportunity.lostReason.isEmpty
        ? t.lostReasonEmpty
        : opportunity.lostReason;

    return ShakeWidget(
      controller: _shake,
      child: AppCard(
        padding: EdgeInsetsDirectional.all(
          OpportunityLayoutConstants.progressCardPadding,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: iconBox,
              height: iconBox,
              decoration: BoxDecoration(
                color: isWon ? colors.successContainer : colors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isWon
                    ? DrawnCheck(color: colors.onSuccessContainer)
                    : Icon(
                        Icons.close_rounded,
                        color: colors.onErrorContainer,
                      ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isWon ? t.statusWon : t.statusLost,
                    style: textStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isWon ? colors.success : colors.error,
                    ),
                  ),
                  if (isWon && closedAt != null) ...[
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      '${t.facts.closedAt} ${Formatters.crmDate(closedAt)}',
                      style: textStyles.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                  if (!isWon)
                    AnimatedVisibility(
                      visible: _reasonVisible,
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          top: AppSpacing.xs,
                        ),
                        child: Text(
                          reason,
                          style: textStyles.bodyMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
