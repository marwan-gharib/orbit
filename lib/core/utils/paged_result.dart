import 'package:equatable/equatable.dart';

/// One page of a paginated list (DATA-7).
///
/// Returned by a repository method so the paging state — items, whether more
/// exist, and how to ask for the next page — travels together. The repository
/// stays stateless; the Cubit accumulates the pages.
class PagedResult<T> extends Equatable {
  const PagedResult({
    required this.items,
    required this.hasMore,
    this.nextPage,
    this.nextCursor,
  });

  final List<T> items;

  /// Whether another page can be requested.
  final bool hasMore;

  /// Offset-based cursor; `null` when the API pages by [nextCursor].
  final int? nextPage;

  /// Opaque cursor returned by the API; `null` when the API pages by [nextPage].
  final String? nextCursor;

  @override
  List<Object?> get props => [items, hasMore, nextPage, nextCursor];
}
