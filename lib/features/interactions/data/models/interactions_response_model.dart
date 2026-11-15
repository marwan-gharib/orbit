import 'package:equatable/equatable.dart';

import 'package:orbit/core/constants/api_keys.dart';

import 'interaction_model.dart';

/// The interactions list response: a bare `{"Interactions": [...]}` root
/// (capital I on the wire) — NOT paginated. Any malformed item fails the
/// whole parse (strict wire contract, DATA-3).
final class InteractionsResponseModel extends Equatable {
  const InteractionsResponseModel({required this.interactions});

  static const String _rootKey = ApiKeys.interactionsRootKey;

  final List<InteractionModel> interactions;

  factory InteractionsResponseModel.fromJson(Map<String, dynamic> json) {
    final rawList = json[_rootKey];
    if (rawList is! List) {
      throw const FormatException('Interactions response root is not a list.');
    }
    return InteractionsResponseModel(
      interactions: [
        for (final item in rawList)
          item is Map
              ? InteractionModel.fromJson(Map<String, dynamic>.from(item))
              : throw const FormatException(
                  'An interactions list item is not a JSON object.',
                ),
      ],
    );
  }

  @override
  List<Object?> get props => [interactions];
}
