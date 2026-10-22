import 'package:orbit/core/constants/api_keys.dart';

import 'package:orbit/features/auth/domain/entities/signup_result_entity.dart';

/// The signup echo (wire keys differ from login: `first_name`/`last_name`
/// are returned here, while the request carries `work_email`).
final class SignupResponseModel {
  const SignupResponseModel({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  final String firstName;
  final String lastName;
  final String email;

  factory SignupResponseModel.fromJson(Map<String, dynamic> json) =>
      SignupResponseModel(
        firstName: json[ApiKeys.firstNameKey] as String,
        lastName: json[ApiKeys.lastNameKey] as String,
        email: json[ApiKeys.emailKey] as String,
      );

  SignupResult toEntity() =>
      SignupResult(firstName: firstName, lastName: lastName, email: email);
}
