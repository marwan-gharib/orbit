/// Reusable `TextFormField` validators: each factory returns a
/// `String? Function(String?)`. [message] is required on purpose — validators
/// are UI-free, so the caller passes the localized copy (UI-4); there is no
/// English default to strip later. Empty input passes except for [required],
/// so presence and format validation stay independent.
abstract final class Validators {
  /// Minimum length of a valid password; predicates and rules both read it.
  static const int passwordMinLength = 8;

  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  static final RegExp _digitsOnly = RegExp(r'^[0-9]+$');
  static final RegExp _phoneDigits = RegExp(r'^\+?[0-9]{7,15}$');
  static final RegExp _hasUppercase = RegExp(r'[A-Z]');
  static final RegExp _hasLowercase = RegExp(r'[a-z]');
  static final RegExp _hasDigit = RegExp(r'[0-9]');
  static final RegExp _phoneSeparators = RegExp(r'[\s()-]');

  /// Unicode letters only: no spaces, digits, or symbols.
  static final RegExp _lettersOnly = RegExp(r'^\p{L}+$', unicode: true);

  /// One Unicode character that is neither a letter, a digit, nor whitespace.
  static final RegExp _specialCharacter = RegExp(
    r'[^\p{L}\p{N}\s]',
    unicode: true,
  );

  /// Whether [value] (trimmed) matches the email format.
  static bool isEmailValid(String value) => _email.hasMatch(value.trim());

  /// Whether [value] (trimmed) is non-empty Unicode letters only.
  static bool isLettersOnly(String value) =>
      _lettersOnly.hasMatch(value.trim());

  static bool hasUppercase(String value) => _hasUppercase.hasMatch(value);

  static bool hasLowercase(String value) => _hasLowercase.hasMatch(value);

  static bool hasDigit(String value) => _hasDigit.hasMatch(value);

  /// Whether [value] holds at least one symbol such as `_`, `!`, or `@`.
  static bool hasSpecialCharacter(String value) =>
      _specialCharacter.hasMatch(value);

  static bool hasMinLength(String value, int minLength) =>
      value.length >= minLength;

  static String? Function(String?) required({required String message}) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }

  static String? Function(String?) email({required String message}) {
    return (value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return null;
      if (!_email.hasMatch(text)) {
        return message;
      }
      return null;
    };
  }

  static String? Function(String?) password({required String message}) {
    return (value) {
      final text = value ?? '';
      if (text.isEmpty) return null;
      if (!hasMinLength(text, passwordMinLength)) {
        return message;
      }
      if (!hasUppercase(text)) {
        return message;
      }
      if (!hasLowercase(text)) {
        return message;
      }
      if (!hasDigit(text)) {
        return message;
      }
      return null;
    };
  }

  /// Empty input passes; otherwise every character must be a letter.
  static String? Function(String?) lettersOnly({required String message}) {
    return (value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return null;
      if (!isLettersOnly(text)) {
        return message;
      }
      return null;
    };
  }

  /// Compares the value with the live value of [original] — a closure so a
  /// password field changing after the first validation is still caught.
  static String? Function(String?) matches({
    required String Function() original,
    required String message,
  }) {
    return (value) {
      if ((value ?? '') != original()) {
        return message;
      }
      return null;
    };
  }

  static String? Function(String?) confirmPassword(
    String original, {
    required String message,
  }) {
    return (value) {
      if ((value ?? '') != original) {
        return message;
      }
      return null;
    };
  }

  static String? Function(String?) phone({required String message}) {
    return (value) {
      final text = (value ?? '').replaceAll(_phoneSeparators, '');
      if (text.isEmpty) return null;
      if (!_phoneDigits.hasMatch(text)) {
        return message;
      }
      return null;
    };
  }

  static String? Function(String?) minLength(
    int length, {
    required String message,
  }) {
    return (value) {
      final text = value ?? '';
      if (text.isEmpty) return null;
      if (text.length < length) {
        return message;
      }
      return null;
    };
  }

  static String? Function(String?) maxLength(
    int length, {
    required String message,
  }) {
    return (value) {
      final text = value ?? '';
      if (text.isEmpty) return null;
      if (text.length > length) {
        return message;
      }
      return null;
    };
  }

  static String? Function(String?) numeric({required String message}) {
    return (value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return null;
      if (!_digitsOnly.hasMatch(text)) {
        return message;
      }
      return null;
    };
  }

  /// Chains [validators] in order and returns the first failure, or `null`
  /// when they all pass.
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
