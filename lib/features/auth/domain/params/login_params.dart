/// Input of the login flow; more than one primitive, so ONE params class.
final class LoginParams {
  const LoginParams({required this.email, required this.password});

  final String email;
  final String password;
}
