import 'package:orbit/core/constants/api_keys.dart';
import 'package:orbit/core/errors/failures.dart';

/// Wire keys the signup backend can report per field. Anything else in a
/// `ValidationFailure` falls back to the generic banner (risk 10).
const Set<String> _signupFieldKeys = {
  ApiKeys.firstNameKey,
  ApiKeys.lastNameKey,
  ApiKeys.workEmailKey,
  ApiKeys.passwordKey,
};

/// The subset of a signup failure that has an inline field slot.
///
/// [ValidationFailure.fieldErrors] is already filtered for user safety by the
/// error mapper; this only decides where each message is displayed. Only the
/// first message per field is shown — an inline slot holds one line.
Map<String, String> mappedSignupFieldErrors(Failure failure) {
  if (failure is! ValidationFailure) return const {};
  return {
    for (final entry in failure.fieldErrors.entries)
      if (_signupFieldKeys.contains(entry.key) && entry.value.isNotEmpty)
        entry.key: entry.value.first,
  };
}

/// Whether a signup failure still needs the generic banner because some
/// server detail has no inline slot (or there is no field detail at all).
bool signupFailureHasUnmappedErrors(Failure failure) {
  if (failure is! ValidationFailure) return true;
  if (failure.fieldErrors.isEmpty) return true;
  return failure.fieldErrors.keys.any((key) => !_signupFieldKeys.contains(key));
}
