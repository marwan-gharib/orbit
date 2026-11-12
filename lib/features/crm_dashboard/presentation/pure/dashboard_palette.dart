import 'package:flutter/material.dart';
import 'package:orbit/core/theme/extensions/colors_extension.dart';

import '../../domain/enums/dashboard_stage.dart';

/// Theme colour of a pipeline stage (the same colour in every chart).
Color dashboardStageColor(BuildContext context, DashboardStage stage) {
  final colors = context.colors;
  return switch (stage) {
    DashboardStage.lead => colors.secondary,
    DashboardStage.qualified => colors.primary,
    DashboardStage.proposal => colors.warning,
    DashboardStage.negotiation => colors.success,
    DashboardStage.closed => colors.success,
    DashboardStage.unknown => colors.textSecondary,
  };
}
