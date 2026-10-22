import 'package:equatable/equatable.dart';

/// The signup echo. No tokens and no status arrive — the account starts
/// implicitly as `pending`, which the employee-status flow can prove later.
final class SignupResult extends Equatable {
  const SignupResult({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  final String firstName;
  final String lastName;
  final String email;

  @override
  List<Object?> get props => [firstName, lastName, email];
}
