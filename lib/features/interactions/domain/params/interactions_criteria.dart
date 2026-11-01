import 'package:equatable/equatable.dart';

import 'package:orbit/features/interactions/domain/enums/interaction_type.dart';

/// Active filters of the interactions list; a null field means unfiltered.
///
/// Filter events build a fresh criteria (the plain-params convention of this
/// codebase — no copyWith); search text is sent as typed — the backend does
/// the `contains` matching, never the client (lowercasing/trimming on the
/// client would silently change what the user searched for).
final class InteractionsCriteria extends Equatable {
  const InteractionsCriteria({
    this.searchText,
    this.type,
    this.customerId,
    this.contactId,
    this.opportunityId,
  });

  /// Free-text search; the backend matches subject OR description, so the
  /// repository fires two merged requests for one non-empty text.
  final String? searchText;
  final InteractionType? type;
  final int? customerId;
  final int? contactId;
  final int? opportunityId;

  @override
  List<Object?> get props => [
    searchText,
    type,
    customerId,
    contactId,
    opportunityId,
  ];
}
