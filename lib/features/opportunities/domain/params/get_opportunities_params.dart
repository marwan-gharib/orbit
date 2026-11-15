import 'package:equatable/equatable.dart';

import 'opportunities_criteria.dart';

/// Input of the opportunities list fetch: criteria plus paging arguments.
/// Paging arguments are NOT part of the criteria so the repository stays
/// stateless (DATA-7).
final class GetOpportunitiesParams extends Equatable {
  const GetOpportunitiesParams({
    required this.criteria,
    required this.page,
    required this.pageSize,
  });

  final OpportunitiesCriteria criteria;
  final int page;
  final int pageSize;

  @override
  List<Object?> get props => [criteria, page, pageSize];
}
