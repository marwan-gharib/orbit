import 'package:flutter/material.dart';
import 'package:orbit/core/errors/failures.dart';
import 'package:orbit/core/extensions/context_extensions.dart';
import 'package:orbit/core/i18n/strings.g.dart';
import 'package:orbit/core/theme/app_spacing.dart';
import 'package:orbit/core/widgets/empty_state.dart';
import 'package:orbit/core/widgets/error_state.dart';

/// Full-screen error and not-found view for the opportunity detail route.
class OpportunityDetailErrorView extends StatelessWidget {
  const OpportunityDetailErrorView({
    super.key,
    required this.failure,
    required this.onRetry,
  });

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isNotFound = failure is NotFoundFailure;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => onRetry(),
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.xl),
          children: [
            if (isNotFound)
              EmptyState(
                title: context.failureText(failure),
                icon: Icons.search_off_rounded,
                primaryAction: (
                  label: context.t.crm.common.retry,
                  onPressed: onRetry,
                ),
              )
            else
              ErrorState(
                message: context.failureText(failure),
                retryAction: (
                  label: context.t.crm.common.retry,
                  onPressed: onRetry,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
