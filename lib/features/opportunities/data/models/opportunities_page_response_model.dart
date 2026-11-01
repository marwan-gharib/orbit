import 'package:orbit/core/constants/api_keys.dart';

import 'opportunity_model.dart';

/// The DRF-style page envelope: `{"count": ..., "next": ..., "previous": ..., "results": [...]}`.
final class OpportunitiesPageResponseModel {
  const OpportunitiesPageResponseModel({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  final int count;
  final String? next;
  final String? previous;
  final List<OpportunityModel> results;

  factory OpportunitiesPageResponseModel.fromJson(Map<String, dynamic> json) {
    final rawResults = json[ApiKeys.resultsKey];
    if (rawResults is! List) {
      throw const FormatException('Opportunities results root is not a list.');
    }
    return OpportunitiesPageResponseModel(
      count: json[ApiKeys.countKey] as int? ?? 0,
      next: json[ApiKeys.nextKey] as String?,
      previous: json[ApiKeys.previousKey] as String?,
      results: [
        for (final item in rawResults)
          item is Map
              ? OpportunityModel.fromJson(Map<String, dynamic>.from(item))
              : throw const FormatException(
                  'An opportunities list item is not a JSON object.',
                ),
      ],
    );
  }
}
