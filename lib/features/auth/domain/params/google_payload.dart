import 'package:equatable/equatable.dart';

/// Carries Google identity claims parsed from an ID token.
final class GooglePayload extends Equatable {
  const GooglePayload({
    required this.iss,
    required this.sub,
    required this.email,
    required this.givenName,
    required this.familyName,
    required this.idToken,
  });

  final String iss;
  final String sub;
  final String email;
  final String givenName;
  final String familyName;
  final String idToken;

  @override
  List<Object?> get props => [
    iss,
    sub,
    email,
    givenName,
    familyName,
    idToken,
  ];
}
