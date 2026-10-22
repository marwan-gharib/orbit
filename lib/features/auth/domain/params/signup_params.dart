/// Input of the signup flow; more than one primitive, so ONE params class.
/// [workEmail] maps to the signup-specific wire key (`work_email`), distinct
/// from login's `email`.
final class SignupParams {
  const SignupParams({
    required this.firstName,
    required this.lastName,
    required this.workEmail,
    required this.password,
  });

  final String firstName;
  final String lastName;
  final String workEmail;
  final String password;
}
